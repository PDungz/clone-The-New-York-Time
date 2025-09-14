// core/services/secure_token_manager.dart

import 'package:news_app/core/config/storage_constants.dart';
import 'package:news_app/core/service/secure/model/authentication_models.dart';
import 'package:news_app/core/service/storage/secure_storage_manager.dart';
import 'package:packages/core/service/logger_service.dart';

class SecureTokenManager {
  // Private constructor
  SecureTokenManager._();

  // Singleton instance
  static SecureTokenManager? _instance;

  // Storage manager
  static late SecureStorageManager _storageManager;

  /// Method to get the singleton instance
  static Future<SecureTokenManager> getInstance() async {
    _instance ??= SecureTokenManager._();
    _storageManager = await SecureStorageManager.getInstance();
    return _instance!;
  }

  /// Save complete authentication data
  Future<void> saveAuthenticationData({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
    required DateTime sessionExpiresAt,
    required String userId,
    required String userEmail,
    required String userRole,
    String? sessionId,
    String? deviceId,
    String tokenType = 'Bearer',
    int? accessTokenExpiresIn,
    int? refreshTokenExpiresIn,
  }) async {
    try {
      final currentTime = DateTime.now();
      
      // Save tokens with additional encryption
      await _storageManager.writeSecure(
        StorageConstants.accessToken,
        accessToken,
        additionalEncryption: true,
        encryptionSalt: StorageConstants.tokenSalt,
      );
      
      await _storageManager.writeSecure(
        StorageConstants.refreshToken,
        refreshToken,
        additionalEncryption: true,
        encryptionSalt: StorageConstants.tokenSalt,
      );
      
      // Save token metadata with expiry
      await _storageManager.writeWithExpiry(
        StorageConstants.accessTokenExpiresAt,
        accessTokenExpiresAt.toIso8601String(),
        accessTokenExpiresAt.difference(currentTime),
        additionalEncryption: true,
      );
      
      await _storageManager.writeWithExpiry(
        StorageConstants.refreshTokenExpiresAt,
        refreshTokenExpiresAt.toIso8601String(),
        refreshTokenExpiresAt.difference(currentTime),
        additionalEncryption: true,
      );
      
      await _storageManager.writeWithExpiry(
        StorageConstants.sessionExpiresAt,
        sessionExpiresAt.toIso8601String(),
        sessionExpiresAt.difference(currentTime),
        additionalEncryption: true,
      );
      
      // Save user data with checksum
      await _storageManager.writeWithChecksum(
        StorageConstants.userId,
        userId,
      );
      
      await _storageManager.writeWithChecksum(
        StorageConstants.userEmail,
        userEmail,
      );
      
      await _storageManager.writeWithChecksum(
        StorageConstants.userRole,
        userRole,
      );
      
      // Save additional metadata
      await _storageManager.writeSecure(
        StorageConstants.tokenType,
        tokenType,
        additionalEncryption: true,
      );
      
      await _storageManager.writeSecure(
        StorageConstants.tokenIssuedAt,
        currentTime.toIso8601String(),
        additionalEncryption: true,
      );
      
      await _storageManager.writeSecure(
        StorageConstants.lastAuthTime,
        currentTime.toIso8601String(),
        additionalEncryption: true,
      );
      
      if (sessionId != null) {
        await _storageManager.writeWithChecksum(
          StorageConstants.sessionId,
          sessionId,
        );
      }
      
      if (deviceId != null) {
        await _storageManager.writeWithChecksum(
          StorageConstants.deviceId,
          deviceId,
        );
      }
      
      if (accessTokenExpiresIn != null) {
        await _storageManager.writeSecure(
          StorageConstants.accessTokenExpiresIn,
          accessTokenExpiresIn.toString(),
          additionalEncryption: true,
        );
      }

      if (refreshTokenExpiresIn != null) {
        await _storageManager.writeSecure(
          StorageConstants.refreshTokenExpiresIn,
          refreshTokenExpiresIn.toString(),
          additionalEncryption: true,
        );
      }
      
      printS("[SecureTokenManager] saveAuthenticationData: Complete auth data saved");
    } catch (e) {
      printE("[SecureTokenManager] saveAuthenticationData - Error: $e");
      rethrow;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storageManager.readSecure(
        StorageConstants.accessToken,
        additionalEncryption: true,
        encryptionSalt: StorageConstants.tokenSalt,
      );
    } catch (e) {
      printE("[SecureTokenManager] getAccessToken - Error: $e");
      return null;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storageManager.readSecure(
        StorageConstants.refreshToken,
        additionalEncryption: true,
        encryptionSalt: StorageConstants.tokenSalt,
      );
    } catch (e) {
      printE("[SecureTokenManager] getRefreshToken - Error: $e");
      return null;
    }
  }

  /// Check if access token is valid (not expired)
  Future<bool> isAccessTokenValid() async {
    try {
      // First check if token exists
      final token = await getAccessToken();
      if (token == null) return false;
      
      // Check expiry time
      final expiryString = await _storageManager.readWithExpiry(
        StorageConstants.accessTokenExpiresAt,
        additionalEncryption: true,
      );
      
      if (expiryString == null) {
        // If no expiry found, consider token invalid
        return false;
      }
      
      final expiryTime = DateTime.parse(expiryString);
      final isValid = DateTime.now().isBefore(expiryTime);
      
      printS("[SecureTokenManager] isAccessTokenValid: $isValid");
      return isValid;
    } catch (e) {
      printE("[SecureTokenManager] isAccessTokenValid - Error: $e");
      return false;
    }
  }

  /// Check if refresh token is valid (not expired)
  Future<bool> isRefreshTokenValid() async {
    try {
      final token = await getRefreshToken();
      if (token == null) return false;
      
      final expiryString = await _storageManager.readWithExpiry(
        StorageConstants.refreshTokenExpiresAt,
        additionalEncryption: true,
      );
      
      if (expiryString == null) return false;
      
      final expiryTime = DateTime.parse(expiryString);
      final isValid = DateTime.now().isBefore(expiryTime);
      
      printS("[SecureTokenManager] isRefreshTokenValid: $isValid");
      return isValid;
    } catch (e) {
      printE("[SecureTokenManager] isRefreshTokenValid - Error: $e");
      return false;
    }
  }

  /// Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      final sessionExpiryString = await _storageManager.readWithExpiry(
        StorageConstants.sessionExpiresAt,
        additionalEncryption: true,
      );
      
      if (sessionExpiryString == null) return false;
      
      final sessionExpiryTime = DateTime.parse(sessionExpiryString);
      final isValid = DateTime.now().isBefore(sessionExpiryTime);
      
      printS("[SecureTokenManager] isSessionValid: $isValid");
      return isValid;
    } catch (e) {
      printE("[SecureTokenManager] isSessionValid - Error: $e");
      return false;
    }
  }

  /// Get complete authentication status
  Future<AuthenticationStatus> getAuthenticationStatus() async {
    try {
      final hasAccessToken = await getAccessToken() != null;
      final hasRefreshToken = await getRefreshToken() != null;
      final isAccessValid = await isAccessTokenValid();
      final isRefreshValid = await isRefreshTokenValid();
      final isSessionValid = await this.isSessionValid();
      final isAccessTokenStillValidByExpiresIn_ = await isAccessTokenStillValidByExpiresIn();
      final isRefreshTokenStillValidByExpiresIn_ = await isRefreshTokenStillValidByExpiresIn();
      return AuthenticationStatus(
        hasAccessToken: hasAccessToken,
        hasRefreshToken: hasRefreshToken,
        isAccessTokenValid: isAccessValid,
        isRefreshTokenValid: isRefreshValid,
        isSessionValid: isSessionValid,
        isAccessTokenStillValidByExpiresIn: isAccessTokenStillValidByExpiresIn_,
        isRefreshTokenStillValidByExpiresIn: isRefreshTokenStillValidByExpiresIn_,
        isAuthenticated: hasAccessToken && hasRefreshToken && isSessionValid,
        needsRefresh: hasRefreshToken && !isAccessValid && isRefreshValid,
      );
    } catch (e) {
      printE("[SecureTokenManager] getAuthenticationStatus - Error: $e");
      return AuthenticationStatus.unauthenticated();
    }
  }

  /// Get user data
  Future<SecureUserData?> getUserData() async {
    try {
      final userId = await _storageManager.readWithChecksum(StorageConstants.userId);
      final userEmail = await _storageManager.readWithChecksum(StorageConstants.userEmail);
      final userRole = await _storageManager.readWithChecksum(StorageConstants.userRole);
      final sessionId = await _storageManager.readWithChecksum(StorageConstants.sessionId);
      final deviceId = await _storageManager.readWithChecksum(StorageConstants.deviceId);
      
      if (userId == null || userEmail == null || userRole == null) {
        return null;
      }
      
      return SecureUserData(
        userId: userId,
        userEmail: userEmail,
        userRole: userRole,
        sessionId: sessionId,
        deviceId: deviceId,
      );
    } catch (e) {
      printE("[SecureTokenManager] getUserData - Error: $e");
      return null;
    }
  }

  /// Update access token (for refresh scenarios)
  Future<void> updateAccessToken({
    required String newAccessToken,
    required DateTime newExpiresAt,
  }) async {
    try {
      await _storageManager.writeSecure(
        StorageConstants.accessToken,
        newAccessToken,
        additionalEncryption: true,
        encryptionSalt: StorageConstants.tokenSalt,
      );
      
      final currentTime = DateTime.now();
      await _storageManager.writeWithExpiry(
        StorageConstants.accessTokenExpiresAt,
        newExpiresAt.toIso8601String(),
        newExpiresAt.difference(currentTime),
        additionalEncryption: true,
      );
      
      await _storageManager.writeSecure(
        StorageConstants.lastAuthTime,
        currentTime.toIso8601String(),
        additionalEncryption: true,
      );
      
      printS("[SecureTokenManager] updateAccessToken: Token updated");
    } catch (e) {
      printE("[SecureTokenManager] updateAccessToken - Error: $e");
      rethrow;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuthenticationData() async {
    try {
      final authKeys = [
        StorageConstants.accessToken,
        StorageConstants.refreshToken,
        StorageConstants.tokenType,
        StorageConstants.accessTokenExpiresAt,
        StorageConstants.refreshTokenExpiresAt,
        StorageConstants.sessionExpiresAt,
        StorageConstants.tokenIssuedAt,
        StorageConstants.userId,
        StorageConstants.userEmail,
        StorageConstants.userRole,
        StorageConstants.sessionId,
        StorageConstants.deviceId,
        StorageConstants.lastAuthTime,
      ];
      
      await _storageManager.deleteMultiple(authKeys);
      printS("[SecureTokenManager] clearAuthenticationData: All auth data cleared");
    } catch (e) {
      printE("[SecureTokenManager] clearAuthenticationData - Error: $e");
      rethrow;
    }
  }

  /// Save security settings
  Future<void> saveSecuritySettings({
    bool biometricEnabled = false,
    bool autoLoginEnabled = false,
    bool rememberMe = false,
  }) async {
    try {
      await _storageManager.writeSecure(
        StorageConstants.biometricEnabled,
        biometricEnabled.toString(),
        additionalEncryption: true,
      );
      
await _storageManager.writeSecure(
       StorageConstants.autoLoginEnabled,
       autoLoginEnabled.toString(),
       additionalEncryption: true,
     );
     
     await _storageManager.writeSecure(
       StorageConstants.rememberMe,
       rememberMe.toString(),
       additionalEncryption: true,
     );
     
     printS("[SecureTokenManager] saveSecuritySettings: Settings saved");
   } catch (e) {
     printE("[SecureTokenManager] saveSecuritySettings - Error: $e");
     rethrow;
   }
 }

 /// Get security settings
 Future<SecuritySettings> getSecuritySettings() async {
   try {
     final biometricString = await _storageManager.readSecure(
       StorageConstants.biometricEnabled,
       additionalEncryption: true,
     );
     
     final autoLoginString = await _storageManager.readSecure(
       StorageConstants.autoLoginEnabled,
       additionalEncryption: true,
     );
     
     final rememberMeString = await _storageManager.readSecure(
       StorageConstants.rememberMe,
       additionalEncryption: true,
     );
     
     return SecuritySettings(
       biometricEnabled: biometricString?.toLowerCase() == 'true',
       autoLoginEnabled: autoLoginString?.toLowerCase() == 'true',
       rememberMe: rememberMeString?.toLowerCase() == 'true',
     );
   } catch (e) {
     printE("[SecureTokenManager] getSecuritySettings - Error: $e");
     return SecuritySettings();
   }
 }

 /// Record login attempt (for security tracking)
 Future<void> recordLoginAttempt({required bool success}) async {
   try {
     final currentTime = DateTime.now();
     
     if (success) {
       await _storageManager.writeSecure(
         StorageConstants.lastAuthTime,
         currentTime.toIso8601String(),
         additionalEncryption: true,
       );
       
       // Reset login attempts on successful login
       await _storageManager.delete(StorageConstants.loginAttempts);
       await _storageManager.delete(StorageConstants.lastFailedLogin);
     } else {
       // Increment failed login attempts
       final currentAttemptsString = await _storageManager.readSecure(
         StorageConstants.loginAttempts,
         additionalEncryption: true,
       );
       
       final currentAttempts = int.tryParse(currentAttemptsString ?? '0') ?? 0;
       final newAttempts = currentAttempts + 1;
       
       await _storageManager.writeSecure(
         StorageConstants.loginAttempts,
         newAttempts.toString(),
         additionalEncryption: true,
       );
       
       await _storageManager.writeSecure(
         StorageConstants.lastFailedLogin,
         currentTime.toIso8601String(),
         additionalEncryption: true,
       );
     }
     
     printS("[SecureTokenManager] recordLoginAttempt: success=$success");
   } catch (e) {
     printE("[SecureTokenManager] recordLoginAttempt - Error: $e");
   }
 }

 /// Get login attempt information
 Future<LoginAttemptInfo> getLoginAttemptInfo() async {
   try {
     final attemptsString = await _storageManager.readSecure(
       StorageConstants.loginAttempts,
       additionalEncryption: true,
     );
     
     final lastFailedString = await _storageManager.readSecure(
       StorageConstants.lastFailedLogin,
       additionalEncryption: true,
     );
     
     final lastAuthString = await _storageManager.readSecure(
       StorageConstants.lastAuthTime,
       additionalEncryption: true,
     );
     
     return LoginAttemptInfo(
       failedAttempts: int.tryParse(attemptsString ?? '0') ?? 0,
       lastFailedLogin: lastFailedString != null ? DateTime.parse(lastFailedString) : null,
       lastSuccessfulLogin: lastAuthString != null ? DateTime.parse(lastAuthString) : null,
     );
   } catch (e) {
     printE("[SecureTokenManager] getLoginAttemptInfo - Error: $e");
     return LoginAttemptInfo();
   }
 }

 /// Check if account is locked due to too many failed attempts
  Future<bool> isAccountLocked({
    int maxAttempts = 50,
    Duration lockDuration = const Duration(minutes: 5),
  }) async {
   try {
     final attemptInfo = await getLoginAttemptInfo();
     
     if (attemptInfo.failedAttempts >= maxAttempts) {
       final lastFailed = attemptInfo.lastFailedLogin;
       if (lastFailed != null) {
         final lockUntil = lastFailed.add(lockDuration);
         final isLocked = DateTime.now().isBefore(lockUntil);
         printS("[SecureTokenManager] isAccountLocked: $isLocked (${attemptInfo.failedAttempts} attempts)");
         return isLocked;
       }
     }
     
     return false;
   } catch (e) {
     printE("[SecureTokenManager] isAccountLocked - Error: $e");
     return false;
   }
 }

 /// Clean up expired data and perform maintenance
 Future<void> performMaintenance() async {
   try {
     // Clean up expired data
     await _storageManager.cleanupExpiredData();
     
     // Check and clean invalid sessions
     final isSessionValid = await this.isSessionValid();
     if (!isSessionValid) {
       await clearAuthenticationData();
       printS("[SecureTokenManager] performMaintenance: Cleared invalid session");
     }
     
     printS("[SecureTokenManager] performMaintenance: Completed");
   } catch (e) {
     printE("[SecureTokenManager] performMaintenance - Error: $e");
   }
 }

 /// Get storage statistics
 Future<StorageStatistics> getStorageStatistics() async {
   try {
     final allKeys = await _storageManager.getAllKeys();
     final authKeys = allKeys.where((key) => key.startsWith('access_') || 
                                             key.startsWith('refresh_') || 
                                             key.startsWith('user_') ||
                                             key.startsWith('session_')).toSet();
     
     final authStatus = await getAuthenticationStatus();
     
     return StorageStatistics(
       totalKeys: allKeys.length,
       authKeys: authKeys.length,
       isAuthenticated: authStatus.isAuthenticated,
       hasValidSession: authStatus.isSessionValid,
       needsRefresh: authStatus.needsRefresh,
     );
   } catch (e) {
     printE("[SecureTokenManager] getStorageStatistics - Error: $e");
     return StorageStatistics();
   }
 }

  /// Get access token expires in (seconds as String)
  Future<String?> getAccessTokenExpiresIn() async {
    try {
      return await _storageManager.readSecure(
        StorageConstants.accessTokenExpiresIn,
        additionalEncryption: true,
      );
    } catch (e) {
      printE("[SecureTokenManager] getAccessTokenExpiresIn - Error: $e");
      return null;
    }
  }

  /// Check if access token is still valid by accessTokenExpiresIn
  Future<bool> isAccessTokenStillValidByExpiresIn() async {
    try {
      final issuedAtStr = await _storageManager.readSecure(
        StorageConstants.tokenIssuedAt,
        additionalEncryption: true,
      );
      final expiresInStr = await _storageManager.readSecure(
        StorageConstants.accessTokenExpiresIn,
        additionalEncryption: true,
      );
      if (issuedAtStr == null || expiresInStr == null) return false;
      final issuedAt = DateTime.tryParse(issuedAtStr);
      final expiresIn = int.tryParse(expiresInStr);
      if (issuedAt == null || expiresIn == null) return false;
      final expiresInSeconds = (expiresIn / 1000).round();
      final now = DateTime.now();
      return now.isBefore(issuedAt.add(Duration(seconds: expiresInSeconds)));
    } catch (e) {
      printE("[SecureTokenManager] isAccessTokenStillValidByExpiresIn - Error: $e");
      return false;
    }
  }

  /// Check if refresh token is still valid by refreshTokenExpiresIn
  Future<bool> isRefreshTokenStillValidByExpiresIn() async {
    try {
      final issuedAtStr = await _storageManager.readSecure(
        StorageConstants.tokenIssuedAt,
        additionalEncryption: true,
      );
      final expiresInStr = await _storageManager.readSecure(
        StorageConstants.refreshTokenExpiresIn,
        additionalEncryption: true,
      );
      if (issuedAtStr == null || expiresInStr == null) return false;
      final issuedAt = DateTime.tryParse(issuedAtStr);
      final expiresIn = int.tryParse(expiresInStr);
      if (issuedAt == null || expiresIn == null) return false;
      final expiresInSeconds = (expiresIn / 1000).round();
      final now = DateTime.now();
      return now.isBefore(issuedAt.add(Duration(seconds: expiresInSeconds)));
    } catch (e) {
      printE("[SecureTokenManager] isRefreshTokenStillValidByExpiresIn - Error: $e");
      return false;
    }
  }
}