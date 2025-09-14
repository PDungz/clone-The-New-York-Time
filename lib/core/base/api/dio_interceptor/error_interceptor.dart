import 'package:dio/dio.dart';
import 'package:packages/core/service/logger_service.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    printE(
      '[API]-[ERROR]'
      '\nStatus Code: ${err.response?.statusCode}'
      '\nURL: ${err.requestOptions.baseUrl}${err.requestOptions.path}'
      '\nMethod: ${err.requestOptions.method}'
      '\nError Type: ${err.type}'
      '\nError Data: ${err.response?.data}'
      '\nError Message: ${err.message}',
    );

    // Handle specific error cases
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - redirect to login
      _handleUnauthorized();
    } else if (err.response?.statusCode == 403) {
      // Handle forbidden
      _handleForbidden();
    }

    super.onError(err, handler);
  }

  void _handleUnauthorized() {
    // Clear user session and redirect to login
    printW('[API] Unauthorized - clearing session');
    // You can add your logout logic here
  }

  void _handleForbidden() {
    printW('[API] Forbidden - insufficient permissions');
  }
}
