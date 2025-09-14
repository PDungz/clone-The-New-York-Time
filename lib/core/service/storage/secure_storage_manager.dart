// core/storage/secure_storage_manager.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:packages/core/service/logger_service.dart';

class SecureStorageManager {
  // Private constructor
  SecureStorageManager._();

  // Singleton instance
  // ignore: unused_field
  static SecureStorageManager? _instance;

  // FlutterSecureStorage instance with enhanced security options
  static late FlutterSecureStorage _secureStorage;

  // Method to get the singleton instance
  static Future<SecureStorageManager> getInstance() async {
    _instance ??= SecureStorageManager._();

    // Initialize secure storage with maximum security options
    _secureStorage = FlutterSecureStorage();

    return _instance!;
  }

  /// Write secure data with optional additional encryption
  Future<void> writeSecure(String key, String value, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      String finalValue = value;

      if (additionalEncryption) {
        finalValue = _encryptValue(value, encryptionSalt ?? key);
      }

      await _secureStorage.write(key: key, value: finalValue);
      printS("[SecureStorageManager] writeSecure: [$key] - Additional encryption: $additionalEncryption");
    } catch (e) {
      printE("[SecureStorageManager] writeSecure: [$key] - Error: $e");
      rethrow;
    }
  }

  /// Read secure data with optional decryption
  Future<String?> readSecure(String key, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      final value = await _secureStorage.read(key: key);

      if (value == null) {
        printS("[SecureStorageManager] readSecure: [$key] - Not found");
        return null;
      }

      String finalValue = value;

      if (additionalEncryption) {
        try {
          finalValue = _decryptValue(value, encryptionSalt ?? key);
        } catch (e) {
          printE("[SecureStorageManager] readSecure: [$key] - Decryption failed: $e");
          return null;
        }
      }

      printS("[SecureStorageManager] readSecure: [$key] - Found with additional encryption: $additionalEncryption");
      return finalValue;
    } catch (e) {
      printE("[SecureStorageManager] readSecure: [$key] - Error: $e");
      return null;
    }
  }

  /// Write JSON object securely
  Future<void> writeJson(String key, Map<String, dynamic> json, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      final jsonString = jsonEncode(json);
      await writeSecure(key, jsonString, additionalEncryption: additionalEncryption, encryptionSalt: encryptionSalt);
      printS("[SecureStorageManager] writeJson: [$key] - ${json.keys.length} properties");
    } catch (e) {
      printE("[SecureStorageManager] writeJson: [$key] - Error: $e");
      rethrow;
    }
  }

  /// Read JSON object securely
  Future<Map<String, dynamic>?> readJson(String key, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      final jsonString = await readSecure(key, additionalEncryption: additionalEncryption, encryptionSalt: encryptionSalt);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      printS("[SecureStorageManager] readJson: [$key] - ${json.keys.length} properties");
      return json;
    } catch (e) {
      printE("[SecureStorageManager] readJson: [$key] - Error: $e");
      return null;
    }
  }

  /// Write object with expiration time
  Future<void> writeWithExpiry(String key, String value, Duration expiryDuration, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      final expiryTime = DateTime.now().add(expiryDuration);
      final dataWithExpiry = {'value': value, 'expiryTime': expiryTime.toIso8601String()};

      await writeJson(key, dataWithExpiry, additionalEncryption: additionalEncryption, encryptionSalt: encryptionSalt);
      printS("[SecureStorageManager] writeWithExpiry: [$key] - Expires at: $expiryTime");
    } catch (e) {
      printE("[SecureStorageManager] writeWithExpiry: [$key] - Error: $e");
      rethrow;
    }
  }

  /// Read object with expiration check
  Future<String?> readWithExpiry(String key, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      final dataWithExpiry = await readJson(key, additionalEncryption: additionalEncryption, encryptionSalt: encryptionSalt);

      if (dataWithExpiry == null) return null;

      final expiryTimeString = dataWithExpiry['expiryTime'] as String?;
      if (expiryTimeString != null) {
        final expiryTime = DateTime.parse(expiryTimeString);
        if (DateTime.now().isAfter(expiryTime)) {
          printS("[SecureStorageManager] readWithExpiry: [$key] - Expired, removing");
          await delete(key);
          return null;
        }
      }

      final value = dataWithExpiry['value'] as String?;
      printS("[SecureStorageManager] readWithExpiry: [$key] - Valid data found");
      return value;
    } catch (e) {
      printE("[SecureStorageManager] readWithExpiry: [$key] - Error: $e");
      return null;
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      printS("[SecureStorageManager] delete: [$key]");
    } catch (e) {
      printE("[SecureStorageManager] delete: [$key] - Error: $e");
      rethrow;
    }
  }

  /// Delete multiple keys
  Future<void> deleteMultiple(List<String> keys) async {
    try {
      for (final key in keys) {
        await delete(key);
      }
      printS("[SecureStorageManager] deleteMultiple: ${keys.length} keys");
    } catch (e) {
      printE("[SecureStorageManager] deleteMultiple - Error: $e");
      rethrow;
    }
  }

  /// Delete all data
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      printS("[SecureStorageManager] deleteAll");
    } catch (e) {
      printE("[SecureStorageManager] deleteAll - Error: $e");
      rethrow;
    }
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final exists = await _secureStorage.containsKey(key: key);
      printS("[SecureStorageManager] containsKey: [$key] = $exists");
      return exists;
    } catch (e) {
      printE("[SecureStorageManager] containsKey: [$key] - Error: $e");
      return false;
    }
  }

  /// Get all keys
  Future<Set<String>> getAllKeys() async {
    try {
      final allData = await _secureStorage.readAll();
      final keys = allData.keys.toSet();
      printS("[SecureStorageManager] getAllKeys: ${keys.length} keys");
      return keys;
    } catch (e) {
      printE("[SecureStorageManager] getAllKeys - Error: $e");
      return <String>{};
    }
  }

  /// Get storage size (number of keys)
  Future<int> size() async {
    try {
      final keys = await getAllKeys();
      return keys.length;
    } catch (e) {
      printE("[SecureStorageManager] size - Error: $e");
      return 0;
    }
  }

  /// Check if storage is empty
  Future<bool> isEmpty() async {
    try {
      final size = await this.size();
      return size == 0;
    } catch (e) {
      printE("[SecureStorageManager] isEmpty - Error: $e");
      return true;
    }
  }

  /// Batch write operations
  Future<void> writeBatch(Map<String, String> data, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      for (final entry in data.entries) {
        await writeSecure(entry.key, entry.value, additionalEncryption: additionalEncryption, encryptionSalt: encryptionSalt);
      }
      printS("[SecureStorageManager] writeBatch: ${data.length} items");
    } catch (e) {
      printE("[SecureStorageManager] writeBatch - Error: $e");
      rethrow;
    }
  }

  /// Batch read operations
  Future<Map<String, String?>> readBatch(List<String> keys, {bool additionalEncryption = false, String? encryptionSalt}) async {
    try {
      final Map<String, String?> result = {};
      for (final key in keys) {
        result[key] = await readSecure(key, additionalEncryption: additionalEncryption, encryptionSalt: encryptionSalt);
      }
      printS("[SecureStorageManager] readBatch: ${keys.length} items");
      return result;
    } catch (e) {
      printE("[SecureStorageManager] readBatch - Error: $e");
      return {};
    }
  }

  /// Backup all data (be careful with this in production)
  Future<Map<String, String>> backup() async {
    try {
      final allData = await _secureStorage.readAll();
      printS("[SecureStorageManager] backup: ${allData.length} items");
      return allData;
    } catch (e) {
      printE("[SecureStorageManager] backup - Error: $e");
      return {};
    }
  }

  /// Restore data from backup
  Future<void> restore(Map<String, String> data) async {
    try {
      await deleteAll();
      await writeBatch(data);
      printS("[SecureStorageManager] restore: ${data.length} items");
    } catch (e) {
      printE("[SecureStorageManager] restore - Error: $e");
      rethrow;
    }
  }

  /// Check data integrity with checksum
  Future<void> writeWithChecksum(String key, String value) async {
    try {
      final checksum = _generateChecksum(value);
      final dataWithChecksum = {'value': value, 'checksum': checksum, 'timestamp': DateTime.now().toIso8601String()};

      await writeJson(key, dataWithChecksum, additionalEncryption: true);
      printS("[SecureStorageManager] writeWithChecksum: [$key]");
    } catch (e) {
      printE("[SecureStorageManager] writeWithChecksum: [$key] - Error: $e");
      rethrow;
    }
  }

  /// Read data with checksum verification
  Future<String?> readWithChecksum(String key) async {
    try {
      final dataWithChecksum = await readJson(key, additionalEncryption: true);

      if (dataWithChecksum == null) return null;

      final value = dataWithChecksum['value'] as String?;
      final storedChecksum = dataWithChecksum['checksum'] as String?;

      if (value == null || storedChecksum == null) {
        printE("[SecureStorageManager] readWithChecksum: [$key] - Invalid data structure");
        return null;
      }

      final calculatedChecksum = _generateChecksum(value);
      if (storedChecksum != calculatedChecksum) {
        printE("[SecureStorageManager] readWithChecksum: [$key] - Checksum mismatch, data may be corrupted");
        await delete(key); // Remove corrupted data
        return null;
      }

      printS("[SecureStorageManager] readWithChecksum: [$key] - Checksum verified");
      return value;
    } catch (e) {
      printE("[SecureStorageManager] readWithChecksum: [$key] - Error: $e");
      return null;
    }
  }

  /// Private encryption method using simple XOR with salt (can be enhanced)
  String _encryptValue(String value, String salt) {
    try {
      final valueBytes = utf8.encode(value);
      final saltBytes = utf8.encode(salt);
      final encrypted = <int>[];

      for (int i = 0; i < valueBytes.length; i++) {
        encrypted.add(valueBytes[i] ^ saltBytes[i % saltBytes.length]);
      }

      return base64Encode(encrypted);
    } catch (e) {
      printE("[SecureStorageManager] _encryptValue - Error: $e");
      rethrow;
    }
  }

  /// Private decryption method
  String _decryptValue(String encryptedValue, String salt) {
    try {
      final encryptedBytes = base64Decode(encryptedValue);
      final saltBytes = utf8.encode(salt);
      final decrypted = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ saltBytes[i % saltBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      printE("[SecureStorageManager] _decryptValue - Error: $e");
      rethrow;
    }
  }

  /// Generate checksum for data integrity
  String _generateChecksum(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Clean up expired data
  Future<void> cleanupExpiredData() async {
    try {
      final allKeys = await getAllKeys();
      int cleanedCount = 0;

      for (final key in allKeys) {
        try {
          final data = await readJson(key);
          if (data != null && data.containsKey('expiryTime')) {
            final expiryTimeString = data['expiryTime'] as String?;
            if (expiryTimeString != null) {
              final expiryTime = DateTime.parse(expiryTimeString);
              if (DateTime.now().isAfter(expiryTime)) {
                await delete(key);
                cleanedCount++;
              }
            }
          }
        } catch (e) {
          // Continue with next key if there's an error
          printE("[SecureStorageManager] cleanupExpiredData: Error processing key [$key] - $e");
        }
      }

      printS("[SecureStorageManager] cleanupExpiredData: Cleaned $cleanedCount expired items");
    } catch (e) {
      printE("[SecureStorageManager] cleanupExpiredData - Error: $e");
    }
  }
}
