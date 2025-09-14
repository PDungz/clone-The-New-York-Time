// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:news_app/core/base/api/dio_client.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/auth/data/model/auth_response.dart';
import 'package:packages/core/service/logger_service.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, AuthResponse>> login({required String username, required String password});
  Future<Either<Failure, AuthResponse>> biometricLogin({
    required String email,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  });
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthResponse>> refreshToken({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient = DioClient.instance;

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);

      printI('[Login DataSource] Starting login request for username: $username');

      final response = await _dioClient.dio.post(
        AppConfigManagerBase.apiAuthLogin,
        data: {"email": username, "password": password},
      );

      printI('[Login DataSource] Response status: ${response.statusCode}');
      printI('[Login DataSource] Response data: ${response.data}');

      // Check for successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final authResponse = AuthResponse.fromJson(response.data);

          // Validate response
          if (authResponse.isSuccess && authResponse.userModel != null) {
            printI(
              '[Login DataSource] Login successful for user: ${authResponse.userModel!.email}',
            );
            return Right(authResponse);
          } else {
            printE('[Login DataSource] Login failed - invalid response structure');
            return Left(ServerFailure(authResponse.message ?? 'Login failed'));
          }
        } catch (parseError) {
          printE('[Login DataSource] JSON parsing error: $parseError');
          return Left(ServerFailure('Failed to parse server response'));
        }
      } else {
        printE('[Login DataSource] Server error - Status: ${response.statusCode}');
        return Left(ServerFailure('Server error: ${response.statusCode}'));
      }
    } on DioException catch (dioError) {
      printE('[Login DataSource] Dio Exception: ${dioError.type} - ${dioError.message}');

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Left(NetworkFailure('Connection timeout'));

        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          final responseData = dioError.response?.data;

          if (statusCode == 401) {
            return Left(ServerFailure('Invalid username or password'));
          } else if (statusCode == 422) {
            final message = responseData?['message'] ?? 'Validation failed';
            return Left(ValidationFailure(message));
          } else {
            return Left(ServerFailure('Server error: $statusCode'));
          }

        case DioExceptionType.cancel:
          return Left(NetworkFailure('Request cancelled'));

        case DioExceptionType.connectionError:
          return Left(NetworkFailure('No internet connection'));

        case DioExceptionType.unknown:
          // Xử lý lỗi unknown - thường là connection refused, server không khả dụng
          if (dioError.message?.contains('Connection refused') == true ||
              dioError.message?.contains('connection error') == true) {
            return Left(NetworkFailure('Server is not available. Please try again later.'));
          } else if (dioError.message?.contains('SocketException') == true) {
            return Left(NetworkFailure('Network connection error'));
          } else {
            return Left(NetworkFailure('Unknown network error: ${dioError.message}'));
          }

        default:
          return Left(NetworkFailure('Network error occurred'));
      }
    } catch (e) {
      printE('[Login DataSource] Unexpected exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> biometricLogin({
    required String email,
    required bool isBiometric,
    required String deviceIdentifier,
    required String typeBiometric,
  }) async {
    try {
      _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);

      printI('[Biometric Login DataSource] Starting Biometric login request for email: $email');

      final response = await _dioClient.dio.post(
        AppConfigManagerBase.apiAuthBiometricLogin,
        data: {
          "email": email,
          "isBiometric": isBiometric,
          "deviceIdentifier": deviceIdentifier,
          "typeBiometric": typeBiometric,
        },
      );

      printI('[Biometric Login DataSource] Response status: ${response.statusCode}');
      printI('[Biometric Login DataSource] Response data: ${response.data}');

      // Check for successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final authResponse = AuthResponse.fromJson(response.data);

          // Validate response
          if (authResponse.isSuccess && authResponse.userModel != null) {
            printI(
              '[Biometric Login DataSource] Biometric Login successful for user: ${authResponse.userModel!.email}',
            );
            return Right(authResponse);
          } else {
            printE('[Biometric Login DataSource] Biometric Login failed - invalid response structure');
            return Left(ServerFailure(authResponse.message ?? 'Biometric Login failed'));
          }
        } catch (parseError) {
          printE('[Biometric Login DataSource] JSON parsing error: $parseError');
          return Left(ServerFailure('Failed to parse server response'));
        }
      } else {
        printE('[Biometric Login DataSource] Server error - Status: ${response.statusCode}');
        return Left(ServerFailure('Server error: ${response.statusCode}'));
      }
    } on DioException catch (dioError) {
      printE('[Biometric Login DataSource] Dio Exception: ${dioError.type} - ${dioError.message}');

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Left(NetworkFailure('Connection timeout'));

        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          final responseData = dioError.response?.data;

          if (statusCode == 401) {
            return Left(ServerFailure('Invalid email or password'));
          } else if (statusCode == 422) {
            final message = responseData?['message'] ?? 'Validation failed';
            return Left(ValidationFailure(message));
          } else {
            return Left(ServerFailure('Server error: $statusCode'));
          }

        case DioExceptionType.cancel:
          return Left(NetworkFailure('Request cancelled'));

        case DioExceptionType.connectionError:
          return Left(NetworkFailure('No internet connection'));

        case DioExceptionType.unknown:
          // Xử lý lỗi unknown - thường là connection refused, server không khả dụng
          if (dioError.message?.contains('Connection refused') == true ||
              dioError.message?.contains('connection error') == true) {
            return Left(NetworkFailure('Server is not available. Please try again later.'));
          } else if (dioError.message?.contains('SocketException') == true) {
            return Left(NetworkFailure('Network connection error'));
          } else {
            return Left(NetworkFailure('Unknown network error: ${dioError.message}'));
          }

        default:
          return Left(NetworkFailure('Network error occurred'));
      }
    } catch (e) {
      printE('[Biometric Login DataSource] Unexpected exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);

      printI('[Logout DataSource] Starting logout request');

      final response = await _dioClient.dio.post(AppConfigManagerBase.apiAuthLogout);

      printI('[Logout DataSource] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        printI('[Logout DataSource] Logout successful');
        return const Right(true);
      } else {
        printE('[Logout DataSource] Logout failed - Status: ${response.statusCode}');
        return Left(ServerFailure('Logout failed'));
      }
    } on DioException catch (dioError) {
      printE('[Logout DataSource] Dio Exception: ${dioError.type} - ${dioError.message}');

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          // Logout có thể fail nhưng vẫn consider là success từ phía client
          printW('[Logout DataSource] Network timeout, but considering logout successful');
          return const Right(true);

        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          if (statusCode == 401) {
            // Token đã invalid, consider logout successful
            printI('[Logout DataSource] Token already invalid, logout successful');
            return const Right(true);
          } else {
            printE('[Logout DataSource] Server error during logout: $statusCode');
            return Left(ServerFailure('Logout failed: Server error $statusCode'));
          }

        case DioExceptionType.connectionError:
          // Không có internet, nhưng vẫn clear local data
          printW('[Logout DataSource] No internet connection, but considering logout successful');
          return const Right(true);

        case DioExceptionType.unknown:
          // Đối với logout, unknown error vẫn consider là success
          printW(
            '[Logout DataSource] Unknown error during logout, but considering logout successful',
          );
          return const Right(true);

        default:
          printW('[Logout DataSource] Network error, but considering logout successful');
          return const Right(true);
      }
    } catch (e) {
      printE('[Logout DataSource] Unexpected exception: $e');
      // Logout có thể fail nhưng vẫn consider là success từ phía client
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken({required String refreshToken}) async {
    try {
      _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);

      printI('[Refresh DataSource] Starting refresh token request');

      final response = await _dioClient.dio.post(
        AppConfigManagerBase.apiAuthRefresh,
        queryParameters: {"refresh": refreshToken},
      );

      printI('[Refresh DataSource] Response status: ${response.statusCode}');
      printI('[Refresh DataSource] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final authResponse = AuthResponse.fromJson(response.data);

          // Validate response - refresh token response might not include user data
          if (authResponse.isSuccess && authResponse.accessToken != null) {
            printI('[Refresh DataSource] Token refresh successful');
            return Right(authResponse);
          } else {
            printE('[Refresh DataSource] Token refresh failed - invalid response structure');
            return Left(ServerFailure(authResponse.message ?? 'Token refresh failed'));
          }
        } catch (parseError) {
          printE('[Refresh DataSource] JSON parsing error: $parseError');
          return Left(ServerFailure('Failed to parse refresh token response'));
        }
      } else {
        printE('[Refresh DataSource] Server error - Status: ${response.statusCode}');
        return Left(ServerFailure('Server error: ${response.statusCode}'));
      }
    } on DioException catch (dioError) {
      printE('[Refresh DataSource] Dio Exception: ${dioError.type} - ${dioError.message}');

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Left(NetworkFailure('Connection timeout during token refresh'));

        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          final responseData = dioError.response?.data;

          if (statusCode == 401) {
            return Left(ServerFailure('Refresh token is invalid or expired'));
          } else if (statusCode == 422) {
            final message = responseData?['message'] ?? 'Validation failed';
            return Left(ValidationFailure(message));
          } else {
            return Left(ServerFailure('Server error: $statusCode'));
          }

        case DioExceptionType.cancel:
          return Left(NetworkFailure('Request cancelled'));

        case DioExceptionType.connectionError:
          return Left(NetworkFailure('No internet connection'));

        case DioExceptionType.unknown:
          // Xử lý lỗi unknown cho refresh token
          if (dioError.message?.contains('Connection refused') == true ||
              dioError.message?.contains('connection error') == true) {
            return Left(NetworkFailure('Server is not available. Please try again later.'));
          } else if (dioError.message?.contains('SocketException') == true) {
            return Left(NetworkFailure('Network connection error'));
          } else {
            return Left(
              NetworkFailure('Unknown network error during token refresh: ${dioError.message}'),
            );
          }

        default:
          return Left(NetworkFailure('Network error occurred'));
      }
    } catch (e) {
      printE('[Refresh DataSource] Unexpected exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}