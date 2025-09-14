import 'dart:io';

import 'package:dio/dio.dart';
import 'package:packages/core/service/logger_service.dart';

class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if the error can be retried
    if (_shouldRetry(err) && _getRetryCount(err.requestOptions) < maxRetries) {
      final retryCount = _getRetryCount(err.requestOptions) + 1;
      
      printW('[Retry Interceptor] Retrying request (attempt $retryCount/$maxRetries)');
      
      // Add retry count to request options
      err.requestOptions.extra['retryCount'] = retryCount;
      
      // Wait before retrying
      await Future.delayed(retryDelay * retryCount);
      
      try {
        // Retry the request
        final response = await Dio().request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            responseType: err.requestOptions.responseType,
            contentType: err.requestOptions.contentType,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
            extra: err.requestOptions.extra,
          ),
        );
        
        printS('[Retry Interceptor] Retry successful on attempt $retryCount');
        return handler.resolve(response);
      } catch (e) {
        printE('[Retry Interceptor] Retry failed on attempt $retryCount: $e');
        
        // If this was the last retry, pass the original error
        if (retryCount >= maxRetries) {
          return handler.next(err);
        }
        
        // Otherwise, create a new DioException and retry again
        if (e is DioException) {
          return onError(e, handler);
        }
      }
    }
    
    // If not retryable or max retries reached, pass the error
    return handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    // Retry on network-related errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Retry on server errors (5xx) but not client errors (4xx)
        final statusCode = error.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      case DioExceptionType.unknown:
        // Retry if the underlying error is a SocketException
        return error.error is SocketException;
      default:
        return false;
    }
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['retryCount'] ?? 0;
  }
}