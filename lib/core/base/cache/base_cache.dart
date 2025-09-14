import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

abstract class BaseCache<T> {
  Future<T?> get(String key);
  Future<bool> put(String key, T data);
  Future<bool> remove(String key);
  Future<bool> clear();
  Future<bool> exists(String key);
  Future<DateTime?> getTimestamp(String key);
  Future<bool> isExpired(String key, Duration maxAge);
  Future<List<String>> getAllKeys();
  Future<int> size();
  Future<void> close();
}

class HiveCache<T> implements BaseCache<T> {
  final String boxName;
  final String timestampBoxName;
  final void Function(String)? onError;
  final Duration? autoCleanupInterval;
  final Duration? defaultMaxAge;
  
  Box<T>? _dataBox;
  Box<int>? _timestampBox;
  bool _isInitialized = false;
  Timer? _cleanupTimer;

  HiveCache({
    required this.boxName,
    this.onError,
    this.autoCleanupInterval,
    this.defaultMaxAge,
  }) : timestampBoxName = '${boxName}_timestamps';

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      try {
        _dataBox = await Hive.openBox<T>(boxName);
        _timestampBox = await Hive.openBox<int>(timestampBoxName);
        _isInitialized = true;
        _startAutoCleanup();
      } catch (e) {
        _handleError('Initialization failed: $e');
        rethrow;
      }
    }
  }

  void _startAutoCleanup() {
    if (autoCleanupInterval != null && defaultMaxAge != null) {
      _cleanupTimer?.cancel();
      _cleanupTimer = Timer.periodic(autoCleanupInterval!, (timer) {
        _performAutoCleanup();
      });
    }
  }

  Future<void> _performAutoCleanup() async {
    try {
      if (defaultMaxAge != null) {
        final removed = await cleanup(defaultMaxAge!);
        if (removed > 0) {
          _handleError('Auto cleanup removed $removed expired entries');
        }
      }
    } catch (e) {
      _handleError('Auto cleanup failed: $e');
    }
  }

  @override
  Future<T?> get(String key) async {
    try {
      await _ensureInitialized();
      return _dataBox?.get(key);
    } catch (e) {
      _handleError('Get failed for key $key: $e');
      return null;
    }
  }

  @override
  Future<bool> put(String key, T data) async {
    try {
      await _ensureInitialized();
      await _dataBox?.put(key, data);
      await _timestampBox?.put(key, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      _handleError('Put failed for key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await _ensureInitialized();
      await _dataBox?.delete(key);
      await _timestampBox?.delete(key);
      return true;
    } catch (e) {
      _handleError('Remove failed for key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      await _ensureInitialized();
      await _dataBox?.clear();
      await _timestampBox?.clear();
      return true;
    } catch (e) {
      _handleError('Clear failed: $e');
      return false;
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      await _ensureInitialized();
      return _dataBox?.containsKey(key) ?? false;
    } catch (e) {
      _handleError('Exists check failed for key $key: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getTimestamp(String key) async {
    try {
      await _ensureInitialized();
      final timestamp = _timestampBox?.get(key);
      return timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
    } catch (e) {
      _handleError('Get timestamp failed for key $key: $e');
      return null;
    }
  }

  @override
  Future<bool> isExpired(String key, Duration maxAge) async {
    try {
      final timestamp = await getTimestamp(key);
      if (timestamp == null) return true;
      return DateTime.now().difference(timestamp) > maxAge;
    } catch (e) {
      _handleError('Check expiry failed for key $key: $e');
      return true;
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      await _ensureInitialized();
      return _dataBox?.keys.cast<String>().toList() ?? [];
    } catch (e) {
      _handleError('Get all keys failed: $e');
      return [];
    }
  }

  @override
  Future<int> size() async {
    try {
      await _ensureInitialized();
      return _dataBox?.length ?? 0;
    } catch (e) {
      _handleError('Get size failed: $e');
      return 0;
    }
  }

  @override
  Future<void> close() async {
    try {
      _cleanupTimer?.cancel();
      _cleanupTimer = null;
      await _dataBox?.close();
      await _timestampBox?.close();
      _isInitialized = false;
    } catch (e) {
      _handleError('Close failed: $e');
    }
  }

  Future<int> cleanup(Duration maxAge) async {
    try {
      await _ensureInitialized();
      final keys = await getAllKeys();
      int removedCount = 0;
      for (final key in keys) {
        if (await isExpired(key, maxAge)) {
          await remove(key);
          removedCount++;
        }
      }
      return removedCount;
    } catch (e) {
      _handleError('Cleanup failed: $e');
      return 0;
    }
  }

  void _handleError(String message) {
    if (onError != null) {
      onError!(message);
    } else {
      print('[HiveCache] $message');
    }
  }
}

class CacheFactory {
  static final Map<String, HiveCache> _instances = {};
  static bool _isHiveInitialized = false;

  static Future<void> initHive() async {
    if (!_isHiveInitialized) {
      await Hive.initFlutter();
      _isHiveInitialized = true;
    }
  }

  static HiveCache<T> getCache<T>(
    String name, {
    void Function(String)? onError,
    Duration? autoCleanupInterval,
    Duration? defaultMaxAge,
  }) {
    final key = '${name}_${T.toString()}';
    if (!_instances.containsKey(key)) {
      _instances[key] = HiveCache<T>(
        boxName: name,
        onError: onError,
        autoCleanupInterval: autoCleanupInterval,
        defaultMaxAge: defaultMaxAge,
      );
    }
    return _instances[key] as HiveCache<T>;
  }

  static Future<void> cleanupAll(Duration maxAge) async {
    for (final cache in _instances.values) {
      await cache.cleanup(maxAge);
    }
  }

  static Future<void> clearAll() async {
    for (final cache in _instances.values) {
      await cache.clear();
    }
  }

  static Future<void> closeAll() async {
    for (final cache in _instances.values) {
      await cache.close();
    }
    _instances.clear();
  }

  static Future<Map<String, int>> getCacheSizes() async {
    final sizes = <String, int>{};
    for (final entry in _instances.entries) {
      sizes[entry.key] = await entry.value.size();
    }
    return sizes;
  }
}