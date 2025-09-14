import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:packages/core/service/logger_service.dart';

class DioExceptionHandler {
  DioExceptionHandler._();

  /// Xử lý DioException và trả về Either<Failure, T>
  ///
  /// [dioError] - DioException cần xử lý
  /// [operation] - Tên operation để logging (optional)
  /// [context] - Context thêm cho logging (optional)
  static Either<Failure, T> handle<T>(DioException dioError, {String? operation, String? context}) {
    final operationName = operation ?? 'API call';
    final contextInfo = context != null ? ' [$context]' : '';

    printE(
      '[DioExceptionHandler]$contextInfo Dio Exception in $operationName: ${dioError.type} - ${dioError.message}',
    );

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Left(NetworkFailure('Connection timeout during $operationName'));

      case DioExceptionType.badResponse:
        return _handleBadResponse<T>(dioError, operationName);

      case DioExceptionType.cancel:
        return Left(NetworkFailure('Request cancelled'));

      case DioExceptionType.connectionError:
        return Left(NetworkFailure('No internet connection'));

      case DioExceptionType.unknown:
        return _handleUnknownError<T>(dioError, operationName);

      default:
        return Left(NetworkFailure('Network error occurred during $operationName'));
    }
  }

  /// Xử lý BadResponse exceptions
  static Either<Failure, T> _handleBadResponse<T>(DioException dioError, String operationName) {
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;

    switch (statusCode) {
      case 400:
        final message = _extractErrorMessage(responseData, 'Bad request');
        return Left(ValidationFailure(message));

      case 401:
        return Left(ServerFailure('Unauthorized access'));

      case 403:
        return Left(ServerFailure('Access forbidden'));

      case 404:
        return Left(ServerFailure('Resource not found'));

      case 422:
        final message = _extractErrorMessage(responseData, 'Validation failed');
        return Left(ValidationFailure(message));

      case 429:
        return Left(NetworkFailure('Too many requests. Please try again later.'));

      case 500:
        return Left(ServerFailure('Internal server error'));

      case 502:
        return Left(NetworkFailure('Bad gateway. Server is temporarily unavailable.'));

      case 503:
        return Left(NetworkFailure('Service unavailable. Please try again later.'));

      case 504:
        return Left(NetworkFailure('Gateway timeout. Please try again.'));

      default:
        return Left(ServerFailure('Server error: $statusCode'));
    }
  }

  /// Xử lý Unknown exceptions
  static Either<Failure, T> _handleUnknownError<T>(DioException dioError, String operationName) {
    final message = dioError.message?.toLowerCase() ?? '';

    if (message.contains('connection refused') || message.contains('connection error')) {
      return Left(NetworkFailure('Server is not available. Please try again later.'));
    } else if (message.contains('socketexception')) {
      return Left(NetworkFailure('Network connection error'));
    } else if (message.contains('handshake')) {
      return Left(NetworkFailure('SSL/TLS connection error'));
    } else if (message.contains('host lookup failed')) {
      return Left(NetworkFailure('Unable to resolve server address'));
    } else {
      return Left(NetworkFailure('Unknown network error: ${dioError.message}'));
    }
  }

  /// Trích xuất error message từ response data
  static String _extractErrorMessage(dynamic responseData, String defaultMessage) {
    if (responseData == null) return defaultMessage;

    try {
      // Thử các pattern phổ biến của error response
      if (responseData is Map<String, dynamic>) {
        // Pattern 1: {"message": "error message"}
        if (responseData['message'] is String) {
          return responseData['message'];
        }

        // Pattern 2: {"error": "error message"}
        if (responseData['error'] is String) {
          return responseData['error'];
        }

        // Pattern 3: {"errors": ["error1", "error2"]}
        if (responseData['errors'] is List) {
          final errors = responseData['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.join(', ');
          }
        }

        // Pattern 4: {"details": "error message"}
        if (responseData['details'] is String) {
          return responseData['details'];
        }

        // Pattern 5: {"data": {"message": "error message"}}
        if (responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data['message'] is String) {
            return data['message'];
          }
        }
      }

      // Nếu không tìm thấy pattern nào, return toString của response
      return responseData.toString();
    } catch (e) {
      printW('[DioExceptionHandler] Failed to extract error message: $e');
      return defaultMessage;
    }
  }

  /// Kiểm tra xem có phải lỗi authentication không
  static bool isAuthError(DioException dioError) {
    return dioError.response?.statusCode == 401;
  }

  /// Kiểm tra xem có phải lỗi validation không
  static bool isValidationError(DioException dioError) {
    final statusCode = dioError.response?.statusCode;
    return statusCode == 400 || statusCode == 422;
  }

  /// Kiểm tra xem có phải lỗi network không
  static bool isNetworkError(DioException dioError) {
    return dioError.type == DioExceptionType.connectionTimeout ||
        dioError.type == DioExceptionType.sendTimeout ||
        dioError.type == DioExceptionType.receiveTimeout ||
        dioError.type == DioExceptionType.connectionError;
  }

  /// Kiểm tra xem có phải lỗi server không
  static bool isServerError(DioException dioError) {
    final statusCode = dioError.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }

  /// Log chi tiết về DioException (for debugging)
  static void logDioException(DioException dioError, {String? operation, String? context}) {
    final operationName = operation ?? 'API call';
    final contextInfo = context != null ? ' [$context]' : '';

    printE('[DioExceptionHandler]$contextInfo Exception Details for $operationName:');
    printE('  Type: ${dioError.type}');
    printE('  Message: ${dioError.message}');

    if (dioError.response != null) {
      printE('  Status Code: ${dioError.response!.statusCode}');
      printE('  Status Message: ${dioError.response!.statusMessage}');
      printE('  Headers: ${dioError.response!.headers}');
      printE('  Data: ${dioError.response!.data}');
    }

    printE('  Request URL: ${dioError.requestOptions.uri}');
    printE('  Request Method: ${dioError.requestOptions.method}');
    printE('  Request Headers: ${dioError.requestOptions.headers}');
    printE('  Request Data: ${dioError.requestOptions.data}');
  }
}

/// Extension method để sử dụng DioExceptionHandler dễ dàng hơn
extension DioExceptionHandling on DioException {
  /// Handle exception với operation name
  Either<Failure, T> handle<T>([String? operation, String? context]) {
    return DioExceptionHandler.handle<T>(this, operation: operation, context: context);
  }

  /// Extract error message từ response
  String get errorMessage =>
      DioExceptionHandler._extractErrorMessage(response?.data, message ?? 'Unknown error');

  /// Check if it's auth error
  bool get isAuthError => DioExceptionHandler.isAuthError(this);

  /// Check if it's validation error
  bool get isValidationError => DioExceptionHandler.isValidationError(this);

  /// Check if it's network error
  bool get isNetworkError => DioExceptionHandler.isNetworkError(this);

  /// Check if it's server error
  bool get isServerError => DioExceptionHandler.isServerError(this);

  /// Log detailed exception info
  void logDetails([String? operation, String? context]) {
    DioExceptionHandler.logDioException(this, operation: operation, context: context);
  }
}
