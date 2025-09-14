import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:packages/core/network/network_info.dart';
import 'package:packages/core/service/logger_service.dart';
import 'package:news_app/feature/home/data/data_source/local/top_stories_local_data_source.dart';
import 'package:news_app/feature/home/data/data_source/remote/topstories_remote_data_source.dart';
import 'package:news_app/feature/home/data/model/article_model.dart';
import 'package:news_app/feature/home/data/model/multimedia_model.dart';
import 'package:news_app/feature/home/domain/entities/article.dart';
import 'package:news_app/feature/home/domain/repository/topstories_repository.dart';

class TopStoriesRepositoryImpl extends TopStoriesRepository {
  final TopStoriesRemoteDataSource remoteDataSource;
  final TopStoriesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TopStoriesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Article>>> getTopStories({
    required String section,
  }) async {
    try {
      final bool isConnected = await networkInfo.hasInternetAccess();
      printI('[TopStoriesRepo] Network status: $isConnected');

      if (isConnected) {
        // ONLINE STRATEGY: API First, Cache as backup
        return await _getTopStoriesOnline(section);
      } else {
        // OFFLINE STRATEGY: Cache only
        return await _getTopStoriesOffline(section);
      }
    } catch (e) {
      printE('[TopStoriesRepo] Unexpected error: $e');

      // Emergency fallback to cache
      final fallbackResult = await _getTopStoriesOffline(section);
      if (fallbackResult.isRight()) {
        printI('[TopStoriesRepo] Emergency fallback to cache successful');
        return fallbackResult;
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  // Online strategy: Always fetch fresh data, cache as backup
  Future<Either<Failure, List<Article>>> _getTopStoriesOnline(
    String section,
  ) async {
    try {
      printI('[TopStoriesRepo] Online mode: Fetching fresh data from API');

      final remoteResult = await remoteDataSource.getTopStories(
        section: section,
      );

      return remoteResult.fold(
        (failure) async {
          printE('[TopStoriesRepo] API failed: ${failure.message}');

          // API failed, try cache as fallback
          final cacheResult = await _getTopStoriesOffline(section);
          if (cacheResult.isRight()) {
            printI('[TopStoriesRepo] Using cache as fallback for API failure');
            return cacheResult;
          }

          return Left(failure);
        },
        (articles) async {
          printI(
            '[TopStoriesRepo] API success: ${articles.length} articles received',
          );

          // FIX: Convert List<Article> to List<ArticleModel> for caching
          final articleModels = _convertToArticleModels(articles);

          // Cache new data in background (don't block response)
          _cacheArticlesInBackground(section, articleModels);

          return Right(articles);
        },
      );
    } catch (e) {
      printE('[TopStoriesRepo] Online fetch error: $e');

      // Try cache fallback
      final cacheResult = await _getTopStoriesOffline(section);
      if (cacheResult.isRight()) {
        return cacheResult;
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  // Offline strategy: Cache only
  Future<Either<Failure, List<Article>>> _getTopStoriesOffline(
    String section,
  ) async {
    try {
      printI('[TopStoriesRepo] Offline mode: Loading from cache');

      final bool hasCache = await localDataSource.hasCache(section);
      if (!hasCache) {
        return Left(
          NetworkFailure('No internet connection and no cached data available'),
        );
      }

      final cacheResult = await localDataSource.getCachedTopStories(section);
      return cacheResult.fold(
        (failure) {
          printE('[TopStoriesRepo] Cache load failed: ${failure.message}');
          return Left(
            NetworkFailure(
              'No internet connection and cached data is corrupted',
            ),
          );
        },
        (articleModels) {
          printI(
            '[TopStoriesRepo] Cache load successful: ${articleModels.length} articles',
          );

          // FIX: Convert List<ArticleModel> to List<Article> for domain layer
          final articles = _convertToArticles(articleModels);
          return Right(articles);
        },
      );
    } catch (e) {
      printE('[TopStoriesRepo] Offline fetch error: $e');
      return Left(CacheFailure('Failed to load cached data: $e'));
    }
  }

  // FIX: Convert List<Article> to List<ArticleModel>
  List<ArticleModel> _convertToArticleModels(List<Article> articles) {
    return articles.map((article) {
      if (article is ArticleModel) {
        return article;
      } else {
        // Convert Article to ArticleModel with multimedia conversion
        return ArticleModel(
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
          multimedia: _convertMultimediaList(article.multimedia),
        );
      }
    }).toList();
  }

  // FIX: Convert List<Multimedia>? to List<MultimediaModel>?
  List<MultimediaModel>? _convertMultimediaList(List<dynamic>? multimedia) {
    if (multimedia == null || multimedia.isEmpty) {
      return null;
    }

    try {
      return multimedia.map((media) {
        if (media is MultimediaModel) {
          return media;
        } else if (media is Map<String, dynamic>) {
          // Convert from JSON
          return MultimediaModel.fromJson(media);
        } else {
          // Convert from Multimedia entity to MultimediaModel
          return MultimediaModel(
            url: _getMediaProperty(media, 'url'),
            format: _getMediaProperty(media, 'format'),
            height: _getMediaProperty(media, 'height'),
            width: _getMediaProperty(media, 'width'),
            type: _getMediaProperty(media, 'type'),
            subtype: _getMediaProperty(media, 'subtype'),
            caption: _getMediaProperty(media, 'caption'),
            copyright: _getMediaProperty(media, 'copyright'),
            localPath: _getMediaProperty(media, 'localPath'),
            cachedAt: _getMediaProperty(media, 'cachedAt'),
          );
        }
      }).toList();
    } catch (e) {
      print('[TopStoriesRepo] Error converting multimedia: $e');
      return null;
    }
  }

  // Helper method to safely get properties from dynamic media object
  T? _getMediaProperty<T>(dynamic media, String property) {
    try {
      if (media == null) return null;

      // Try to access property using reflection-like approach
      switch (property) {
        case 'url':
          return (media as dynamic).url as T?;
        case 'format':
          return (media as dynamic).format as T?;
        case 'height':
          return (media as dynamic).height as T?;
        case 'width':
          return (media as dynamic).width as T?;
        case 'type':
          return (media as dynamic).type as T?;
        case 'subtype':
          return (media as dynamic).subtype as T?;
        case 'caption':
          return (media as dynamic).caption as T?;
        case 'copyright':
          return (media as dynamic).copyright as T?;
        case 'localPath':
          return (media as dynamic).localPath as T?;
        case 'cachedAt':
          return (media as dynamic).cachedAt as T?;
        default:
          return null;
      }
    } catch (e) {
      print('[TopStoriesRepo] Error getting property $property: $e');
      return null;
    }
  }

  // FIX: Convert List<ArticleModel> to List<Article>
  List<Article> _convertToArticles(List<ArticleModel> articleModels) {
    // ArticleModel extends Article, so this is safe
    return articleModels.cast<Article>();
  }

  // Background caching with proper type conversion
  void _cacheArticlesInBackground(
    String section,
    List<ArticleModel> articleModels,
  ) {
    localDataSource
        .cacheTopStories(section, articleModels)
        .then((success) {
          if (success) {
            printI(
              '[TopStoriesRepo] Background caching completed for $section',
            );
          } else {
            printW('[TopStoriesRepo] Background caching failed for $section');
          }
        })
        .catchError((e) {
          printE('[TopStoriesRepo] Background caching error: $e');
        });
  }

  // Manual refresh - always fetch fresh data
  Future<Either<Failure, List<Article>>> refreshTopStories({
    required String section,
  }) async {
    try {
      final bool isConnected = await networkInfo.hasInternetAccess();
      if (!isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      printI('[TopStoriesRepo] Manual refresh: Force fetching from API');

      final remoteResult = await remoteDataSource.getTopStories(
        section: section,
      );
      return remoteResult.fold((failure) => Left(failure), (articles) async {
        printI('[TopStoriesRepo] Manual refresh successful');

        // FIX: Convert and cache
        final articleModels = _convertToArticleModels(articles);
        await localDataSource.cacheTopStories(section, articleModels);

        return Right(articles);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Check if we have valid cached data
  Future<bool> hasCachedData(String section) async {
    try {
      final hasCache = await localDataSource.hasCache(section);
      if (!hasCache) return false;

      // Try to actually load cache to verify it's valid
      final result = await localDataSource.getCachedTopStories(section);
      return result.isRight();
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAllCache() async {
    return await localDataSource.clearCache();
  }

  Future<Either<Failure, ConnectivityInfo>> getNetworkInfo() async {
    try {
      final info = await (networkInfo as NetworkInfoImpl).getConnectivityInfo();
      return Right(info);
    } catch (e) {
      return Left(ServerFailure('Failed to get network info: $e'));
    }
  }
}
