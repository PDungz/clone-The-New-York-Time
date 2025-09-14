import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/core/base/cache/base_cache.dart';
import 'package:news_app/core/base/cache/base_media_cache.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/feature/home/data/data_source/local/top_stories_local_data_source.dart';
import 'package:news_app/feature/home/data/model/article_cache_model.dart';

class CacheInitializationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[CacheInit] Starting cache system initialization...');

      // 1. Initialize base cache system
      await CacheFactory.initHive();

      // 2. Register Hive adapters
      await _registerHiveAdapters();

      // 3. Initialize media cache
      await _initializeMediaCache();

      // 4. Perform startup maintenance
      await _performStartupMaintenance();

      _isInitialized = true;
      print('[CacheInit] Cache system initialized successfully');
    } catch (e) {
      print('[CacheInit] Failed to initialize cache system: $e');
      rethrow;
    }
  }

  static Future<void> _registerHiveAdapters() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ArticleCacheModelAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(MultimediaCacheModelAdapter());
    }
  }

  static Future<void> _initializeMediaCache() async {
    try {
      await MediaCacheManager.instance.initialize();
      print('[CacheInit] Media cache initialized');
    } catch (e) {
      print('[CacheInit] Media cache init failed: $e');
      // Don't rethrow, app can still work without media cache
    }
  }

  static Future<void> _performStartupMaintenance() async {
    try {
      // Sync media cache registry on startup - quan trọng cho việc rebuild registry
      await MediaCacheManager.instance.syncCacheRegistry();

      // Cleanup old entries (older than 30 days)
      await MediaCacheManager.instance.cleanup();

      print('[CacheInit] Startup maintenance completed');
    } catch (e) {
      print('[CacheInit] Startup maintenance failed: $e');
    }
  }

  static Future<void> performMaintenance() async {
    try {
      print('[CacheInit] Starting global maintenance...');

      await CacheFactory.cleanupAll(const Duration(days: 30));
      await MediaCacheManager.instance.cleanup();
      await MediaCacheManager.instance.syncCacheRegistry();

      print('[CacheInit] Global maintenance completed');
    } catch (e) {
      print('[CacheInit] Global maintenance failed: $e');
    }
  }

  // ============= CACHE MANAGEMENT METHODS =============

  /// Clear tất cả cache - method chính để sử dụng
  static Future<bool> clearAllCaches() async {
    try {
      print('[CacheInit] Starting to clear all cache...');

      // 1. Clear specific cache instances first
      await _clearSpecificCaches();

      // 2. Clear base cache systems
      await CacheFactory.clearAll();
      await MediaCacheManager.instance.clearCache();

      // 3. Verify clear thành công
      final stats = await getCacheStats();
      print('[CacheInit] All cache cleared. New stats: $stats');

      return true;
    } catch (e) {
      print('[CacheInit] Failed to clear all cache: $e');
      return false;
    }
  }

  /// Clear specific caches (backup method)
  static Future<void> _clearSpecificCaches() async {
    try {
      // Clear TopStories cache if available
      if (getIt.isRegistered<TopStoriesLocalDataSource>()) {
        final localDataSource = getIt<TopStoriesLocalDataSource>();
        await localDataSource.clearCache();
      }

      print('[CacheInit] Specific caches cleared');
    } catch (e) {
      print('[CacheInit] Error clearing specific caches: $e');
    }
  }

  /// Clear chỉ articles cache (giữ lại media)
  static Future<bool> clearArticlesCache() async {
    try {
      print('[CacheInit] Clearing articles cache only...');

      // Clear TopStories cache
      if (getIt.isRegistered<TopStoriesLocalDataSource>()) {
        final localDataSource = getIt<TopStoriesLocalDataSource>();
        await localDataSource.clearCache();
      }

      // Clear all Hive caches (articles data)
      await CacheFactory.clearAll();

      print('[CacheInit] Articles cache cleared successfully');
      return true;
    } catch (e) {
      print('[CacheInit] Failed to clear articles cache: $e');
      return false;
    }
  }

  /// Clear chỉ media cache (giữ lại articles)
  static Future<bool> clearMediaCache() async {
    try {
      print('[CacheInit] Clearing media cache only...');

      final success = await MediaCacheManager.instance.clearCache();

      print('[CacheInit] Media cache cleared: $success');
      return success;
    } catch (e) {
      print('[CacheInit] Failed to clear media cache: $e');
      return false;
    }
  }

  /// Clear cache cho section cụ thể
  static Future<bool> clearSectionCache(String section) async {
    try {
      print('[CacheInit] Clearing cache for section: $section');

      // Access articles cache để clear specific section
      final articlesCache = CacheFactory.getCache<dynamic>('topstories_cache');
      await articlesCache.remove(section);

      print('[CacheInit] Section cache cleared: $section');
      return true;
    } catch (e) {
      print('[CacheInit] Failed to clear section cache: $e');
      return false;
    }
  }

  /// Get comprehensive cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheSizes = await CacheFactory.getCacheSizes();
      final mediaStats = await MediaCacheManager.instance.getCacheStats();

      // Add local data source stats if available
      Map<String, dynamic>? localStats;
      if (getIt.isRegistered<TopStoriesLocalDataSource>()) {
        try {
          final localDataSource = getIt<TopStoriesLocalDataSource>();
          if (localDataSource is TopStoriesLocalDataSourceImpl) {
            localStats = await localDataSource.getCacheStats();
          }
        } catch (e) {
          print('[CacheInit] Error getting local stats: $e');
        }
      }

      return {
        'initialized': _isInitialized,
        'cacheSizes': cacheSizes,
        'mediaStats': mediaStats,
        'localDataSource': localStats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'initialized': _isInitialized,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get cache size in bytes
  static Future<int> getCacheSizeInBytes() async {
    try {
      final mediaStats = await MediaCacheManager.instance.getCacheStats();
      final totalSize = mediaStats['totalSize'] as int? ?? 0;

      // TODO: Add articles cache size calculation if needed
      // Articles cache size is usually much smaller than media

      return totalSize;
    } catch (e) {
      print('[CacheInit] Failed to get cache size: $e');
      return 0;
    }
  }

  /// Format cache size for display
  static Future<String> getFormattedCacheSize() async {
    try {
      final mediaStats = await MediaCacheManager.instance.getCacheStats();
      return mediaStats['totalSizeFormatted'] as String? ?? '0 B';
    } catch (e) {
      return '0 B';
    }
  }

  /// Check if cache is empty
  static Future<bool> isCacheEmpty() async {
    try {
      final stats = await getCacheStats();

      final mediaStats = stats['mediaStats'] as Map<String, dynamic>?;
      final cacheStats = stats['cacheSizes'] as Map<String, dynamic>?;

      final mediaEmpty = (mediaStats?['fileCount'] as int? ?? 0) == 0;
      final articlesEmpty =
          (cacheStats?.values.fold<int>(
                0,
                (sum, size) => sum + (size as int? ?? 0),
              ) ??
              0) ==
          0;

      return mediaEmpty && articlesEmpty;
    } catch (e) {
      return true;
    }
  }

  /// Cleanup expired cache (không clear tất cả)
  static Future<void> cleanupExpiredCache() async {
    try {
      print('[CacheInit] Cleaning up expired cache...');

      // Cleanup expired articles (7 days)
      await CacheFactory.cleanupAll(const Duration(days: 7));

      // Cleanup expired media (30 days)
      await MediaCacheManager.instance.cleanup();

      print('[CacheInit] Expired cache cleanup completed');
    } catch (e) {
      print('[CacheInit] Expired cache cleanup failed: $e');
    }
  }

  /// Emergency cache reset (khi có lỗi corruption)
  static Future<bool> emergencyCacheReset() async {
    try {
      print('[CacheInit] Performing emergency cache reset...');

      // 1. Force close all cache connections
      await CacheFactory.closeAll();

      // 2. Clear all cache
      await clearAllCaches();

      // 3. Reset initialization flag
      _isInitialized = false;

      // 4. Reinitialize cache system
      await initialize();

      print('[CacheInit] Emergency cache reset completed');
      return true;
    } catch (e) {
      print('[CacheInit] Emergency cache reset failed: $e');
      return false;
    }
  }

  /// Get cache status info for debugging
  static Future<Map<String, dynamic>> getCacheHealthCheck() async {
    try {
      // ignore: unused_local_variable
      final stats = await getCacheStats();
      final isEmpty = await isCacheEmpty();
      final sizeFormatted = await getFormattedCacheSize();

      return {
        'isInitialized': _isInitialized,
        'isEmpty': isEmpty,
        'totalSizeFormatted': sizeFormatted,
        'mediaHealth': await _checkMediaCacheHealth(),
        'articlesHealth': await _checkArticlesCacheHealth(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isInitialized': _isInitialized,
        'lastCheck': DateTime.now().toIso8601String(),
      };
    }
  }

  static Future<Map<String, dynamic>> _checkMediaCacheHealth() async {
    try {
      final stats = await MediaCacheManager.instance.getCacheStats();
      final fileCount = stats['fileCount'] as int? ?? 0;
      final registryEntries = stats['registryEntries'] as int? ?? 0;
      final validEntries = stats['validRegistryEntries'] as int? ?? 0;

      return {
        'status': 'healthy',
        'fileCount': fileCount,
        'registryEntries': registryEntries,
        'validEntries': validEntries,
        'healthScore':
            validEntries / (registryEntries > 0 ? registryEntries : 1),
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _checkArticlesCacheHealth() async {
    try {
      final cacheSizes = await CacheFactory.getCacheSizes();
      final totalEntries = cacheSizes.values.fold<int>(
        0,
        (sum, size) => sum + (size as int? ?? 0),
      );

      return {
        'status': 'healthy',
        'totalEntries': totalEntries,
        'cacheBoxes': cacheSizes.keys.length,
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }
}
