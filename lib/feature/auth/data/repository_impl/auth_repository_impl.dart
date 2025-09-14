import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/global/device/data/model/device_model.dart';
import 'package:news_app/core/global/device/domain/use_case/device_use_case.dart';
import 'package:news_app/core/service/device/device_info/device_info_service.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/core/service/notification/firebase_messaging_service.dart';
import 'package:news_app/core/service/secure/secure_token_manager.dart';
import 'package:news_app/feature/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:news_app/feature/auth/data/model/auth_response.dart';
import 'package:news_app/feature/auth/domain/entities/User.dart';
import 'package:news_app/feature/auth/domain/extension/user_extension.dart';
import 'package:news_app/feature/auth/domain/repository/auth_repository.dart';
import 'package:packages/core/service/logger_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  late final SecureTokenManager _tokenManager;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource {
    _initTokenManager();
  }

  /// Initialize SecureTokenManager
  Future<void> _initTokenManager() async {
    _tokenManager = await SecureTokenManager.getInstance();
  }

  @override
  Future<Either<Failure, User>> login({required String username, required String password}) async {
    try {
      printI('[AuthRepository] Starting login process for: $username');

      // Check if account is locked due to failed attempts
      final isLocked = await _tokenManager.isAccountLocked();
      if (isLocked) {
        printE('[AuthRepository] Account is locked due to too many failed attempts');
        return Left(ServerFailure('Account is temporarily locked. Please try again later.'));
      }

      // Call remote data source
      final result = await _remoteDataSource.login(username: username, password: password);

      return result.fold(
        (failure) async {
          printE('[AuthRepository] Login failed: ${failure.message}');

          // Record failed login attempt
          await _tokenManager.recordLoginAttempt(success: false);

          return Left(failure);
        },
        (authResponse) async {
          printI('[AuthRepository] Login successful, saving authentication data');

          try {
            // Save authentication data securely
            if (authResponse.accessToken != null &&
                authResponse.refreshToken != null &&
                authResponse.userModel != null) {
              await _saveAuthenticationData(authResponse);

              // Record successful login
              await _tokenManager.recordLoginAttempt(success: true);

              // Convert UserModel to User entity
              final user = authResponse.userModel!.toEntity();

              // Get device info
              final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
              final Map<String, dynamic>? deviceInfo = await deviceInfoService.getApiDeviceInfo();
              
              // Get FCM token với fallback handling
              final String? fcmToken = await _getFCMTokenSafely();

              printI('[AuthRepository] FCM Token: ${fcmToken ?? "Not available"}');

              // Create device model with FCM token
              final deviceModel = DeviceModel.fromJson(deviceInfo ?? <String, dynamic>{}).copyWith(
                userId: user.id,
                pushToken: fcmToken, // Add FCM token to device model
              );

              final loginDevice = await getIt<DeviceUseCase>().createDevice(
                device: deviceModel,
              );

              // Await the result of fold and return its value
              return await loginDevice.fold(
                (failure) {
                  logout();
                  printE('[AuthRepository] Device creation failed: ${failure.message}');
                  return Left(ServerFailure('Device registration failed'));
                },
                (isSuccess) {
                  if (isSuccess == false) {
                    printE('[AuthRepository] Device creation returned false');
                    logout();
                    return Left(ServerFailure('Device registration failed'));
                  }
                  printI('[AuthRepository] Authentication and device registration successful');
                  return Right(user);
                },
              );
            } else {
              printE('[AuthRepository] Invalid response: missing required data');
              return Left(ServerFailure('Invalid response: missing authentication data'));
            }
          } catch (storageError) {
            printE('[AuthRepository] Failed to save authentication data: $storageError');
            return Left(ServerFailure('Failed to save authentication data'));
          }
        },
      );
    } catch (e) {
      printE('[AuthRepository] Unexpected error during login: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> biometricLogin({
    required String email,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  }) async {
    try {
      printI('[AuthRepository] Starting Biometric Login process for: $email');

      // Check if account is locked due to failed attempts
      final isLocked = await _tokenManager.isAccountLocked();
      if (isLocked) {
        printE('[AuthRepository] Account is locked due to too many failed attempts');
        return Left(ServerFailure('Account is temporarily locked. Please try again later.'));
      }

      // Call remote data source
      final result = await _remoteDataSource.biometricLogin(
        email: email,
        deviceIdentifier: deviceIdentifier,
        isBiometric: isBiometric,
        typeBiometric: typeBiometric,
      );

      return result.fold(
        (failure) async {
          printE('[AuthRepository] Biometric Login failed: ${failure.message}');

          // Record failed Biometric Login attempt
          await _tokenManager.recordLoginAttempt(success: false);

          return Left(failure);
        },
        (authResponse) async {
          printI('[AuthRepository] Biometric Login successful, saving authentication data');

          try {
            // Save authentication data securely
            if (authResponse.accessToken != null &&
                authResponse.refreshToken != null &&
                authResponse.userModel != null) {
              await _saveAuthenticationData(authResponse);

              // Record successful Biometric Login
              await _tokenManager.recordLoginAttempt(success: true);

              // Convert UserModel to User entity
              final user = authResponse.userModel!.toEntity();

              // Get device info
              final DeviceInfoService deviceInfoService = DeviceInfoService.instance;
              final Map<String, dynamic>? deviceInfo = await deviceInfoService.getApiDeviceInfo();

              // Get FCM token với fallback handling
              final String? fcmToken = await _getFCMTokenSafely();

              printI('[AuthRepository] FCM Token: ${fcmToken ?? "Not available"}');

              // Create device model with FCM token
              final deviceModel = DeviceModel.fromJson(deviceInfo ?? <String, dynamic>{}).copyWith(
                userId: user.id,
                pushToken: fcmToken, // Add FCM token to device model
              );

              final loginDevice = await getIt<DeviceUseCase>().createDevice(device: deviceModel.copyWith());

              // Await the result of fold and return its value
              return await loginDevice.fold(
                (failure) {
                  logout();
                  printE('[AuthRepository] Device creation failed: ${failure.message}');
                  return Left(ServerFailure('Device registration failed'));
                },
                (isSuccess) {
                  if (isSuccess == false) {
                    printE('[AuthRepository] Device creation returned false');
                    logout();
                    return Left(ServerFailure('Device registration failed'));
                  }
                  printI('[AuthRepository] Authentication and device registration successful');
                  return Right(user);
                },
              );
            } else {
              printE('[AuthRepository] Invalid response: missing required data');
              return Left(ServerFailure('Invalid response: missing authentication data'));
            }
          } catch (storageError) {
            printE('[AuthRepository] Failed to save authentication data: $storageError');
            return Left(ServerFailure('Failed to save authentication data'));
          }
        },
      );
    } catch (e) {
      printE('[AuthRepository] Unexpected error during Biometric Login: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Get FCM token safely with fallback
  Future<String?> _getFCMTokenSafely() async {
    try {
      // First try to get token from static getter
      String? fcmToken = FirebaseMessagingService.fcmToken;

      if (fcmToken != null && fcmToken.isNotEmpty) {
        return fcmToken;
      }

      printI('[AuthRepository] FCM token not ready, waiting...');

      // If token is not ready, wait a bit and try again
      await Future.delayed(const Duration(milliseconds: 500));
      fcmToken = FirebaseMessagingService.fcmToken;

      if (fcmToken != null && fcmToken.isNotEmpty) {
        return fcmToken;
      }

      // If still not available, try to refresh token
      printI('[AuthRepository] Attempting to refresh FCM token...');
      await FirebaseMessagingService.refreshToken();

      // Wait a bit more for token to be available
      await Future.delayed(const Duration(milliseconds: 1000));
      fcmToken = FirebaseMessagingService.fcmToken;

      if (fcmToken != null && fcmToken.isNotEmpty) {
        return fcmToken;
      }

      printW('[AuthRepository] FCM token still not available after refresh');
      return null;
    } catch (e) {
      printE('[AuthRepository] Error getting FCM token: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      printI('[AuthRepository] Starting logout process');

      // Get current access token
      final accessToken = await _tokenManager.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        // Call remote logout API
        final result = await _remoteDataSource.logout();

        return result.fold(
          (failure) async {
            printE('[AuthRepository] Logout API failed: ${failure.message}');

            // Even if API fails, clear local data
            try {
              await _tokenManager.clearAuthenticationData();
              printI('[AuthRepository] Local authentication data cleared despite API failure');
            } catch (clearError) {
              printE('[AuthRepository] Failed to clear local data: $clearError');
            }

            // Return success even if API failed, because local data is cleared
            return const Right(true);
          },
          (success) async {
            printI('[AuthRepository] Logout API successful, clearing local data');

            try {
              // Clear all authentication data from secure storage
              await _tokenManager.clearAuthenticationData();
              printI('[AuthRepository] All authentication data cleared successfully');
              return const Right(true);
            } catch (clearError) {
              printE('[AuthRepository] Failed to clear authentication data: $clearError');
              return Left(ServerFailure('Logout successful but failed to clear local data'));
            }
          },
        );
      } else {
        printI('[AuthRepository] No access token found, clearing local data only');

        try {
          // No access token, just clear local data
          await _tokenManager.clearAuthenticationData();
          printI('[AuthRepository] Local authentication data cleared');
          return const Right(true);
        } catch (clearError) {
          printE('[AuthRepository] Failed to clear local data: $clearError');
          return Left(ServerFailure('Failed to clear authentication data'));
        }
      }
    } catch (e) {
      printE('[AuthRepository] Unexpected error during logout: $e');

      // Try to clear local data even if there's an unexpected error
      try {
        await _tokenManager.clearAuthenticationData();
        printI('[AuthRepository] Local data cleared after unexpected error');
      } catch (clearError) {
        printE('[AuthRepository] Failed to clear local data after error: $clearError');
      }

      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> refreshToken({required String refreshToken}) async {
    try {
      printI('[AuthRepository] Starting token refresh process');

      // Check if the refresh token is valid and not expired
      final isRefreshTokenValid = await _tokenManager.isRefreshTokenValid();
      if (!isRefreshTokenValid) {
        printE('[AuthRepository] Refresh token is invalid or expired');
        await _tokenManager.clearAuthenticationData();
        return Left(ServerFailure('Refresh token is invalid or expired'));
      }

      // Call remote data source to refresh token
      final result = await _remoteDataSource.refreshToken(refreshToken: refreshToken);

      return result.fold(
        (failure) async {
          printE('[AuthRepository] Token refresh failed: ${failure.message}');

          // If refresh fails with 401, clear all authentication data
          if (failure is ServerFailure &&
              (failure.message.contains('401') ||
                  failure.message.contains('invalid') ||
                  failure.message.contains('expired'))) {
            printI('[AuthRepository] Refresh token invalid, clearing authentication data');
            try {
              await _tokenManager.clearAuthenticationData();
            } catch (clearError) {
              printE('[AuthRepository] Failed to clear authentication data: $clearError');
            }
          }

          return Left(failure);
        },
        (authResponse) async {
          printI('[AuthRepository] Token refresh successful, updating tokens');

          try {
            // Update tokens with new data from AuthResponse
            await _updateTokensFromAuthResponse(authResponse);

            printI('[AuthRepository] Tokens updated successfully');
            return const Right(true);
          } catch (updateError) {
            printE('[AuthRepository] Failed to update tokens: $updateError');
            return Left(ServerFailure('Failed to update authentication tokens'));
          }
        },
      );
    } catch (e) {
      printE('[AuthRepository] Unexpected error during token refresh: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Save complete authentication data to secure storage
  Future<void> _saveAuthenticationData(AuthResponse authResponse) async {
    try {
      if (authResponse.userModel == null ||
          authResponse.accessToken == null ||
          authResponse.refreshToken == null) {
        throw Exception('Missing required authentication data');
      }

      final user = authResponse.userModel!;

      await _tokenManager.saveAuthenticationData(
        accessToken: authResponse.accessToken!,
        refreshToken: authResponse.refreshToken!,
        accessTokenExpiresAt:
            authResponse.accessTokenExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
        refreshTokenExpiresAt:
            authResponse.refreshTokenExpiresAt ?? DateTime.now().add(const Duration(days: 30)),
        sessionExpiresAt:
            authResponse.sessionExpiresAt ?? DateTime.now().add(const Duration(hours: 8)),
        userId: user.userId ?? user.id ?? '',
        userEmail: user.email ?? '',
        userRole: user.role?.apiValue ?? 'USER',
        sessionId: null, // Can be added if provided by API
        deviceId: null, // Can be added if device tracking is implemented
        tokenType: 'Bearer',
        accessTokenExpiresIn: authResponse.accessTokenExpiresIn,
        refreshTokenExpiresIn: authResponse.refreshTokenExpiresIn,
      );

      printI('[AuthRepository] Authentication data saved to secure storage');
    } catch (e) {
      printE('[AuthRepository] Failed to save authentication data: $e');
      rethrow;
    }
  }

  /// Update tokens from AuthResponse (for refresh token scenario)
  Future<void> _updateTokensFromAuthResponse(AuthResponse authResponse) async {
    try {
      // Update access token if provided
      if (authResponse.accessToken != null) {
        final newExpiresAt =
            authResponse.accessTokenExpiresAt ?? DateTime.now().add(const Duration(hours: 1));

        await _tokenManager.updateAccessToken(
          newAccessToken: authResponse.accessToken!,
          newExpiresAt: newExpiresAt,
        );

        printI('[AuthRepository] Access token updated successfully');
      }

      // Update refresh token if provided (some APIs return new refresh token on refresh)
      if (authResponse.refreshToken != null) {
        final currentTime = DateTime.now();
        final newRefreshExpiresAt =
            authResponse.refreshTokenExpiresAt ?? currentTime.add(const Duration(days: 30));

        // Save new refresh token with encryption
        await _tokenManager.saveAuthenticationData(
          accessToken: authResponse.accessToken ?? await _tokenManager.getAccessToken() ?? '',
          refreshToken: authResponse.refreshToken!,
          accessTokenExpiresAt:
              authResponse.accessTokenExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
          refreshTokenExpiresAt: newRefreshExpiresAt,
          sessionExpiresAt:
              authResponse.sessionExpiresAt ?? DateTime.now().add(const Duration(hours: 8)),
          userId: (await _tokenManager.getUserData())?.userId ?? '',
          userEmail: (await _tokenManager.getUserData())?.userEmail ?? '',
          userRole: (await _tokenManager.getUserData())?.userRole ?? 'USER',
          tokenType: 'Bearer',
        );

        printI('[AuthRepository] Refresh token updated successfully');
      }

      // Update user data if provided in refresh response (some APIs include updated user data)
      if (authResponse.userModel != null) {
        final user = authResponse.userModel!;
        final existingUserData = await _tokenManager.getUserData();

        await _tokenManager.saveAuthenticationData(
          accessToken: authResponse.accessToken ?? await _tokenManager.getAccessToken() ?? '',
          refreshToken: authResponse.refreshToken ?? await _tokenManager.getRefreshToken() ?? '',
          accessTokenExpiresAt:
              authResponse.accessTokenExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
          refreshTokenExpiresAt:
              authResponse.refreshTokenExpiresAt ?? DateTime.now().add(const Duration(days: 30)),
          sessionExpiresAt:
              authResponse.sessionExpiresAt ?? DateTime.now().add(const Duration(hours: 8)),
          userId: user.userId ?? user.id ?? existingUserData?.userId ?? '',
          userEmail: user.email ?? existingUserData?.userEmail ?? '',
          userRole: user.role?.apiValue ?? existingUserData?.userRole ?? 'USER',
          sessionId: existingUserData?.sessionId,
          deviceId: existingUserData?.deviceId,
          tokenType: 'Bearer',
        );

        printI('[AuthRepository] User data updated from refresh response');
      }
    } catch (e) {
      printE('[AuthRepository] Failed to update tokens from AuthResponse: $e');
      rethrow;
    }
  }
}
