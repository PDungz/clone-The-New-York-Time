import 'dart:io';

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final String? errorType;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.errorType,
  });

  factory ApiException.fromDioException(DioException dioException) {
    String message;
    String errorType;
    int? statusCode = dioException.response?.statusCode;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message =
            'Connection timeout. Please check your internet connection and try again.';
        errorType = 'CONNECTION_TIMEOUT';
        statusCode = 408;
        break;

      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        errorType = 'SEND_TIMEOUT';
        statusCode = 408;
        break;

      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout. Please try again.';
        errorType = 'RECEIVE_TIMEOUT';
        statusCode = 408;
        break;

      case DioExceptionType.badResponse:
        message = _handleStatusCode(statusCode);
        errorType = 'BAD_RESPONSE';
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        errorType = 'CANCELLED';
        statusCode = -3;
        break;

      case DioExceptionType.connectionError:
        // Handle specific connection errors
        if (dioException.message?.contains('Failed host lookup') == true) {
          message =
              'Unable to reach the server. Please check your internet connection or try again later.';
          errorType = 'DNS_LOOKUP_FAILED';
          statusCode = -2;
        } else if (dioException.message?.contains('Network is unreachable') ==
            true) {
          message =
              'Network is unreachable. Please check your internet connection.';
          errorType = 'NETWORK_UNREACHABLE';
          statusCode = -1;
        } else if (dioException.message?.contains('Connection refused') ==
            true) {
          message = 'Server connection refused. Please try again later.';
          errorType = 'CONNECTION_REFUSED';
          statusCode = -4;
        } else {
          message = 'Connection error. Please check your internet connection.';
          errorType = 'CONNECTION_ERROR';
          statusCode = -1;
        }
        break;

      case DioExceptionType.badCertificate:
        message = 'Security certificate error. Please try again later.';
        errorType = 'BAD_CERTIFICATE';
        statusCode = -5;
        break;

      case DioExceptionType.unknown:
      // ignore: unreachable_switch_default
      default:
        // Try to extract more specific error information
        if (dioException.error is SocketException) {
          message =
              'Network connection failed. Please check your internet connection.';
          errorType = 'SOCKET_EXCEPTION';
          statusCode = -1;
        } else {
          message =
              dioException.message ?? 'Something went wrong. Please try again.';
          errorType = 'UNKNOWN';
          statusCode = -999;
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: dioException.response?.data,
      errorType: errorType,
    );
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found. The requested content doesn\'t exist.';
      case 408:
        return 'Request timeout. Please try again.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. The server took too long to respond.';
      default:
        return 'Server error (${statusCode ?? 'Unknown'}). Please try again later.';
    }
  }

  // Helper method to check if error is network-related
  bool get isNetworkError {
    return errorType == 'CONNECTION_ERROR' ||
        errorType == 'DNS_LOOKUP_FAILED' ||
        errorType == 'NETWORK_UNREACHABLE' ||
        errorType == 'CONNECTION_REFUSED' ||
        errorType == 'SOCKET_EXCEPTION' ||
        errorType == 'CONNECTION_TIMEOUT';
  }

  // Helper method to check if error can be retried
  bool get canRetry {
    return isNetworkError ||
        errorType == 'RECEIVE_TIMEOUT' ||
        errorType == 'SEND_TIMEOUT' ||
        statusCode == 502 ||
        statusCode == 503 ||
        statusCode == 504;
  }

  @override
  String toString() {
    return 'ApiException: $message (Type: $errorType, Status: $statusCode)';
  }
}
