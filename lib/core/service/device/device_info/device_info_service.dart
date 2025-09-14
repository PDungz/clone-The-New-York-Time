// lib/core/service/device/device_info/device_info_service.dart
import 'package:news_app/core/native/base_native_service.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._();
  static DeviceInfoService get instance => _instance;

  final BaseNativeService _channel = BaseNativeService('device_service');

  DeviceInfoService._();

  /// Get complete device information with location (async)
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    final result = await _channel.call<Map<dynamic, dynamic>>('getDeviceInfo');
    if (result == null) return null;

    // ✅ Convert Map<dynamic, dynamic> to Map<String, dynamic> safely
    return _convertToStringDynamicMap(result);
  }

  /// Get device information without full location (sync/faster)
  Future<Map<String, dynamic>?> getDeviceInfoSync() async {
    final result = await _channel.call<Map<dynamic, dynamic>>('getDeviceInfoSync');
    if (result == null) return null;

    return _convertToStringDynamicMap(result);
  }

  /// Get system information only (without user-specific data)
  Future<Map<String, dynamic>?> getSystemInfo() async {
    final result = await _channel.call<Map<dynamic, dynamic>>('getSystemInfo');
    if (result == null) return null;

    return _convertToStringDynamicMap(result);
  }

  /// Get unique device identifier
  Future<String?> getDeviceIdentifier() async {
    final result = await _channel.call<String>('getDeviceIdentifier');
    return result;
  }

  // ========================= CONVENIENCE METHODS =========================

  /// Get device info ready for API call (with location)
  Future<Map<String, dynamic>?> getApiDeviceInfo() async {
    try {
      final deviceInfo = await getDeviceInfo();
      if (deviceInfo == null) return null;

      // Format data theo đúng API structure (bao gồm location)
      final apiInfo = {
        "deviceName": deviceInfo['deviceName'],
        "deviceType": deviceInfo['deviceType'],
        "platform": deviceInfo['platform'],
        "platformVersion": deviceInfo['platformVersion'],
        "appVersion": deviceInfo['appVersion'],
        "deviceIdentifier": deviceInfo['deviceIdentifier'],
        "pushToken": null, // Tạm thời null
        "screenResolution": deviceInfo['screenResolution'],
        "timezone": deviceInfo['timezone'],
        "language": deviceInfo['language'],
        "isPushEnabled": false, // Tạm thời false
        "isActive": deviceInfo['isActive'],
        "isPrimary": deviceInfo['isPrimary'],
        "status": deviceInfo['status'],
        "location": deviceInfo['location'], // ✅ THÊM location info
      };

      return apiInfo;
    } catch (e) {
      print('Error getting API device info: $e');
      return null;
    }
  }

  /// Get device info ready for API call (faster, without full location)
  Future<Map<String, dynamic>?> getApiDeviceInfoSync() async {
    try {
      final deviceInfo = await getDeviceInfoSync();
      if (deviceInfo == null) return null;

      final apiInfo = {
        "deviceName": deviceInfo['deviceName'],
        "deviceType": deviceInfo['deviceType'],
        "platform": deviceInfo['platform'],
        "platformVersion": deviceInfo['platformVersion'],
        "appVersion": deviceInfo['appVersion'],
        "deviceIdentifier": deviceInfo['deviceIdentifier'],
        "pushToken": null,
        "screenResolution": deviceInfo['screenResolution'],
        "timezone": deviceInfo['timezone'],
        "language": deviceInfo['language'],
        "isPushEnabled": false,
        "isActive": deviceInfo['isActive'],
        "isPrimary": deviceInfo['isPrimary'],
        "status": deviceInfo['status'],
        "location": deviceInfo['location'], // Basic location info
      };

      return apiInfo;
    } catch (e) {
      print('Error getting API device info sync: $e');
      return null;
    }
  }

  /// Print device info in JSON format for API testing
  void printDeviceInfoForAPI(Map<String, dynamic> deviceInfo) {
    print('📱 Device Info JSON for API:');
    print('{');
    deviceInfo.forEach((key, value) {
      if (value is Map) {
        print('  "$key": {');
        (value).forEach((subKey, subValue) {
          if (subValue is String) {
            print('    "$subKey": "$subValue",');
          } else {
            print('    "$subKey": $subValue,');
          }
        });
        print('  },');
      } else if (value is String) {
        print('  "$key": "$value",');
      } else {
        print('  "$key": $value,');
      }
    });
    print('}');
  }

  /// Get individual device properties
  Future<String?> getDeviceName() async {
    final info = await getSystemInfo();
    return info?['deviceName'];
  }

  Future<String?> getDeviceType() async {
    final info = await getSystemInfo();
    return info?['deviceType'];
  }

  Future<String?> getPlatform() async {
    final info = await getSystemInfo();
    return info?['platform'];
  }

  Future<String?> getPlatformVersion() async {
    final info = await getSystemInfo();
    return info?['platformVersion'];
  }

  Future<String?> getScreenResolution() async {
    final info = await getSystemInfo();
    return info?['screenResolution'];
  }

  Future<String?> getTimezone() async {
    final info = await getSystemInfo();
    return info?['timezone'];
  }

  Future<String?> getLanguage() async {
    final info = await getSystemInfo();
    return info?['language'];
  }

  /// Get location info specifically
  Future<Map<String, dynamic>?> getLocationInfo() async {
    final deviceInfo = await getDeviceInfo();
    if (deviceInfo == null || deviceInfo['location'] == null) return null;

    return _convertToStringDynamicMap(deviceInfo['location']);
  }

  // ✅ THÊM: Helper method để convert types safely
  Map<String, dynamic> _convertToStringDynamicMap(dynamic input) {
    if (input == null) return {};

    if (input is Map<String, dynamic>) {
      // Already correct type, but check nested maps
      return input.map((key, value) => MapEntry(key, _convertValue(value)));
    } else if (input is Map) {
      // Convert Map<dynamic, dynamic> or Map<Object?, Object?> to Map<String, dynamic>
      return input.map((key, value) => MapEntry(key.toString(), _convertValue(value)));
    }

    return {};
  }

  dynamic _convertValue(dynamic value) {
    if (value is Map && value is! Map<String, dynamic>) {
      return _convertToStringDynamicMap(value);
    }
    return value;
  }

  /// Get IP address only
  Future<String?> getIpAddress() async {
    final locationInfo = await getLocationInfo();
    return locationInfo?['ipAddress'];
  }

  /// Get country only
  Future<String?> getCountry() async {
    final locationInfo = await getLocationInfo();
    return locationInfo?['country'];
  }

  /// Get city only
  Future<String?> getCity() async {
    final locationInfo = await getLocationInfo();
    return locationInfo?['city'];
  }

  /// Get coordinates
  Future<Map<String, double>?> getCoordinates() async {
    final locationInfo = await getLocationInfo();
    if (locationInfo == null) return null;

    return {
      'latitude': (locationInfo['latitude'] as num?)?.toDouble() ?? 0.0,
      'longitude': (locationInfo['longitude'] as num?)?.toDouble() ?? 0.0,
    };
  }
}
