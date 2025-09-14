import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/cache/base_cache.dart';
import 'package:news_app/core/base/cache/base_media_cache.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/home/data/model/article_cache_model.dart';
import 'package:news_app/feature/home/data/model/article_model.dart';
import 'package:news_app/feature/home/data/model/multimedia_model.dart';

abstract class TopStoriesLocalDataSource {
  Future<Either<Failure, List<ArticleModel>>> getCachedTopStories(
    String section,
  );
  Future<bool> cacheTopStories(String section, List<ArticleModel> articles);
  Future<bool> clearCache();
  Future<bool> isCacheExpired(String section);
  Future<bool> hasCache(String section);
}

class TopStoriesLocalDataSourceImpl implements TopStoriesLocalDataSource {
  static const String _cacheBoxName = 'topstories_cache';
  static const Duration _cacheExpiry = Duration(minutes: 30);

  late final HiveCache<dynamic> _articlesCache;
  late final MediaCacheManager _mediaCache;
  bool _isInitialized = false;

  TopStoriesLocalDataSourceImpl();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      _articlesCache = CacheFactory.getCache<dynamic>(
        _cacheBoxName,
        onError: (error) => print('[TopStoriesLocal] $error'),
      );

      _mediaCache = MediaCacheManager.instance;
      await _mediaCache.initialize();

      // Sync media cache registry on startup
      await _mediaCache.syncCacheRegistry();

      _isInitialized = true;
      print('[TopStoriesLocal] Initialized successfully');
    } catch (e) {
      print('[TopStoriesLocal] Initialization failed: $e');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<ArticleModel>>> getCachedTopStories(
    String section,
  ) async {
    try {
      await _ensureInitialized();

      final dynamic cachedData = await _articlesCache.get(section);

      if (cachedData == null) {
        return Left(CacheFailure('No cached data for section: $section'));
      }

      final List<ArticleCacheModel>? cached = _convertToArticleCacheList(
        cachedData,
      );

      if (cached == null || cached.isEmpty) {
        return Left(CacheFailure('Invalid cached data for section: $section'));
      }

      // Convert cache models to article models with media path sync
      final articles = <ArticleModel>[];
      for (final cacheModel in cached) {
        try {
          final article = cacheModel.toArticleModel();

          // Sync media paths with current cache registry
          if (article.multimedia?.isNotEmpty == true) {
            final updatedMultimedia = <MultimediaModel>[];

            for (final media in article.multimedia!) {
              final mediaModel = media as MultimediaModel;

              // Always check current media cache registry
              String? currentLocalPath;
              if (mediaModel.url != null) {
                currentLocalPath = _mediaCache.getCachedPath(mediaModel.url!);

                // Verify file actually exists
                if (currentLocalPath != null &&
                    !_mediaCache.isCached(mediaModel.url!)) {
                  currentLocalPath = null;
                  print(
                    '[TopStoriesLocal] Cached media file not found: ${mediaModel.url}',
                  );
                }
              }

              updatedMultimedia.add(
                mediaModel.copyWithCache(localPath: currentLocalPath),
              );
            }

            articles.add(
              ArticleModel(
                section: article.section,
                subsection: article.subsection,
                title: article.title,
                abstract: article.abstract,
                url: article.url,
                uri: article.uri,
                byline: article.byline,
                itemType: article.itemType,
                updatedDate: article.updatedDate,
                createdDate: article.createdDate,
                publishedDate: article.publishedDate,
                desFacet: article.desFacet,
                orgFacet: article.orgFacet,
                perFacet: article.perFacet,
                geoFacet: article.geoFacet,
                multimedia: updatedMultimedia,
              ),
            );
          } else {
            articles.add(article);
          }
        } catch (e) {
          print('[TopStoriesLocal] Error converting cached article: $e');
          continue;
        }
      }

      print(
        '[TopStoriesLocal] Retrieved ${articles.length} articles for section: $section',
      );
      return Right(articles);
    } catch (e) {
      print('[TopStoriesLocal] Failed to get cached articles: $e');

      // Try to clear corrupted cache
      try {
        await _articlesCache.remove(section);
        print(
          '[TopStoriesLocal] Cleared potentially corrupted cache for $section',
        );
      } catch (clearError) {
        print('[TopStoriesLocal] Failed to clear corrupted cache: $clearError');
      }

      return Left(CacheFailure('Failed to get cached data: $e'));
    }
  }

  List<ArticleCacheModel>? _convertToArticleCacheList(dynamic data) {
    try {
      if (data == null) return null;

      if (data is List<ArticleCacheModel>) {
        return data;
      }

      if (data is List) {
        final List<ArticleCacheModel> result = [];
        for (final item in data) {
          try {
            if (item is ArticleCacheModel) {
              result.add(item);
            }
          } catch (e) {
            print('[TopStoriesLocal] Error converting cache item: $e');
            continue;
          }
        }
        return result;
      }

      return null;
    } catch (e) {
      print('[TopStoriesLocal] Error in _convertToArticleCacheList: $e');
      return null;
    }
  }

  @override
  Future<bool> cacheTopStories(
    String section,
    List<ArticleModel> articles,
  ) async {
    try {
      await _ensureInitialized();

      print(
        '[TopStoriesLocal] Caching ${articles.length} articles for section: $section',
      );

      // Process articles and cache media in background
      _cacheArticlesAndMediaInBackground(section, articles);

      return true;
    } catch (e) {
      print('[TopStoriesLocal] Failed to cache articles: $e');
      return false;
    }
  }

  Future<void> _cacheArticlesAndMediaInBackground(
    String section,
    List<ArticleModel> articles,
  ) async {
    try {
      final processedArticles = <ArticleCacheModel>[];

      for (final article in articles) {
        try {
          ArticleModel processedArticle = article;

          // Process multimedia
          if (article.multimedia?.isNotEmpty == true) {
            final processedMultimedia = <MultimediaModel>[];

            for (final media in article.multimedia!) {
              final mediaModel = media as MultimediaModel;

              // Check if already cached
              String? localPath;
              if (mediaModel.url != null) {
                localPath = _mediaCache.getCachedPath(mediaModel.url!);

                // If not cached, start background download
                if (localPath == null ||
                    !_mediaCache.isCached(mediaModel.url!)) {
                  _mediaCache
                      .cacheMedia(mediaModel.url!)
                      .then((cachedPath) {
                        if (cachedPath != null) {
                          print(
                            '[TopStoriesLocal] Media cached: ${mediaModel.url}',
                          );
                        }
                      })
                      .catchError((e) {
                        print('[TopStoriesLocal] Media cache failed: $e');
                      });
                }
              }

              processedMultimedia.add(
                mediaModel.copyWithCache(
                  localPath: localPath,
                  cachedAt: DateTime.now(),
                ),
              );
            }

            processedArticle = ArticleModel(
              section: article.section,
              subsection: article.subsection,
              title: article.title,
              abstract: article.abstract,
              url: article.url,
              uri: article.uri,
              byline: article.byline,
              itemType: article.itemType,
              updatedDate: article.updatedDate,
              createdDate: article.createdDate,
              publishedDate: article.publishedDate,
              desFacet: article.desFacet,
              orgFacet: article.orgFacet,
              perFacet: article.perFacet,
              geoFacet: article.geoFacet,
              multimedia: processedMultimedia,
            );
          }

          final cacheModel = ArticleCacheModel.fromArticleModel(
            processedArticle,
          );
          processedArticles.add(cacheModel);
        } catch (e) {
          print('[TopStoriesLocal] Error processing article for cache: $e');
          continue;
        }
      }

      // Cache articles
      await _articlesCache.put(section, processedArticles);
      print(
        '[TopStoriesLocal] Cached ${processedArticles.length} articles for section: $section',
      );
    } catch (e) {
      print('[TopStoriesLocal] Background caching failed: $e');
    }
  }

  @override
  Future<bool> isCacheExpired(String section) async {
    try {
      await _ensureInitialized();
      return await _articlesCache.isExpired(section, _cacheExpiry);
    } catch (e) {
      return true;
    }
  }

  @override
  Future<bool> hasCache(String section) async {
    try {
      await _ensureInitialized();
      final exists = await _articlesCache.exists(section);

      if (exists) {
        // Verify cache is actually loadable
        final data = await _articlesCache.get(section);
        final articles = _convertToArticleCacheList(data);
        return articles != null && articles.isNotEmpty;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearCache() async {
    try {
      await _ensureInitialized();
      await _articlesCache.clear();
      await _mediaCache.clearCache();
      print('[TopStoriesLocal] Cache cleared successfully');
      return true;
    } catch (e) {
      print('[TopStoriesLocal] Error clearing cache: $e');
      return false;
    }
  }

  Future<void> performMaintenance() async {
    try {
      await _ensureInitialized();

      print('[TopStoriesLocal] Starting maintenance...');

      // Cleanup old articles
      await _articlesCache.cleanup(Duration(days: 7));

      // Cleanup old media and sync registry
      await _mediaCache.cleanup();
      await _mediaCache.syncCacheRegistry();

      print('[TopStoriesLocal] Maintenance completed');
    } catch (e) {
      print('[TopStoriesLocal] Maintenance failed: $e');
    }
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      await _ensureInitialized();

      final articlesCacheSize = await _articlesCache.size();
      final mediaStats = await _mediaCache.getCacheStats();

      return {
        'articles': {
          'count': articlesCacheSize,
          'sections': await _articlesCache.getAllKeys(),
        },
        'media': mediaStats,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
