// ignore_for_file: unreachable_switch_default

import 'package:news_app/core/service/device/biometric/enum/biometric_enum.dart';

class Biometric {
  final bool isSupported;
  final bool canCheck;
  final List<BiometricEnumType> availableBiometrics;
  final BiometricEnumStatus status;
  final BiometricEnumType primaryType;

  Biometric({
    required this.isSupported,
    required this.canCheck,
    required this.availableBiometrics,
    required this.status,
    required this.primaryType,
  });

  // Quick access properties
  bool get hasFingerprint => availableBiometrics.contains(BiometricEnumType.FINGERPRINT);
  bool get hasFaceID => availableBiometrics.contains(BiometricEnumType.FACE_ID);
  bool get hasIris => availableBiometrics.contains(BiometricEnumType.IRIS);
  bool get hasVoice => availableBiometrics.contains(BiometricEnumType.VOICE);
  bool get isAvailable => status == BiometricEnumStatus.AVAILABLE;
  bool get isEmpty => availableBiometrics.isEmpty;

  String get typeName => _getBiometricDisplayName(primaryType);
  String get statusMessage => _getStatusMessage(status);
  String get authMessage => _getAuthMessage(primaryType);

  // Utility methods
  static String _getBiometricDisplayName(BiometricEnumType type) {
    switch (type) {
      case BiometricEnumType.FINGERPRINT:
        return 'Vân tay';
      case BiometricEnumType.FACE_ID:
        return 'Khuôn mặt';
      case BiometricEnumType.IRIS:
        return 'Mống mắt';
      case BiometricEnumType.VOICE:
        return 'Giọng nói';
      case BiometricEnumType.OTHER:
      default:
        return 'Khác';
    }
  }

  static String _getAuthMessage(BiometricEnumType type) {
    switch (type) {
      case BiometricEnumType.FINGERPRINT:
        return 'Đặt ngón tay lên cảm biến để xác thực';
      case BiometricEnumType.FACE_ID:
        return 'Nhìn vào camera để xác thực khuôn mặt';
      case BiometricEnumType.IRIS:
        return 'Nhìn vào camera để quét mống mắt';
      case BiometricEnumType.VOICE:
        return 'Nói vào microphone để xác thực giọng nói';
      case BiometricEnumType.OTHER:
      default:
        return 'Vui lòng xác thực để tiếp tục';
    }
  }

  static String _getStatusMessage(BiometricEnumStatus status) {
    switch (status) {
      case BiometricEnumStatus.AVAILABLE:
        return 'Xác thực sinh trắc học sẵn sàng';
      case BiometricEnumStatus.NOT_AVAILABLE:
        return 'Thiết bị không hỗ trợ xác thực sinh trắc học';
      case BiometricEnumStatus.NOT_ENROLLED:
        return 'Chưa thiết lập xác thực sinh trắc học';
      case BiometricEnumStatus.DISABLED:
        return 'Xác thực sinh trắc học đã bị tắt';
      case BiometricEnumStatus.UNKNOWN:
      default:
        return 'Không thể xác định trạng thái xác thực';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isSupported': isSupported,
      'canCheck': canCheck,
      'availableBiometrics': availableBiometrics.map((e) => e.toString()).toList(),
      'availableBiometricNames':
          availableBiometrics.map((e) => _getBiometricDisplayName(e)).toList(),
      'status': status.toString(),
      'statusMessage': statusMessage,
      'primaryType': primaryType.toString(),
      'primaryTypeName': typeName,
      'hasFingerprint': hasFingerprint,
      'hasFaceID': hasFaceID,
      'hasIris': hasIris,
      'hasVoice': hasVoice,
      'isAvailable': isAvailable,
      'authMessage': authMessage,
    };
  }

  @override
  String toString() {
    return 'Biometric(isSupported: $isSupported, canCheck: $canCheck, '
        'availableBiometrics: $availableBiometrics, status: $status, '
        'primaryType: $primaryType)';
  }
}
