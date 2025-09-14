// shared_preference_local_data_source.dart
import 'package:packages/core/service/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  // Private constructor
  SharedPreferenceManager._();

  // Singleton instance
  static SharedPreferenceManager? _instance;

  // Shared Preferences instance
  static late SharedPreferences _sharedPreferences;

  /// Method to get the singleton instance
  static Future<SharedPreferenceManager> getInstance() async {
    // Create instance if it doesn't exist
    _instance ??= SharedPreferenceManager._();

    // Initialize shared preferences if not already initialized
    _sharedPreferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  /// Save any type of data to SharedPreferences
  Future<void> saveData(String key, dynamic value) async {
    try {
      if (value is String) {
        await _sharedPreferences.setString(key, value);
      } else if (value is int) {
        await _sharedPreferences.setInt(key, value);
      } else if (value is double) {
        await _sharedPreferences.setDouble(key, value);
      } else if (value is bool) {
        await _sharedPreferences.setBool(key, value);
      } else if (value is List<String>) {
        await _sharedPreferences.setStringList(key, value);
      } else {
        throw Exception("Unsupported type: ${value.runtimeType}");
      }
      printS("[SharedPreferenceManager] saveData: [$key: $value]");
    } catch (e) {
      printE("[SharedPreferenceManager] saveData: [$key: $value] - Error: $e");
      rethrow;
    }
  }

  /// Get data of any type from SharedPreferences
  Future<dynamic> getData(String key) async {
    try {
      final dynamic value = _sharedPreferences.get(key);
      printS("[SharedPreferenceManager] getData: [$key: $value]");
      return value;
    } catch (e) {
      printE("[SharedPreferenceManager] getData: [$key] - Error: $e");
      return null;
    }
  }

  /// Get data with specific type or default value
  T? getDataTyped<T>(String key) {
    try {
      if (!_sharedPreferences.containsKey(key)) {
        return null;
      }

      final dynamic value = _sharedPreferences.get(key);
      if (value is T) {
        return value;
      }
      return null;
    } catch (e) {
      printE("[SharedPreferenceManager] getDataTyped<$T>: [$key] - Error: $e");
      return null;
    }
  }

  /// Get data with specific type or return default value if not found or type mismatch
  T getDataWithDefault<T>(String key, T defaultValue) {
    return getDataTyped<T>(key) ?? defaultValue;
  }

  /// Type-specific getters for convenience
  String? getString(String key) => getDataTyped<String>(key);
  int? getInt(String key) => getDataTyped<int>(key);
  double? getDouble(String key) => getDataTyped<double>(key);
  bool? getBool(String key) => getDataTyped<bool>(key);
  List<String>? getStringList(String key) => getDataTyped<List<String>>(key);

  /// Type-specific getters with default values
  String getStringWithDefault(String key, String defaultValue) =>
      getString(key) ?? defaultValue;

  int getIntWithDefault(String key, int defaultValue) =>
      getInt(key) ?? defaultValue;

  double getDoubleWithDefault(String key, double defaultValue) =>
      getDouble(key) ?? defaultValue;

  bool getBoolWithDefault(String key, bool defaultValue) =>
      getBool(key) ?? defaultValue;

  List<String> getStringListWithDefault(
    String key,
    List<String> defaultValue,
  ) => getStringList(key) ?? defaultValue;

  /// Remove a specific key-value pair
  Future<void> removeData(String key) async {
    try {
      await _sharedPreferences.remove(key);
      printS("[SharedPreferenceManager] removeData: [$key]");
    } catch (e) {
      printE("[SharedPreferenceManager] removeData: [$key] - Error: $e");
      rethrow;
    }
  }

  /// Clear all data in SharedPreferences
  Future<void> clearData() async {
    try {
      await _sharedPreferences.clear();
      printS("[SharedPreferenceManager] clearData");
    } catch (e) {
      printE("[SharedPreferenceManager] clearData - Error: $e");
      rethrow;
    }
  }

  /// Update existing data
  Future<void> updateData(String key, dynamic newValue) async {
    try {
      if (_sharedPreferences.containsKey(key)) {
        await saveData(key, newValue);
        printS("[SharedPreferenceManager] updateData: [$key: $newValue]");
      } else {
        final error = "Key not found: $key";
        printE("[SharedPreferenceManager] updateData: $error");
        throw Exception(error);
      }
    } catch (e) {
      printE(
        "[SharedPreferenceManager] updateData: [$key: $newValue] - Error: $e",
      );
      rethrow;
    }
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _sharedPreferences.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return _sharedPreferences.getKeys();
  }

  /// Reload shared preferences from disk
  Future<void> reload() async {
    try {
      await _sharedPreferences.reload();
      printS("[SharedPreferenceManager] reload");
    } catch (e) {
      printE("[SharedPreferenceManager] reload - Error: $e");
      rethrow;
    }
  }
}
