import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:news_app/core/service/device/biometric/biometric_service.dart';
import 'package:news_app/core/service/device/biometric/model/biometric.dart';
import 'package:news_app/core/service/device/device_info/device_info_service.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/feature/auth/domain/entities/User.dart';
import 'package:news_app/feature/auth/domain/use_case/auth_use_case.dart';
import 'package:packages/core/service/logger_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase _authUseCase = getIt<AuthUseCase>();
  final BiometricService _biometricService = BiometricService.I;

  AuthBloc() : super(AuthInitial()) {
    // Register event handlers
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthBiometricRequested>(_onBiometricRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusRequested>(_onStatusRequested);

    // Initialize biometric check
    _initializeBiometric();
  }

  /// Initialize biometric service and check availability
  Future<void> _initializeBiometric() async {
    try {
      final biometricInfo = await _biometricService.biometric;

      if (biometricInfo.isAvailable) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(AuthBiometricAvailable(biometricInfo: biometricInfo));
      }
    } catch (e) {
      printE('[AuthBloc] Biometric initialization error: $e');
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      printI('[AuthBloc] Login requested for: ${event.email}');
      emit(AuthLoading());

      // Perform login using use case
      final result = await _authUseCase.login(username: event.email, password: event.password);

      result.fold(
        (failure) {
          printE('[AuthBloc] Login failed: ${failure.message}');
          emit(AuthFailure(message: failure.message, errorCode: _getErrorCode(failure)));
        },
        (user) {
          printI('[AuthBloc] Login successful for: ${user.email}');

          // If remember me is enabled, save credentials for biometric
          if (event.rememberMe) {
            _saveBiometricCredentials(event.email, event.password);
          }

          emit(AuthAuthenticated(user: user, isFromBiometric: false));
        },
      );
    } catch (e) {
      printE('[AuthBloc] Login error: $e');
      emit(
        AuthFailure(
          message: 'An unexpected error occurred during login',
          errorCode: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Handle biometric authentication request
  Future<void> _onBiometricRequested(AuthBiometricRequested event, Emitter<AuthState> emit) async {
    try {
      printI('[AuthBloc] Biometric authentication requested');

      // Check if biometric is available
      final biometricInfo = await BiometricService.I.biometric;

      if (!biometricInfo.isAvailable) {
        emit(
          AuthFailure(
            message: 'Biometric authentication is not available',
            errorCode: 'BIOMETRIC_NOT_AVAILABLE',
            isBiometricError: true,
          ),
        );
        return;
      }

      // Perform biometric authentication
      final biometricResult = await BiometricService.I.authenticate(
        localizedReason:
            event.localizedReason ??
            'Authenticate with ${await BiometricService.I.typeName} to login',
        autoDetectMessage: true,
      );

      // Future.delayed(Duration(seconds: 2), () {});

      if (biometricResult.success) {
        emit(AuthLoading());
        // Get device info
        final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
        final Map<String, dynamic>? deviceInfo = await deviceInfoService.getApiDeviceInfo();

        // Create device model with FCM token
        final deviceModel = DeviceModel.fromJson(deviceInfo ?? <String, dynamic>{});
        // Perform login with saved credentials
        final result = await _authUseCase.biometricLogin(
          email: 'user@gmail.com',
          deviceIdentifier: deviceModel.deviceIdentifier ?? '',
          isBiometric: biometricResult.success,
          typeBiometric: biometricInfo.primaryType.name,
        );

        result.fold(
          (failure) {
            printE('[AuthBloc] Biometric login failed: ${failure.message}');
            emit(
              AuthFailure(
                message: 'Biometric authentication failed: ${failure.message}',
                errorCode: _getErrorCode(failure),
                isBiometricError: true,
              ),
            );
          },
          (user) {
            printI('[AuthBloc] Biometric login successful for: ${user.email}');
            emit(AuthAuthenticated(user: user, isFromBiometric: true));
          },
        );
      }
    } catch (e) {
      printE('[AuthBloc] Biometric authentication error: $e');
      emit(
        AuthFailure(
          message: 'An unexpected error occurred during biometric authentication',
          errorCode: 'BIOMETRIC_UNEXPECTED_ERROR',
          isBiometricError: true,
        ),
      );
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      printI('[AuthBloc] Logout requested');
      emit(AuthLoading());

      // Perform logout using use case
      final result = await _authUseCase.logout();

      result.fold(
        (failure) {
          printE('[AuthBloc] Logout failed: ${failure.message}');
          // Even if logout fails, emit unauthenticated state for UX
          emit(AuthUnauthenticated());
        },
        (success) {
          printI('[AuthBloc] Logout successful');
          emit(AuthUnauthenticated());
        },
      );
    } catch (e) {
      printE('[AuthBloc] Logout error: $e');
      // Force logout even on error
      emit(AuthUnauthenticated());
    }
  }

  /// Handle status check request
  Future<void> _onStatusRequested(AuthStatusRequested event, Emitter<AuthState> emit) async {
    try {
      printI('[AuthBloc] Status check requested');

      // // Check current authentication status
      // final isAuthenticated = await _authUseCase.isAuthenticated();

      // if (isAuthenticated) {
      //   final user = await _authUseCase.getCurrentUser();
      //   if (user != null) {
      //     emit(AuthAuthenticated(user: user));
      //   } else {
      //     emit(AuthUnauthenticated());
      //   }
      // } else {
      //   emit(AuthUnauthenticated());
      // }
    } catch (e) {
      printE('[AuthBloc] Status check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Save credentials for biometric authentication
  Future<void> _saveBiometricCredentials(String email, String password) async {
    try {
      // TODO: Implement secure storage for biometric credentials
      // This should use secure storage like flutter_secure_storage
      // For now, this is a placeholder
      printI('[AuthBloc] Saving biometric credentials for: $email');

      // Example implementation:
      // await _secureStorage.write(key: 'biometric_email', value: email);
      // await _secureStorage.write(key: 'biometric_password', value: password);
    } catch (e) {
      printE('[AuthBloc] Error saving biometric credentials: $e');
    }
  }

  /// Get saved credentials for biometric authentication
  // ignore: unused_element
  Future<Map<String, String>?> _getSavedBiometricCredentials() async {
    try {
      // TODO: Implement secure storage retrieval
      // This should use secure storage like flutter_secure_storage
      // For now, return null as placeholder

      // Example implementation:
      // final email = await _secureStorage.read(key: 'biometric_email');
      // final password = await _secureStorage.read(key: 'biometric_password');
      //
      // if (email != null && password != null) {
      //   return {'email': email, 'password': password};
      // }

      return null;
    } catch (e) {
      printE('[AuthBloc] Error retrieving biometric credentials: $e');
      return null;
    }
  }

  /// Clear saved biometric credentials
  // ignore: unused_element
  Future<void> _clearBiometricCredentials() async {
    try {
      printI('[AuthBloc] Biometric credentials cleared');
    } catch (e) {
      printE('[AuthBloc] Error clearing biometric credentials: $e');
    }
  }

  /// Helper method to get error code from failure
  String _getErrorCode(failure) {
    final failureMessage = failure.toString().toLowerCase();

    if (failureMessage.contains('network')) return 'NETWORK_ERROR';
    if (failureMessage.contains('unauthorized') || failureMessage.contains('invalid'))
      return 'INVALID_CREDENTIALS';
    if (failureMessage.contains('validation')) return 'VALIDATION_ERROR';
    if (failureMessage.contains('server')) return 'SERVER_ERROR';
    if (failureMessage.contains('timeout')) return 'TIMEOUT_ERROR';

    return 'UNKNOWN_ERROR';
  }

  @override
  Future<void> close() async {
    // Clean up resources if needed
    await super.close();
  }
}
