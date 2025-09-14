import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app/core/base/api/dio_client.dart';
import 'package:news_app/core/base/api/model/api_exception.dart';
import 'package:news_app/core/base/api/model/api_response.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:packages/core/service/logger_service.dart';

class ApiService {
  final DioClient _dioClient = DioClient.instance;
  static ApiService? _instance;

  ApiService._() {
    _initializeBaseUrl();
  }

  // Singleton pattern với auto-initialization
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  // Tự động set baseUrl khi khởi tạo
  void _initializeBaseUrl() {
    _dioClient.updateBaseUrl(AppConfigManagerBase.apiBaseUrlNYT);
  }

  // Method để thay đổi baseUrl nếu cần
  void updateBaseUrl(String newBaseUrl) {
    _dioClient.updateBaseUrl(newBaseUrl);
  }

  // GET request with enhanced error handling
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      // Pre-flight connectivity check
      await _checkConnectivity();

      final response = await _dioClient.dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleSuccessResponse<T>(response);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponse.error('Unexpected error occurred: ${e.toString()}');
    }
  }

  // POST request with enhanced error handling
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleSuccessResponse<T>(response);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponse.error('Unexpected error occurred: ${e.toString()}');
    }
  }

  // PUT request with enhanced error handling
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleSuccessResponse<T>(response);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponse.error('Unexpected error occurred: ${e.toString()}');
    }
  }

  // DELETE request with enhanced error handling
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleSuccessResponse<T>(response);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponse.error('Unexpected error occurred: ${e.toString()}');
    }
  }

  // PATCH request with enhanced error handling
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dioClient.dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleSuccessResponse<T>(response);
    } on SocketException catch (e) {
      printE('[API Service] Network error: $e');
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Unexpected error: $e');
      return ApiResponse.error('Unexpected error occurred: ${e.toString()}');
    }
  }

  // Upload file with enhanced error handling
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? filename,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _checkConnectivity();

      FormData formData = FormData.fromMap({
        ...?data,
        'file': await MultipartFile.fromFile(filePath, filename: filename),
      });

      final response = await _dioClient.dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _handleSuccessResponse<T>(response);
    } on SocketException catch (e) {
      printE('[API Service] Network error during upload: $e');
      return ApiResponse.error(
        'Upload failed due to network connection issue.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      printE('[API Service] Upload error: $e');
      return ApiResponse.error('Upload failed: ${e.toString()}');
    }
  }

  // Download file with enhanced error handling
  Future<ApiResponse<String>> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _checkConnectivity();

      await _dioClient.dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse.success(savePath, message: 'Download completed');
    } on SocketException catch (e) {
      printE('[API Service] Network error during download: $e');
      return ApiResponse.error(
        'Download failed due to network connection issue.',
        statusCode: -1,
      );
    } on DioException catch (e) {
      return _handleDioError<String>(e);
    } catch (e) {
      printE('[API Service] Download error: $e');
      return ApiResponse.error('Download failed: ${e.toString()}');
    }
  }

  // Connectivity check method
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 5));
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
  ApiResponse<T> _handleSuccessResponse<T>(Response<T> response) {
    return ApiResponse.success(
      response.data as T,
      statusCode: response.statusCode,
    );
  }

  // Enhanced DioException handling
  ApiResponse<T> _handleDioError<T>(DioException dioException) {
    printE(
      '[API Service] DioException: ${dioException.type} - ${dioException.message}',
    );

    // Handle specific connection errors
    switch (dioException.type) {
      case DioExceptionType.connectionError:
        if (dioException.message?.contains('Failed host lookup') == true) {
          return ApiResponse.error(
            'Unable to reach the server. Please check your internet connection or try again later.',
            statusCode: -2, // Custom code for DNS failure
          );
        }
        return ApiResponse.error(
          'Connection failed. Please check your internet connection.',
          statusCode: -1,
        );

      case DioExceptionType.connectionTimeout:
        return ApiResponse.error(
          'Connection timeout. Please check your internet connection and try again.',
          statusCode: 408,
        );

      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(
          'Server response timeout. Please try again.',
          statusCode: 408,
        );

      case DioExceptionType.sendTimeout:
        return ApiResponse.error(
          'Request timeout. Please try again.',
          statusCode: 408,
        );

      default:
        final apiException = ApiException.fromDioException(dioException);
        return ApiResponse.error(
          apiException.message,
          statusCode: apiException.statusCode,
        );
    }
  }
}