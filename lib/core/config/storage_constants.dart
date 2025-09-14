class StorageConstants {
  // Token keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenType = 'token_type';
  static const String tokenScope = 'token_scope';
  
  // Token metadata
  static const String accessTokenExpiresAt = 'access_token_expires_at';
  static const String refreshTokenExpiresAt = 'refresh_token_expires_at';
  static const String sessionExpiresAt = 'session_expires_at';
  static const String tokenIssuedAt = 'token_issued_at';
  static const String accessTokenExpiresIn = 'access_token_expires_in';
  static const String refreshTokenExpiresIn = 'refresh_token_expires_in';
  
  // User session
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String sessionId = 'session_id';
  static const String deviceId = 'device_id';
  
  // Security
  static const String lastAuthTime = 'last_auth_time';
  static const String loginAttempts = 'login_attempts';
  static const String lastFailedLogin = 'last_failed_login';
  static const String securityHash = 'security_hash';
  
  // Settings
  static const String biometricEnabled = 'biometric_enabled';
  static const String autoLoginEnabled = 'auto_login_enabled';
  static const String rememberMe = 'remember_me';
  
  // Encryption salts (these should be generated per installation)
  static const String tokenSalt = 'token_encryption_salt';
  static const String userDataSalt = 'user_data_encryption_salt';
}