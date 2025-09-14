import 'dart:async';

import 'package:dio/dio.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/service/secure/secure_token_manager.dart';

class TokenInterceptor extends Interceptor {
  SecureTokenManager? _tokenManager;
  
  // Callback để thông báo khi cần refresh token
  final Function()? onTokenExpired;
  final Function()? onUnauthorized;

  TokenInterceptor({this.onTokenExpired, this.onUnauthorized});

  Future<SecureTokenManager> get _getTokenManager async {
    return _tokenManager ??= await SecureTokenManager.getInstance();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Add API key cho tất cả requests
      options.queryParameters['api-key'] = AppConfigManagerBase.apiKeyNYTimes;

      // Skip auth cho các endpoint không cần authentication
      if (_shouldSkipAuth(options)) {
        return handler.next(options);
      }

      final tokenManager = await _getTokenManager;
      
      // Kiểm tra authentication status
      final authStatus = await tokenManager.getAuthenticationStatus();

      if (authStatus.isAuthenticated) {
        if (authStatus.isAccessTokenValid) {
          // Access token còn valid, thêm vào header
          final accessToken = await tokenManager.getAccessToken();
          if (accessToken?.isNotEmpty == true) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        } else if (authStatus.needsRefresh) {
          // Access token hết hạn, thông báo để UI/Service layer xử lý
          print('TokenInterceptor: Access token expired, needs refresh');
          onTokenExpired?.call();

          // Không thêm token hết hạn vào request
          // Let the request proceed without token, server will return 401
        } else {
          // Cả 2 token đều hết hạn
          print('TokenInterceptor: Both tokens expired, clearing data');
          await tokenManager.clearAuthenticationData();
          onUnauthorized?.call();
        }
      }
      
    } catch (e) {
      print('TokenInterceptor: Error in onRequest - $e');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      if (err.response?.statusCode == 401) {
        print('TokenInterceptor: 401 Unauthorized received');
        
        final tokenManager = await _getTokenManager;
        
        // Clear authentication data khi gặp 401
        await tokenManager.clearAuthenticationData();
        
        // Thông báo để UI/Service layer xử lý (redirect to login, etc.)
        onUnauthorized?.call();
      }
    } catch (e) {
      print('TokenInterceptor: Error handling 401 - $e');
    }

    handler.next(err);
  }

  /// Kiểm tra xem request có cần authentication không
  bool _shouldSkipAuth(RequestOptions options) {
    final path = options.path.toLowerCase();

    // Skip auth cho các endpoint public
    final publicEndpoints = [
      AppConfigManagerBase.apiAuthLogin,
      AppConfigManagerBase.apiAuthRegister,
      AppConfigManagerBase.apiAuthBiometricLogin,
      AppConfigManagerBase.apiAuthRefresh,
      AppConfigManagerBase.apiAuthChangePassword,
      '/health',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Method để cập nhật token mới từ bên ngoài
  Future<void> updateTokenAfterRefresh() async {
    try {
      final tokenManager = await _getTokenManager;
      final authStatus = await tokenManager.getAuthenticationStatus();

      if (authStatus.isAccessTokenValid) {
        print('TokenInterceptor: Token updated successfully');
      }
    } catch (e) {
      print('TokenInterceptor: Error updating token - $e');
    }
  }

  /// Method để dispose resources
  void dispose() {
    _tokenManager = null;
  }
}
