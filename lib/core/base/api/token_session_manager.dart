import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app/core/service/secure/secure_token_manager.dart';
import 'package:packages/core/service/logger_service.dart';

class TokenSessionManager {
  static TokenSessionManager? _instance;
  static TokenSessionManager get instance => _instance ??= TokenSessionManager._();

  TokenSessionManager._();

  Timer? _tokenCheckTimer;
  SecureTokenManager? _tokenManager;

  // Callback when token expires
  VoidCallback? _onTokenExpired;

  bool _isMonitoring = false;

  /// Initialize with callback for token expiry
  Future<void> initialize({VoidCallback? onTokenExpired}) async {
    _tokenManager = await SecureTokenManager.getInstance();
    _onTokenExpired = onTokenExpired;
    printI('[TokenSessionManager] Initialized');
  }

  /// Start monitoring token expiry
  Future<void> startTokenMonitoring() async {
    if (_tokenManager == null) {
      printE('[TokenSessionManager] Not initialized');
      return;
    }

    if (_isMonitoring) {
      printW('[TokenSessionManager] Already monitoring');
      return;
    }

    try {
      // Check if user is authenticated
      final authStatus = await _tokenManager!.getAuthenticationStatus();
      if (!authStatus.isAuthenticated) {
        printW('[TokenSessionManager] User not authenticated, cannot start monitoring');
        return;
      }

      _isMonitoring = true;

      // Lấy accessTokenExpiresIn từ storage (nếu có)
      int checkIntervalSeconds = 30; // default
      try {
        final expiresInStr = await _tokenManager!.getAccessTokenExpiresIn();
        if (expiresInStr != null) {
          int expiresIn = int.tryParse(expiresInStr) ?? 30;
          expiresIn = (expiresIn / 1000).round();
          checkIntervalSeconds = expiresIn;
        }
      } catch (_) {}

      // Start checking theo thời gian sống của access token (nếu có)
      _tokenCheckTimer = Timer.periodic(Duration(seconds: checkIntervalSeconds), (timer) async {
        await _checkTokenExpiry();
      });

      printI(
        '[TokenSessionManager] Token monitoring started, interval: '
        '[32m$checkIntervalSeconds[0m seconds',
      );
    } catch (e) {
      printE('[TokenSessionManager] Error starting token monitoring: $e');
    }
  }

  /// Stop monitoring
  void stopTokenMonitoring() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = null;
    _isMonitoring = false;
    printI('[TokenSessionManager] Token monitoring stopped');
  }

  /// Check if tokens are expired
  Future<void> _checkTokenExpiry() async {
    try {
      if (_tokenManager == null) return;

      final authStatus = await _tokenManager!.getAuthenticationStatus();

      // Check if session is completely invalid
      if (!authStatus.isSessionValid || !authStatus.hasAccessToken) {
        printI('[TokenSessionManager] Session/Token expired - triggering logout');
        await _handleTokenExpiry();
        return;
      }

      // Check if access token is expired but refresh token is still valid
      if (!authStatus.isAccessTokenValid && authStatus.isRefreshTokenValid) {
        printI('[TokenSessionManager] Access token expired but refresh token valid');
        // You can implement auto-refresh here if needed
        // For now, we'll logout when access token expires
        await _handleTokenExpiry();
        return;
      }

      // If both tokens are invalid
      if (!authStatus.isAccessTokenValid && !authStatus.isRefreshTokenValid) {
        printI('[TokenSessionManager] Both tokens expired - triggering logout');
        await _handleTokenExpiry();
        return;
      }

      if (!authStatus.isAccessTokenStillValidByExpiresIn ||
          !authStatus.isRefreshTokenStillValidByExpiresIn) {
        printI('[TokenSessionManager] Both tokens expired - triggering logout');
        await _handleTokenExpiry();
        return;
      }
    } catch (e) {
      printE('[TokenSessionManager] Error checking token expiry: $e');
      await _handleTokenExpiry();
    }
  }

  /// Handle token expiry - clear data and logout
  Future<void> _handleTokenExpiry() async {
    try {
      // Stop monitoring
      stopTokenMonitoring();

      // Clear all authentication data
      if (_tokenManager != null) {
        await _tokenManager!.clearAuthenticationData();
        printI('[TokenSessionManager] Cleared authentication data');
      }

      // Trigger callback for logout
      _onTokenExpired?.call();

      printI('[TokenSessionManager] Token expiry handled');
    } catch (e) {
      printE('[TokenSessionManager] Error handling token expiry: $e');
    }
  }

  /// Manual check for token validity
  Future<bool> isTokenValid() async {
    try {
      if (_tokenManager == null) return false;

      final authStatus = await _tokenManager!.getAuthenticationStatus();
      return authStatus.isAuthenticated &&
          authStatus.isSessionValid &&
          authStatus.isAccessTokenValid;
    } catch (e) {
      printE('[TokenSessionManager] Error checking token validity: $e');
      return false;
    }
  }

  /// Force logout and clear data
  Future<void> forceLogout() async {
    await _handleTokenExpiry();
  }

  /// Dispose
  void dispose() {
    stopTokenMonitoring();
    _tokenManager = null;
    _onTokenExpired = null;
    _instance = null;
  }
}
