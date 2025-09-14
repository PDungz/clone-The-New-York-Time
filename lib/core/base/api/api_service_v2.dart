import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app/core/base/api/dio_client.dart';
import 'package:news_app/core/base/api/model/api_exception.dart';
import 'package:news_app/core/base/api/model/api_response_v2.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:packages/core/service/logger_service.dart';

class ApiServiceV2 {
  final DioClient _dioClient = DioClient.instance;
  static ApiServiceV2? _instance;

  ApiServiceV2._() {
    _initializeBaseUrl();
  }

  // Singleton pattern với auto-initialization
  static ApiServiceV2 get instance {
    _instance ??= ApiServiceV2._();
    return _instance!;
  }

  // Tự động set baseUrl khi khởi tạo
  void _initializeBaseUrl() {
    _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrl);
  }

  // Method để thay đổi baseUrl nếu cần
  void updateBaseUrl(String newBaseUrl) {
    _dioClient.updateBaseUrl(newBaseUrl);
  }

  // Method để lấy baseUrl hiện tại
  String get currentBaseUrl => _dioClient.currentBaseUrl;

  // GET request with enhanced error handling
  Future<ApiResponseV2<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      // Pre-flight connectivity check
      await _checkConnectivity();

      final response = await _dioClient.dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponseV2.error('Network connection failed. Please check your internet connection.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponseV2.error('Unexpected error occurred: ${e.toString()}', statusCode: 500);
    }
  }

  // POST request with enhanced error handling
  Future<ApiResponseV2<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponseV2.error('Network connection failed. Please check your internet connection.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponseV2.error('Unexpected error occurred: ${e.toString()}', statusCode: 500);
    }
  }

  // PUT request with enhanced error handling
  Future<ApiResponseV2<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponseV2.error('Network connection failed. Please check your internet connection.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponseV2.error('Unexpected error occurred: ${e.toString()}', statusCode: 500);
    }
  }

  // DELETE request with enhanced error handling
  Future<ApiResponseV2<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.delete(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponseV2.error('Network connection failed. Please check your internet connection.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponseV2.error('Unexpected error occurred: ${e.toString()}', statusCode: 500);
    }
  }

  // PATCH request with enhanced error handling
  Future<ApiResponseV2<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.patch(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponseV2.error('Network connection failed. Please check your internet connection.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponseV2.error('Unexpected error occurred: ${e.toString()}', statusCode: 500);
    }
  }

  // Upload file with enhanced error handling
  Future<ApiResponseV2<T>> uploadFile<T>(String path, String filePath, {String? filename, Map<String, dynamic>? data, ProgressCallback? onSendProgress, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      await _checkConnectivity();

      FormData formData = FormData.fromMap({...?data, 'file': await MultipartFile.fromFile(filePath, filename: filename)});

      final response = await _dioClient.dio.post(path, data: formData, onSendProgress: onSendProgress, cancelToken: cancelToken);

      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error during upload: $e');
      return ApiResponseV2.error('Upload failed due to network connection issue.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Upload error: $e');
      return ApiResponseV2.error('Upload failed: ${e.toString()}', statusCode: 500);
    }
  }

  // Download file with enhanced error handling
  Future<ApiResponseV2<String>> downloadFile(String path, String savePath, {Map<String, dynamic>? queryParameters, ProgressCallback? onReceiveProgress, CancelToken? cancelToken}) async {
    try {
      await _checkConnectivity();

      await _dioClient.dio.download(path, savePath, queryParameters: queryParameters, onReceiveProgress: onReceiveProgress, cancelToken: cancelToken);

      return ApiResponseV2.success(savePath, message: 'Download completed', statusCode: 200);
    } on SocketException catch (e) {
      printE('[API Service] Network error during download: $e');
      return ApiResponseV2.error('Download failed due to network connection issue.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<String>(e);
    } catch (e) {
      printE('[API Service] Download error: $e');
      return ApiResponseV2.error('Download failed: ${e.toString()}', statusCode: 500);
    }
  }

  // Parse response using ApiResponseV2.fromJson
  Future<ApiResponseV2<T>> parseResponse<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, T Function(dynamic)? dataParser}) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

      // Parse using ApiResponseV2.fromJson if response data is a Map
      if (response.data is Map<String, dynamic>) {
        return ApiResponseV2<T>.fromJson(response.data as Map<String, dynamic>, dataParser: dataParser);
      }

      // Fallback to direct parsing
      return _handleSuccessResponse<T>(response, dataParser: dataParser);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponseV2.error('Network connection failed. Please check your internet connection.', statusCode: -1);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponseV2.error('Unexpected error occurred: ${e.toString()}', statusCode: 500);
    }
  }

  // Connectivity check method
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw SocketException('No internet connection');
      }
    } on SocketException {
      throw SocketException('No internet connection available');
    } catch (e) {
      throw SocketException('Network connectivity check failed');
    }
  }

  // Handle successful response
  ApiResponseV2<T> _handleSuccessResponse<T>(Response response, {T Function(dynamic)? dataParser}) {
    T? parsedData;

    if (response.data != null && dataParser != null) {
      parsedData = dataParser(response.data);
    } else if (response.data != null) {
      parsedData = response.data as T?;
    }

    return ApiResponseV2.success(parsedData as T, statusCode: response.statusCode, message: 'Request completed successfully');
  }

  // Enhanced DioException handling
  ApiResponseV2<T> _handleDioError<T>(DioException dioException) {
    printE('[API Service] DioException: ${dioException.type} - ${dioException.message}');

    // Handle specific connection errors
    switch (dioException.type) {
      case DioExceptionType.connectionError:
        if (dioException.message?.contains('Failed host lookup') == true) {
          return ApiResponseV2.error(
            'Unable to reach the server. Please check your internet connection or try again later.',
            statusCode: -2, // Custom code for DNS failure
          );
        }
        return ApiResponseV2.error('Connection failed. Please check your internet connection.', statusCode: -1);

      case DioExceptionType.connectionTimeout:
        return ApiResponseV2.error('Connection timeout. Please check your internet connection and try again.', statusCode: 408);

      case DioExceptionType.receiveTimeout:
        return ApiResponseV2.error('Server response timeout. Please try again.', statusCode: 408);

      case DioExceptionType.sendTimeout:
        return ApiResponseV2.error('Request timeout. Please try again.', statusCode: 408);

      default:
        final apiException = ApiException.fromDioException(dioException);
        return ApiResponseV2.error(apiException.message, statusCode: apiException.statusCode);
    }
  }
}

// Extension methods for easier usage
extension ApiServiceExtensions on ApiServiceV2 {
  // Get with automatic model parsing
  Future<ApiResponseV2<T>> getModel<T>(String path, T Function(Map<String, dynamic>) fromJson, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return get<T>(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken, dataParser: (data) => fromJson(data as Map<String, dynamic>));
  }

  // Post with automatic model parsing
  Future<ApiResponseV2<T>> postModel<T>(String path, T Function(Map<String, dynamic>) fromJson, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, dataParser: (responseData) => fromJson(responseData as Map<String, dynamic>));
  }

  // Get list with automatic model parsing
  Future<ApiResponseV2<List<T>>> getList<T>(String path, T Function(Map<String, dynamic>) fromJson, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    return get<List<T>>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      dataParser: (data) {
        if (data is List) {
          return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
        }
        throw Exception('Expected List but got ${data.runtimeType}');
      },
    );
  }
}
