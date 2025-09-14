import 'package:dio/dio.dart';
import 'package:news_app/core/base/api/dio_interceptor/error_interceptor.dart';
import 'package:news_app/core/base/api/dio_interceptor/logging_interceptor.dart';
import 'package:news_app/core/base/api/dio_interceptor/token_interceptor.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';

class DioClient {
  late Dio dio;
  static DioClient? _instance;

  DioClient._() {
    initDio();
  }

  // Singleton pattern
  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  void initDio() {
    dio = Dio();
    dio.options = BaseOptions(
      baseUrl: AppConfigManagerBase.apiBaseUrl,
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30), // Reduced for faster failure detection
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        // Accept status codes less than 500
        return status != null && status < 500;
      },
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors in order
    dio.interceptors.add(LoggingInterceptor());
    dio.interceptors.add(TokenInterceptor());
    // dio.interceptors.add(RetryInterceptor()); // Add retry interceptor
    dio.interceptors.add(ErrorInterceptor());
  }

  // Method to update base URL dynamically
  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }

  // Method to get current base URL
  String get currentBaseUrl => dio.options.baseUrl;

  // Method to update timeout
  void updateTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) dio.options.connectTimeout = connectTimeout;
    if (receiveTimeout != null) dio.options.receiveTimeout = receiveTimeout;
    if (sendTimeout != null) dio.options.sendTimeout = sendTimeout;
  }

  // Method to test connectivity
  Future<bool> testConnectivity() async {
    try {
      final response = await dio.get(
        '/health', // Assuming you have a health check endpoint
        options: Options(
          receiveTimeout: Duration(seconds: 5),
          sendTimeout: Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}