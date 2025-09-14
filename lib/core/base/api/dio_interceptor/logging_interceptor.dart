import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:packages/core/service/logger_service.dart';

/// A custom interceptor for logging API requests, responses, and errors.
class LoggingInterceptor extends Interceptor {
  /// Helper method to format data as JSON string
  String _formatData(dynamic data) {
    if (data == null) return 'null';

    try {
      // Convert to JSON without formatting (compact)
      return jsonEncode(data);
    } catch (e) {
      // If JSON encoding fails, fall back to toString()
      return data.toString();
    }
  }

  /// Helper method to format query parameters as JSON string
  String _formatQueryParams(Map<String, dynamic> queryParams) {
    if (queryParams.isEmpty) return '{}';

    try {
      return jsonEncode(queryParams);
    } catch (e) {
      return queryParams.toString();
    }
  }

  /// Helper method to format headers as JSON string
  String _formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return '{}';

    try {
      return jsonEncode(headers);
    } catch (e) {
      return headers.toString();
    }
  }

  /// Logs the request details before sending it to the server.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    printI(
      '[API]-[REQUEST]'
      '\nURL: ${options.baseUrl}${options.path}'
      '\nMethod: ${options.method}'
      '\nHeaders: ${_formatHeaders(options.headers)}'
      '\nQuery Params: ${_formatQueryParams(options.queryParameters)}'
      '\nRequest Data: ${_formatData(options.data)}',
    );
    handler.next(options);
  }

  /// Logs the response details after receiving a response from the server.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    printS(
      '[API]-[RESPONSE]'
      '\nStatus Code: ${response.statusCode}'
      '\nURL: ${response.requestOptions.baseUrl}${response.requestOptions.path}'
      '\nMethod: ${response.requestOptions.method}'
      '\nQuery Params: ${_formatQueryParams(response.requestOptions.queryParameters)}'
      '\nResponse Data: ${_formatData(response.data)}',
    );
    handler.next(response);
  }

  /// Logs the error details when an API call fails.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      printE(
        '[API]-[ERROR]'
        '\nStatus Code: ${err.response?.statusCode}'
        '\nURL: ${err.requestOptions.baseUrl}${err.requestOptions.path}'
        '\nMethod: ${err.requestOptions.method}'
        '\nError Type: ${err.type}'
        '\nError Data: ${_formatData(err.response?.data)}'
        '\nError Message: ${err.message}',
      );

      // Log thêm chi tiết cho DioExceptionType.unknown
      if (err.type == DioExceptionType.unknown) {
        printE(
          '[API]-[ERROR] Unknown error details:'
          '\nError object: ${err.error}'
          '\nOriginal exception: ${err.error.runtimeType}',
        );
      }
    } catch (logError) {
      printE('[API]-[ERROR] Failed to log error: $logError');
    }
    handler.next(err);
  }
}
