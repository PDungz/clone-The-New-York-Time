// ignore_for_file: unreachable_switch_default

import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:local_auth_android/local_auth_android.dart' as local_auth;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:news_app/core/service/device/biometric/enum/biometric_enum.dart';
import 'package:news_app/core/service/device/biometric/model/biometric.dart';
import 'package:news_app/core/service/device/biometric/model/biometric_result.dart';

class BiometricService {
  // Private constructor
  BiometricService._();

  // Singleton instance
  static BiometricService? _instance;
  static BiometricService get instance {
    _instance ??= BiometricService._();
    return _instance!;
  }

  // Short alias cho instance
  static BiometricService get I => instance;

  // Internal properties
  final local_auth.LocalAuthentication _auth = local_auth.LocalAuthentication();
  Biometric? _cachedInfo;
  DateTime? _lastCacheTime;
  bool _isInitialized = false;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  /// Auto-initialize khi lần đầu sử dụng
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _refreshBiometricInfo();
      _isInitialized = true;
    }
  }

  /// Getter để lấy biometric info (auto-initialize)
  Future<Biometric> get biometric async {
    await _ensureInitialized();

    if (_cachedInfo != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheTimeout) {
      return _cachedInfo!;
    }

    return await _refreshBiometricInfo();
  }

  // Quick access properties
  Future<BiometricEnumType> get type async => (await biometric).primaryType;
  Future<bool> get isSupported async => (await biometric).isSupported;
  Future<bool> get isAvailable async => (await biometric).isAvailable;
  Future<bool> get hasFingerprint async => (await biometric).hasFingerprint;
  Future<bool> get hasFaceID async => (await biometric).hasFaceID;
  Future<bool> get hasIris async => (await biometric).hasIris;
  Future<bool> get hasVoice async => (await biometric).hasVoice;
  Future<String> get typeName async => (await biometric).typeName;
  Future<String> get statusMessage async => (await biometric).statusMessage;
  Future<String> get authMessage async => (await biometric).authMessage;

  // Platform detection
  bool get isIOSDevice => Platform.isIOS;
  bool get isAndroidDevice => Platform.isAndroid;

  /// Map từ local_auth BiometricType sang BiometricEnumType
  BiometricEnumType _mapBiometricType(local_auth.BiometricType localType) {
    switch (localType) {
      case local_auth.BiometricType.fingerprint:
        return BiometricEnumType.FINGERPRINT;
      case local_auth.BiometricType.face:
        return BiometricEnumType.FACE_ID;
      case local_auth.BiometricType.iris:
        return BiometricEnumType.IRIS;
      case local_auth.BiometricType.weak:
      case local_auth.BiometricType.strong:
        // Android: weak/strong chỉ là fingerprint, không phải face
        return BiometricEnumType.FINGERPRINT;
      default:
        return BiometricEnumType.OTHER;
    }
  }

  /// Lấy loại biometric chính từ danh sách có sẵn
  BiometricEnumType _getPrimaryBiometric(List<BiometricEnumType> biometrics) {
    if (biometrics.isEmpty) return BiometricEnumType.OTHER;

    // Platform-specific priority
    if (Platform.isIOS) {
      // iOS: Ưu tiên Face ID trước, sau đó Touch ID
      if (biometrics.contains(BiometricEnumType.FACE_ID)) {
        return BiometricEnumType.FACE_ID;
      } else if (biometrics.contains(BiometricEnumType.FINGERPRINT)) {
        return BiometricEnumType.FINGERPRINT;
      }
    } else if (Platform.isAndroid) {
      // Android: Ưu tiên Fingerprint trước, sau đó Face
      if (biometrics.contains(BiometricEnumType.FINGERPRINT)) {
        return BiometricEnumType.FINGERPRINT;
      } else if (biometrics.contains(BiometricEnumType.FACE_ID)) {
        return BiometricEnumType.FACE_ID;
      }
    }

    // Fallback cho các loại khác
    if (biometrics.contains(BiometricEnumType.IRIS)) {
      return BiometricEnumType.IRIS;
    } else if (biometrics.contains(BiometricEnumType.VOICE)) {
      return BiometricEnumType.VOICE;
    }

    return BiometricEnumType.OTHER;
  }

  /// Refresh cached biometric info
  Future<Biometric> _refreshBiometricInfo() async {
    try {
      final isSupported = await _isDeviceSupported();
      final canCheck = await _canCheckBiometrics();
      final availableBiometrics = await _getAvailableBiometrics();
      final status = await _getBiometricStatus();
      final primaryType = _getPrimaryBiometric(availableBiometrics);

      _cachedInfo = Biometric(
        isSupported: isSupported,
        canCheck: canCheck,
        availableBiometrics: availableBiometrics,
        status: status,
        primaryType: primaryType,
      );
      _lastCacheTime = DateTime.now();

      return _cachedInfo!;
    } catch (e) {
      // Fallback khi có lỗi
      _cachedInfo = Biometric(
        isSupported: false,
        canCheck: false,
        availableBiometrics: [],
        status: BiometricEnumStatus.UNKNOWN,
        primaryType: BiometricEnumType.OTHER,
      );
      _lastCacheTime = DateTime.now();
      return _cachedInfo!;
    }
  }

  /// Public method để force refresh cache
  Future<Biometric> refresh() async {
    _cachedInfo = null;
    _lastCacheTime = null;
    return await _refreshBiometricInfo();
  }

  /// Clear cache
  void clearCache() {
    _cachedInfo = null;
    _lastCacheTime = null;
    _isInitialized = false;
  }

  /// Kiểm tra thiết bị có hỗ trợ biometric không
  Future<bool> _canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra trạng thái thiết bị có biometric được kích hoạt không
  Future<bool> _isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách các loại biometric có sẵn với Android fallback
  Future<List<BiometricEnumType>> _getAvailableBiometrics() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      
      // Debug: In ra raw biometric types
      print('Raw available biometrics: $availableBiometrics');

      if (availableBiometrics.isEmpty) {
        return [];
      }

      // Android-specific handling
      if (Platform.isAndroid) {
        final Set<BiometricEnumType> detectedTypes = <BiometricEnumType>{};

        for (final rawType in availableBiometrics) {
          switch (rawType) {
            case local_auth.BiometricType.fingerprint:
              detectedTypes.add(BiometricEnumType.FINGERPRINT);
              break;
            case local_auth.BiometricType.face:
              detectedTypes.add(BiometricEnumType.FACE_ID);
              break;
            case local_auth.BiometricType.iris:
              detectedTypes.add(BiometricEnumType.IRIS);
              break;
            case local_auth.BiometricType.strong:
            case local_auth.BiometricType.weak:
              // Android: weak/strong thường chỉ là fingerprint
              detectedTypes.add(BiometricEnumType.FINGERPRINT);
              break;
            default:
              detectedTypes.add(BiometricEnumType.OTHER);
              break;
          }
        }

        // Debug: show what we detected
        print('Android detected types: $detectedTypes');
        return detectedTypes.toList();
      } else {
        // iOS and other platforms: use simple mapping
        List<BiometricEnumType> mappedTypes = availableBiometrics.map(_mapBiometricType).toList();
        return mappedTypes.toSet().toList();
      }
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Kiểm tra trạng thái biometric chi tiết
  Future<BiometricEnumStatus> _getBiometricStatus() async {
    try {
      final isSupported = await _isDeviceSupported();
      if (!isSupported) {
        return BiometricEnumStatus.NOT_AVAILABLE;
      }

      final canCheck = await _canCheckBiometrics();
      if (!canCheck) {
        return BiometricEnumStatus.DISABLED;
      }

      final availableBiometrics = await _getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricEnumStatus.NOT_ENROLLED;
      }

      return BiometricEnumStatus.AVAILABLE;
    } catch (e) {
      return BiometricEnumStatus.UNKNOWN;
    }
  }

  /// Thực hiện xác thực vân tay/FaceID với xử lý lỗi chi tiết
  Future<BiometricResult> authenticate({
    String? localizedReason,
    bool biometricOnly = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
    bool autoDetectMessage = true,
  }) async {
    print('🔐 [BiometricAuth] Starting authentication...');
    
    try {
      final info = await biometric;
      print('🔐 [BiometricAuth] Biometric info: ${info.toJson()}');

      if (!info.isAvailable) {
        print('❌ [BiometricAuth] Biometric not available: ${info.statusMessage}');
        return BiometricResult(
          success: false,
          status: info.status,
          errorMessage: info.statusMessage,
        );
      }

      // Tự động tạo thông báo phù hợp với loại biometric
      String message = localizedReason ?? 'Vui lòng xác thực để tiếp tục';
      if (autoDetectMessage && localizedReason == null) {
        message = info.authMessage;
      }
      
      print('🔐 [BiometricAuth] Using message: "$message"');
      print(
        '🔐 [BiometricAuth] Options: biometricOnly=$biometricOnly, stickyAuth=$stickyAuth, sensitiveTransaction=$sensitiveTransaction',
      );

      // Platform-specific auth messages
      List<local_auth.AuthMessages> authMessages = [];

      if (Platform.isAndroid) {
        authMessages.add(
          const AndroidAuthMessages(
            signInTitle: 'Xác thực sinh trắc học',
            cancelButton: 'Hủy',
            deviceCredentialsRequiredTitle: 'Yêu cầu xác thực thiết bị',
            deviceCredentialsSetupDescription: 'Vui lòng thiết lập xác thực thiết bị',
            goToSettingsButton: 'Đi đến cài đặt',
            goToSettingsDescription:
                'Xác thực sinh trắc học chưa được thiết lập trên thiết bị của bạn',
            biometricHint: 'Xác minh danh tính',
            biometricNotRecognized: 'Không nhận diện được, vui lòng thử lại',
            biometricRequiredTitle: 'Yêu cầu xác thực sinh trắc học',
            biometricSuccess: 'Xác thực thành công',
          ),
        );
        print('🔐 [BiometricAuth] Using Android auth messages');
      }

      if (Platform.isIOS) {
        authMessages.add(
          const IOSAuthMessages(
            cancelButton: 'Hủy',
            goToSettingsButton: 'Đi đến cài đặt',
            goToSettingsDescription: 'Vui lòng thiết lập Touch ID hoặc Face ID',
            lockOut: 'Vui lòng kích hoạt lại xác thực sinh trắc học',
            localizedFallbackTitle: 'Sử dụng mật khẩu',
          ),
        );
        print('🔐 [BiometricAuth] Using iOS auth messages');
      }

      print('🔐 [BiometricAuth] Calling _auth.authenticate...');

      final didAuthenticate = await _auth.authenticate(
        localizedReason: message,
        options: local_auth.AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
        ),
        authMessages: authMessages,
      );

      print('🔐 [BiometricAuth] Authentication result: $didAuthenticate');

      return BiometricResult(
        success: didAuthenticate,
        status: BiometricEnumStatus.AVAILABLE,
        errorMessage: didAuthenticate ? null : 'Xác thực không thành công',
      );
    } on PlatformException catch (e) {
      print('❌ [BiometricAuth] PlatformException: ${e.code} - ${e.message}');
      String errorMessage = _handlePlatformException(e);
      return BiometricResult(
        success: false,
        status: BiometricEnumStatus.UNKNOWN,
        errorMessage: errorMessage,
      );
    } catch (e) {
      print('❌ [BiometricAuth] General Exception: $e');
      return BiometricResult(
        success: false,
        status: BiometricEnumStatus.UNKNOWN,
        errorMessage: 'Lỗi xác thực: ${e.toString()}',
      );
    }
  }

  /// Xử lý lỗi platform-specific
  String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'BiometricOnlyNotSupported':
        return 'Thiết bị không hỗ trợ chỉ xác thực sinh trắc học';
      case 'DeviceNotSupported':
        return 'Thiết bị không hỗ trợ xác thực sinh trắc học';
      case 'NotAvailable':
        return 'Xác thực sinh trắc học không khả dụng';
      case 'NotEnrolled':
        return 'Chưa thiết lập xác thực sinh trắc học';
      case 'PasscodeNotSet':
        return 'Chưa thiết lập mật khẩu thiết bị';
      case 'LockedOut':
        return 'Xác thực sinh trắc học bị khóa do quá nhiều lần thử sai';
      case 'PermanentlyLockedOut':
        return 'Xác thực sinh trắc học bị khóa vĩnh viễn';
      case 'UserCancel':
        return 'Người dùng đã hủy xác thực';
      case 'UserFallback':
        return 'Người dùng chọn sử dụng phương thức xác thực khác';
      case 'SystemCancel':
        return 'Hệ thống đã hủy xác thực';
      case 'InvalidContext':
        return 'Ngữ cảnh xác thực không hợp lệ';
      case 'BiometricError':
        return 'Lỗi xác thực sinh trắc học';
      default:
        return 'Lỗi xác thực: ${e.message ?? e.code}';
    }
  }

  /// Test authentication bypass FragmentActivity issue
  Future<BiometricResult> testAuthenticationBypass() async {
    print('🧪 [BypassTest] Testing authentication without FragmentActivity dependency...');

    try {
      final info = await biometric;

      if (!info.isAvailable) {
        return BiometricResult(
          success: false,
          status: info.status,
          errorMessage: info.statusMessage,
        );
      }

      print('🧪 [BypassTest] Attempting minimal authentication...');

      // Minimal authentication call
      final result = await _auth.authenticate(
        localizedReason: 'Xác thực để tiếp tục',
        options: const local_auth.AuthenticationOptions(
          biometricOnly: false, // Allow device PIN/Pattern as fallback
          stickyAuth: false,
          sensitiveTransaction: false,
        ),
      );

      print('🧪 [BypassTest] Result: $result');

      return BiometricResult(
        success: result,
        status: BiometricEnumStatus.AVAILABLE,
        errorMessage: result ? null : 'Authentication failed',
      );
    } catch (e) {
      print('❌ [BypassTest] Still failed: $e');
      return BiometricResult(
        success: false,
        status: BiometricEnumStatus.UNKNOWN,
        errorMessage: 'Authentication error: ${e.toString()}',
      );
    }
  }

  /// Test authentication với các options khác nhau
  Future<void> testAuthentication() async {
    print('🧪 [BiometricTest] Starting comprehensive test...');

    // Test 1: Basic info
    print('🧪 [Test 1] Checking basic info...');
    final info = await biometric;
    print('  - Supported: ${info.isSupported}');
    print('  - Available: ${info.isAvailable}');
    print('  - Can Check: ${info.canCheck}');
    print('  - Status: ${info.status}');

    if (!info.isAvailable) {
      print('❌ [BiometricTest] Not available, stopping test');
      return;
    }

    // Test 2: Simple authentication
    print('🧪 [Test 2] Testing simple authentication...');
    try {
      final result1 = await _auth.authenticate(
        localizedReason: 'Test authentication',
        options: const local_auth.AuthenticationOptions(
          biometricOnly: false, // Allow fallback
          stickyAuth: false,
          sensitiveTransaction: false,
        ),
      );
      print('  - Result with fallback: $result1');
    } catch (e) {
      print('  - Error with fallback: $e');
    }

    // Test 3: Biometric only
    print('🧪 [Test 3] Testing biometric only...');
    try {
      final result2 = await _auth.authenticate(
        localizedReason: 'Test biometric only',
        options: const local_auth.AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          sensitiveTransaction: false,
        ),
      );
      print('  - Result biometric only: $result2');
    } catch (e) {
      print('  - Error biometric only: $e');
    }

    print('🧪 [BiometricTest] Test completed');
  }

  /// Xác thực đơn giản (backward compatibility)
  Future<bool> authenticateSimple() async {
    final result = await authenticate();
    return result.success;
  }

  /// Kiểm tra nhanh xem có thể xác thực không
  Future<bool> canAuthenticate() async {
    final info = await biometric;
    return info.isAvailable;
  }

  /// Lấy thông tin chi tiết về biometric dưới dạng JSON
  Future<Map<String, dynamic>> getBiometricInfo() async {
    final info = await biometric;
    return {
      ...info.toJson(),
      'platform':
          Platform.isIOS
              ? 'iOS'
              : Platform.isAndroid
              ? 'Android'
              : 'Unknown',
      'isIOSDevice': isIOSDevice,
      'isAndroidDevice': isAndroidDevice,
    };
  }

  /// Debug raw biometric types
  Future<void> debugRawBiometrics() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();

      print('=== RAW BIOMETRIC DEBUG ===');
      print(
        'Platform: ${Platform.isIOS
            ? 'iOS'
            : Platform.isAndroid
            ? 'Android'
            : 'Unknown'}',
      );
      print('Device Supported: $isSupported');
      print('Can Check: $canCheck');
      print('Raw Available Biometrics: $availableBiometrics');
      print('Raw Types Count: ${availableBiometrics.length}');

      for (int i = 0; i < availableBiometrics.length; i++) {
        final raw = availableBiometrics[i];
        final mapped = _mapBiometricType(raw);
        print('  [$i] Raw: $raw -> Mapped: $mapped');
      }

      final mappedList = await _getAvailableBiometrics();
      print('Final Mapped List: $mappedList');
      print('========================');
    } catch (e) {
      print('Debug error: $e');
    }
  }

  /// Debug info - in ra console với raw data
  Future<void> printBiometricInfo() async {
    await debugRawBiometrics();
    
    final info = await biometric;
    print('=== Biometric Info ===');
    print(
      'Platform: ${Platform.isIOS
          ? 'iOS'
          : Platform.isAndroid
          ? 'Android'
          : 'Unknown'}',
    );
    print('Supported: ${info.isSupported}');
    print('Available: ${info.isAvailable}');
    print('Primary Type: ${info.typeName}');
    print('Has Fingerprint: ${info.hasFingerprint}');
    print('Has Face ID: ${info.hasFaceID}');
    print('Has Iris: ${info.hasIris}');
    print('Has Voice: ${info.hasVoice}');
    print('Status: ${info.statusMessage}');
    print('Auth Message: ${info.authMessage}');
    print('Available Types: ${info.availableBiometrics}');
    print('Is iOS: $isIOSDevice');
    print('Is Android: $isAndroidDevice');
    print('===================');
  }

  /// Initialize service ngay khi app khởi động
  static Future<void> initialize() async {
    await instance._ensureInitialized();
    print('✅ BiometricService initialized');

    // Optional: In thông tin debug khi init
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      await instance.printBiometricInfo();
    }
  }

  // Legacy static methods for backward compatibility
  static Future<bool> canCheckBiometrics() async => await instance._canCheckBiometrics();
  static Future<bool> isDeviceSupported() async => await instance._isDeviceSupported();
  static Future<List<BiometricEnumType>> getAvailableBiometrics() async =>
      await instance._getAvailableBiometrics();
  static Future<BiometricEnumStatus> getBiometricStatus() async =>
      await instance._getBiometricStatus();
  static Future<BiometricResult> authenticateStatic({
    String? localizedReason,
    bool biometricOnly = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
    bool autoDetectMessage = true,
  }) async => await instance.authenticate(
    localizedReason: localizedReason,
    biometricOnly: biometricOnly,
    stickyAuth: stickyAuth,
    sensitiveTransaction: sensitiveTransaction,
    autoDetectMessage: autoDetectMessage,
  );
}
