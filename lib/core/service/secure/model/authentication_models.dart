import 'package:equatable/equatable.dart';

class AuthenticationStatus extends Equatable {
  final bool hasAccessToken;
  final bool hasRefreshToken;
  final bool isAccessTokenValid;
  final bool isRefreshTokenValid;
  final bool isSessionValid;
  final bool isAuthenticated;
  final bool needsRefresh;
  final bool isAccessTokenStillValidByExpiresIn;
  final bool isRefreshTokenStillValidByExpiresIn;

  const AuthenticationStatus({
    required this.hasAccessToken,
    required this.hasRefreshToken,
    required this.isAccessTokenValid,
    required this.isRefreshTokenValid,
    required this.isSessionValid,
    required this.isAuthenticated,
    required this.needsRefresh,
    this.isAccessTokenStillValidByExpiresIn = false, this.isRefreshTokenStillValidByExpiresIn = false,
  });

  factory AuthenticationStatus.unauthenticated() {
    return const AuthenticationStatus(
      hasAccessToken: false,
      hasRefreshToken: false,
      isAccessTokenValid: false,
      isRefreshTokenValid: false,
      isSessionValid: false,
      isAuthenticated: false,
      needsRefresh: false,
      isAccessTokenStillValidByExpiresIn: false, isRefreshTokenStillValidByExpiresIn: false,
    );
  }

  @override
  List<Object> get props => [
        hasAccessToken,
        hasRefreshToken,
        isAccessTokenValid,
        isRefreshTokenValid,
        isSessionValid,
        isAuthenticated,
        needsRefresh,
        isAccessTokenStillValidByExpiresIn, isRefreshTokenStillValidByExpiresIn,
      ];
}

class SecureUserData extends Equatable {
  final String userId;
  final String userEmail;
  final String userRole;
  final String? sessionId;
  final String? deviceId;

  const SecureUserData({
    required this.userId,
    required this.userEmail,
    required this.userRole,
    this.sessionId,
    this.deviceId,
  });

  @override
  List<Object?> get props => [userId, userEmail, userRole, sessionId, deviceId];
}

class SecuritySettings extends Equatable {
  final bool biometricEnabled;
  final bool autoLoginEnabled;
  final bool rememberMe;

  const SecuritySettings({
    this.biometricEnabled = false,
    this.autoLoginEnabled = false,
    this.rememberMe = false,
  });

  @override
  List<Object> get props => [biometricEnabled, autoLoginEnabled, rememberMe];
}

class LoginAttemptInfo extends Equatable {
  final int failedAttempts;
  final DateTime? lastFailedLogin;
  final DateTime? lastSuccessfulLogin;

  const LoginAttemptInfo({
    this.failedAttempts = 0,
    this.lastFailedLogin,
    this.lastSuccessfulLogin,
  });

  @override
  List<Object?> get props => [failedAttempts, lastFailedLogin, lastSuccessfulLogin];
}

class StorageStatistics extends Equatable {
  final int totalKeys;
  final int authKeys;
  final bool isAuthenticated;
  final bool hasValidSession;
  final bool needsRefresh;

  const StorageStatistics({
    this.totalKeys = 0,
    this.authKeys = 0,
    this.isAuthenticated = false,
    this.hasValidSession = false,
    this.needsRefresh = false,
  });

  @override
  List<Object> get props => [totalKeys, authKeys, isAuthenticated, hasValidSession, needsRefresh];
}