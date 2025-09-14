import 'package:news_app/core/service/device/biometric/enum/biometric_enum.dart';

class BiometricResult {
  final bool success;
  final String? errorMessage;
  final BiometricEnumStatus status;

  BiometricResult({required this.success, this.errorMessage, required this.status});

  @override
  String toString() {
    return 'BiometricResult(success: $success, errorMessage: $errorMessage, status: $status)';
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'errorMessage': errorMessage, 'status': status.toString()};
  }
}
