import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract class BaseMediaCache {
  Future<void> initialize();
  Future<String?> cacheMedia(String url, {Function(int, int)? onProgress});
  String? getCachedPath(String url);
  bool isCached(String url);
  Future<bool> clearCache();
  Future<void> cleanup();
  Future<void> syncCacheRegistry();
}

class MediaCacheManager implements BaseMediaCache {
  static final MediaCacheManager _instance = MediaCacheManager._internal();
  static MediaCacheManager get instance => _instance;
  MediaCacheManager._internal();

  static const String _cacheDirectory = 'news_media_cache';
  static const String _registryFileName = 'media_registry.json';
  static const Duration _defaultCacheExpiry = Duration(days: 30);

  Dio? _dio;
  Directory? _cacheDir;
  final Map<String, String> _cacheRegistry = {};
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('[MediaCache] Initializing...');

      _dio = Dio();
      _dio!.options.connectTimeout = Duration(seconds: 30);
      _dio!.options.receiveTimeout = Duration(seconds: 60);

      // FIX: Sử dụng getApplicationDocumentsDirectory() cho stable storage
      final documentsDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory(path.join(documentsDir.path, _cacheDirectory));

      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
        print('[MediaCache] Created cache directory: ${_cacheDir!.path}');
      }

      // FIX: Load registry và rebuild từ filesystem
      await _loadAndRebuildRegistry();

      _isInitialized = true;
      print(
        '[MediaCache] Initialized successfully. Registry has ${_cacheRegistry.length} entries',
      );
    } catch (e) {
      print('[MediaCache] Initialization failed: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // FIX: Load registry và rebuild từ filesystem thực tế
  Future<void> _loadAndRebuildRegistry() async {
    try {
      if (_cacheDir == null) return;

      // Step 1: Load existing registry
      await _loadExistingRegistry();

      // Step 2: Rebuild registry từ filesystem thực tế
      await _rebuildRegistryFromFilesystem();

      // Step 3: Save updated registry
      await _saveRegistry();

      print('[MediaCache] Registry loaded and rebuilt successfully');
    } catch (e) {
      print('[MediaCache] Failed to load and rebuild registry: $e');
      _cacheRegistry.clear();
    }
  }

  Future<void> _loadExistingRegistry() async {
    try {
      final registryFile = File(path.join(_cacheDir!.path, _registryFileName));

      if (await registryFile.exists()) {
        final content = await registryFile.readAsString();
        final Map<String, dynamic> registryData = json.decode(content);

        _cacheRegistry.clear();
        registryData.forEach((key, value) {
          if (value is String) {
            _cacheRegistry[key] = value;
          }
        });

        print(
          '[MediaCache] Loaded ${_cacheRegistry.length} entries from existing registry',
        );
      }
    } catch (e) {
      print('[MediaCache] Failed to load existing registry: $e');
      _cacheRegistry.clear();
    }
  }

  // FIX: Rebuild registry từ files thực tế trong thư mục
  Future<void> _rebuildRegistryFromFilesystem() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) return;

      print('[MediaCache] Rebuilding registry from filesystem...');

      final Map<String, String> newRegistry = {};
      final Map<String, String> fileHashToPath = {};

      // Scan tất cả files trong cache directory
      await for (final entity in _cacheDir!.list()) {
        if (entity is File &&
            !entity.path.endsWith(_registryFileName) &&
            await entity.length() > 0) {
          final fileName = path.basename(entity.path);
          final hash = _extractHashFromFileName(fileName);

          if (hash != null) {
            fileHashToPath[hash] = entity.path;
          }
        }
      }

      // Match existing registry entries với files thực tế
      for (final entry in _cacheRegistry.entries) {
        final url = entry.key;
        final oldPath = entry.value;

        // Generate expected hash for this URL
        final expectedHash = _generateHashFromUrl(url);

        // Check if file exists tại path cũ
        if (await File(oldPath).exists() && await File(oldPath).length() > 0) {
          newRegistry[url] = oldPath;
          fileHashToPath.remove(expectedHash); // Remove từ unmatched list
        }
        // Check if file exists với hash trong filesystem
        else if (fileHashToPath.containsKey(expectedHash)) {
          final newPath = fileHashToPath[expectedHash]!;
          newRegistry[url] = newPath;
          fileHashToPath.remove(expectedHash);
          print('[MediaCache] Remapped URL: $url -> $newPath');
        }
        // File không tồn tại, remove khỏi registry
        else {
          print(
            '[MediaCache] File not found for URL: $url (expected hash: $expectedHash)',
          );
        }
      }

      // Update registry
      _cacheRegistry.clear();
      _cacheRegistry.addAll(newRegistry);

      // Log unmatched files (có thể là orphaned files)
      if (fileHashToPath.isNotEmpty) {
        print(
          '[MediaCache] Found ${fileHashToPath.length} orphaned cache files',
        );
        for (final orphanPath in fileHashToPath.values) {
          print('[MediaCache] Orphaned file: $orphanPath');
        }
      }

      print(
        '[MediaCache] Registry rebuilt: ${_cacheRegistry.length} valid entries',
      );
    } catch (e) {
      print('[MediaCache] Failed to rebuild registry from filesystem: $e');
    }
  }

  String? _extractHashFromFileName(String fileName) {
    try {
      final nameWithoutExt = path.basenameWithoutExtension(fileName);
      // Hash có 20 characters (từ SHA256 substring)
      if (nameWithoutExt.length >= 20) {
        return nameWithoutExt.substring(0, 20);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _generateHashFromUrl(String url) {
    try {
      final bytes = utf8.encode(url);
      final digest = sha256.convert(bytes);
      return digest.toString().substring(0, 20);
    } catch (e) {
      return url.hashCode.toString();
    }
  }

  Future<void> _saveRegistry() async {
    try {
      if (_cacheDir == null) return;

      final registryFile = File(path.join(_cacheDir!.path, _registryFileName));
      final content = json.encode(_cacheRegistry);
      await registryFile.writeAsString(content);

      print(
        '[MediaCache] Saved registry with ${_cacheRegistry.length} entries',
      );
    } catch (e) {
      print('[MediaCache] Failed to save registry: $e');
    }
  }

  @override
  Future<void> syncCacheRegistry() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) return;

      print('[MediaCache] Syncing cache registry...');

      // FIX: Always rebuild từ filesystem khi sync
      await _rebuildRegistryFromFilesystem();
      await _saveRegistry();

      print(
        '[MediaCache] Registry sync completed. ${_cacheRegistry.length} valid entries',
      );
    } catch (e) {
      print('[MediaCache] Registry sync failed: $e');
    }
  }

  @override
  Future<String?> cacheMedia(
    String url, {
    Function(int, int)? onProgress,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      if (url.isEmpty) return null;

      // Check if already cached và file exists
      final existingPath = getCachedPath(url);
      if (existingPath != null) {
        final file = File(existingPath);
        if (await file.exists() && await file.length() > 0) {
          print('[MediaCache] Media already cached: $url');
          return existingPath;
        } else {
          // Remove invalid entry
          _cacheRegistry.remove(url);
          print('[MediaCache] Removed invalid cache entry for: $url');
        }
      }

      final fileName = _generateFileName(url);
      final filePath = path.join(_cacheDir!.path, fileName);

      print('[MediaCache] Downloading media: $url');

      final response = await _dio!.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
          responseType: ResponseType.bytes,
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; NewsApp/1.0)'},
        ),
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        if (await file.exists() && await file.length() > 0) {
          _cacheRegistry[url] = filePath;
          await _saveRegistry();

          print('[MediaCache] Successfully cached media: $url -> $filePath');
          return filePath;
        } else {
          print('[MediaCache] Downloaded file is empty or doesn\'t exist');
        }
      } else {
        print(
          '[MediaCache] Download failed with status: ${response.statusCode}',
        );
      }

      return null;
    } catch (e) {
      print('[MediaCache] Cache failed for $url: $e');

      // Clean up partial file
      try {
        final fileName = _generateFileName(url);
        final filePath = path.join(_cacheDir!.path, fileName);
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          print('[MediaCache] Cleaned up partial file: $filePath');
        }
      } catch (cleanupError) {
        print('[MediaCache] Failed to cleanup partial file: $cleanupError');
      }

      return null;
    }
  }

  String _generateFileName(String url) {
    try {
      final hash = _generateHashFromUrl(url);

      final uri = Uri.parse(url);
      final pathSegment =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      final extension = path.extension(pathSegment).toLowerCase();

      // Ensure we have a valid extension
      final validExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.bmp',
        '.svg',
      ];
      final finalExtension =
          validExtensions.contains(extension) ? extension : '.jpg';

      return '$hash$finalExtension';
    } catch (e) {
      print('[MediaCache] Failed to generate filename for $url: $e');
      return '${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
  }

  @override
  String? getCachedPath(String url) {
    if (url.isEmpty) return null;
    return _cacheRegistry[url];
  }

  @override
  bool isCached(String url) {
    final cachedPath = getCachedPath(url);
    if (cachedPath == null) return false;

    try {
      final file = File(cachedPath);
      return file.existsSync() && file.lengthSync() > 0;
    } catch (e) {
      // If we can't check the file, remove from registry
      _cacheRegistry.remove(url);
      return false;
    }
  }

  @override
  Future<bool> clearCache() async {
    try {
      print('[MediaCache] Clearing all cache...');

      if (_cacheDir != null && await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }

      _cacheRegistry.clear();
      await _saveRegistry();

      print('[MediaCache] Cache cleared successfully');
      return true;
    } catch (e) {
      print('[MediaCache] Failed to clear cache: $e');
      return false;
    }
  }

  @override
  Future<void> cleanup() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) return;

      print('[MediaCache] Starting cleanup of expired files...');

      final now = DateTime.now();
      final expiredFiles = <String>[];
      final toRemoveFromRegistry = <String>[];

      // Check each file in registry for expiry
      for (final entry in _cacheRegistry.entries) {
        final url = entry.key;
        final filePath = entry.value;

        try {
          final file = File(filePath);
          if (await file.exists()) {
            final stat = await file.stat();
            if (now.difference(stat.modified) > _defaultCacheExpiry) {
              expiredFiles.add(filePath);
              toRemoveFromRegistry.add(url);
            }
          } else {
            // File doesn't exist, remove from registry
            toRemoveFromRegistry.add(url);
          }
        } catch (e) {
          print('[MediaCache] Error checking file $filePath: $e');
          toRemoveFromRegistry.add(url);
        }
      }

      // Delete expired files
      for (final filePath in expiredFiles) {
        try {
          await File(filePath).delete();
          print('[MediaCache] Deleted expired file: $filePath');
        } catch (e) {
          print('[MediaCache] Failed to delete file $filePath: $e');
        }
      }

      // Remove from registry
      for (final url in toRemoveFromRegistry) {
        _cacheRegistry.remove(url);
      }

      if (toRemoveFromRegistry.isNotEmpty) {
        await _saveRegistry();
        print(
          '[MediaCache] Cleanup completed. Removed ${toRemoveFromRegistry.length} entries',
        );
      } else {
        print('[MediaCache] Cleanup completed. No expired files found');
      }
    } catch (e) {
      print('[MediaCache] Cleanup failed: $e');
    }
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) {
        return {
          'totalSize': 0,
          'fileCount': 0,
          'registryEntries': 0,
          'cacheDirectory': 'Not initialized',
        };
      }

      int totalSize = 0;
      int fileCount = 0;
      int validFiles = 0;

      // Count actual files in directory
      await for (final entity in _cacheDir!.list()) {
        if (entity is File &&
            entity.path != path.join(_cacheDir!.path, _registryFileName)) {
          try {
            final size = await entity.length();
            if (size > 0) {
              totalSize += size;
              fileCount++;
            }
          } catch (e) {
            print('[MediaCache] Error getting file size: $e');
          }
        }
      }

      // Count valid registry entries
      for (final filePath in _cacheRegistry.values) {
        try {
          final file = File(filePath);
          if (await file.exists() && await file.length() > 0) {
            validFiles++;
          }
        } catch (e) {
          // Ignore file access errors in stats
        }
      }

      return {
        'totalSize': totalSize,
        'totalSizeFormatted': _formatBytes(totalSize),
        'fileCount': fileCount,
        'registryEntries': _cacheRegistry.length,
        'validRegistryEntries': validFiles,
        'cacheDirectory': _cacheDir!.path,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
