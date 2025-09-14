abstract class AppConfigBase {
  //! ========== API Configuration ==========
  ///* The base URL for the API.
  String get apiBaseUrl;

  String get apiBaseUrlNYT;

  String get apiKeyNYTimes;

  //! ========== WebSocket Configuration ==========

  String get wsBaseUrl;
  String get wsNotificationNative;
  String get wsNotificationUnread;

  //! ========== Auth API Endpoints ==========

  String get apiAuthLogin;
  String get apiAuthBiometricLogin;
  String get apiAuthRegister;
  String get apiAuthRefresh;
  String get apiAuthLogout;
  String get apiAuthChangePassword;

  //! ========== Device API Endpoints ==========

  String get apiDeviceCreate;
  String get apiDeviceGetById;
  String get apiDeviceGetUserById;
  String get apiDeviceDeleteById;
  String get apiDeviceManagementCreate;
  String get apiDeviceManagementListUser;
  String get apiDeviceManagementDelete;
  String get apiDeviceManagementUpdateBiometric;

  //! ========== Notification API Endpoints ==========

  String get apiNotificationsUser;
  String get apiNotificationsUserUnread;
  String get apiNotificationsUserRead;
  String get apiNotificationsUserReadAll;
  String get apiNotificationsCountUnread;
  String get apiNotificationsCategories;
  String get apiNotificationsHealth;
  String get apiNotificationsTopicSubscribe;
  String get apiNotificationsTopicUnsubscribe;
  String get apiNotificationsValidateToken;

  //! ========== Dynamic URL Methods ==========

  /// Top stories endpoint with section parameter
  String topStoriesUrl({required String section});

  /// Device management info with device identifier and user ID
  String apiDeviceManagementInfoIndentifierUserId({
    required String deviceIdentifier,
    required String userId,
  });

  /// Notifications by category
  String apiNotificationsUserCategory({required String categoryName});

  /// Notifications by status
  String apiNotificationsUserStatus({required String status});

  /// Mark notification as read
  String apiNotificationsMarkRead({required String notificationId});

  /// Count notifications by status
  String apiNotificationsCountStatus({required String status});

  /// Delete notification
  String apiNotificationsDelete({required String notificationId});

  //* Config Base

  /// The base URL for the WebSocket connection.
  String? get webSocketBaseUrl;

  /// The base URL for the WebRTC signaling server.
  String? get webrtcSignalingUrl;

  /// The base URL for the WebRTC STUN server.
  String? get webrtcStunUrl;

  /// The base URL for the WebRTC TURN server.
  String? get webrtcTurnUrl;

  /// The version of the API.
  String get apiVersion;

  /// The timeout duration for API requests.
  Duration? get apiTimeout;

  /// The timeout duration for WebSocket connections.
  Duration? get webSocketTimeout;

  /// The timeout duration for WebRTC connections.
  Duration? get webrtcTimeout;

  /// The maximum number of retries for API requests.
  int? get maxRetries;

  /// The interval between retries for API requests.
  Duration? get retryInterval;

  /// The maximum number of connections for WebSocket.
  int? get maxWebSocketConnections;

  /// The maximum number of connections for WebRTC.
  int? get maxWebRTCConnections;

  /// The maximum size of the WebRTC data channel.
  int? get maxWebRTCDataChannelSize;

  /// The maximum size of the WebRTC media channel.
  int? get maxWebRTCMediaChannelSize;

  /// The maximum size of the WebRTC data channel buffer.
  int? get maxWebRTCDataChannelBufferSize;

  // ========== App Information ==========
  /// The name of the application.
  String get appName;

  /// The version of the application.
  String get appVersion;

  /// The build number of the application.
  String? get buildNumber;

  /// The bundle identifier (iOS) or package name (Android).
  String get bundleId;

  /// The environment (dev, staging, production).
  String get environment;

  /// Whether the app is in debug mode.
  bool get isDebugMode;

  /// Whether the app is in production mode.
  bool get isProduction;

  // ========== Authentication & Security ==========
  /// The OAuth client ID.
  String? get oauthClientId;

  /// The OAuth client secret.
  String? get oauthClientSecret;

  /// The OAuth redirect URI.
  String? get oauthRedirectUri;

  /// The OAuth scopes.
  List<String>? get oauthScopes;

  /// The JWT secret key.
  String? get jwtSecretKey;

  /// The JWT expiration time.
  Duration? get jwtExpirationTime;

  /// The refresh token expiration time.
  Duration? get refreshTokenExpirationTime;

  /// Whether to use biometric authentication.
  bool? get useBiometricAuth;

  /// The encryption key for local storage.
  String? get encryptionKey;

  // ========== Device Management & Security ==========
  /// Whether to enable device registration.
  bool? get enableDeviceRegistration;

  /// The maximum number of devices per user.
  int? get maxDevicesPerUser;

  /// Whether to require device verification.
  bool? get requireDeviceVerification;

  /// The device verification timeout.
  Duration? get deviceVerificationTimeout;

  /// Whether to enable device fingerprinting.
  bool? get enableDeviceFingerprinting;

  /// The device session timeout.
  Duration? get deviceSessionTimeout;

  /// Whether to enable device tracking.
  bool? get enableDeviceTracking;

  /// Whether to require device PIN/Pattern.
  bool? get requireDevicePin;

  /// The device PIN/Pattern retry limit.
  int? get devicePinRetryLimit;

  /// The device lockout duration after max retries.
  Duration? get deviceLockoutDuration;

  /// Whether to enable remote device wipe.
  bool? get enableRemoteDeviceWipe;

  /// Whether to enable device location tracking.
  bool? get enableDeviceLocationTracking;

  /// The device check-in interval.
  Duration? get deviceCheckInInterval;

  /// Whether to enable device compliance checking.
  bool? get enableDeviceComplianceCheck;

  /// The minimum required security patch level.
  String? get minSecurityPatchLevel;

  /// Whether to allow rooted/jailbroken devices.
  bool? get allowRootedDevices;

  /// Whether to enable device certificate pinning.
  bool? get enableDeviceCertificatePinning;

  // ========== Multi-Factor Authentication ==========
  /// Whether to enable multi-factor authentication.
  bool? get enableMFA;

  /// Whether to require MFA for all users.
  bool? get requireMFAForAllUsers;

  /// The supported MFA methods (SMS, EMAIL, TOTP, PUSH).
  List<String>? get supportedMFAMethods;

  /// The default MFA method.
  String? get defaultMFAMethod;

  /// The MFA token expiration time.
  Duration? get mfaTokenExpiration;

  /// The MFA backup codes count.
  int? get mfaBackupCodesCount;

  /// Whether to enable TOTP (Time-based OTP).
  bool? get enableTOTP;

  /// The TOTP time step in seconds.
  int? get totpTimeStep;

  /// The TOTP code length.
  int? get totpCodeLength;

  /// Whether to enable SMS OTP.
  bool? get enableSMSOTP;

  /// The SMS OTP expiration time.
  Duration? get smsOTPExpiration;

  /// Whether to enable email OTP.
  bool? get enableEmailOTP;

  /// The email OTP expiration time.
  Duration? get emailOTPExpiration;

  /// Whether to enable push notifications for MFA.
  bool? get enablePushMFA;

  /// The push MFA timeout.
  Duration? get pushMFATimeout;

  // ========== Session Management ==========
  /// The maximum concurrent sessions per user.
  int? get maxConcurrentSessions;

  /// The session idle timeout.
  Duration? get sessionIdleTimeout;

  /// The absolute session timeout.
  Duration? get sessionAbsoluteTimeout;

  /// Whether to enable session sliding expiration.
  bool? get enableSessionSlidingExpiration;

  /// Whether to require re-authentication for sensitive operations.
  bool? get requireReAuthForSensitiveOps;

  /// The re-authentication validity period.
  Duration? get reAuthValidityPeriod;

  /// Whether to enable single sign-on (SSO).
  bool? get enableSSO;

  /// The SSO provider configuration.
  Map<String, String>? get ssoProviderConfig;

  /// Whether to enable remember me functionality.
  bool? get enableRememberMe;

  /// The remember me duration.
  Duration? get rememberMeDuration;

  // ========== Password & PIN Security ==========
  /// The minimum password length.
  int? get minPasswordLength;

  /// The maximum password length.
  int? get maxPasswordLength;

  /// Whether to require uppercase letters in password.
  bool? get requirePasswordUppercase;

  /// Whether to require lowercase letters in password.
  bool? get requirePasswordLowercase;

  /// Whether to require numbers in password.
  bool? get requirePasswordNumbers;

  /// Whether to require special characters in password.
  bool? get requirePasswordSpecialChars;

  /// The password history count (prevent reuse).
  int? get passwordHistoryCount;

  /// The password expiration period.
  Duration? get passwordExpirationPeriod;

  /// The minimum password change interval.
  Duration? get minPasswordChangeInterval;

  /// The maximum login attempts before lockout.
  int? get maxLoginAttempts;

  /// The account lockout duration.
  Duration? get accountLockoutDuration;

  /// Whether to enable progressive lockout delays.
  bool? get enableProgressiveLockout;

  /// The PIN length.
  int? get pinLength;

  /// Whether to allow sequential PIN patterns.
  bool? get allowSequentialPinPatterns;

  /// Whether to allow repeated PIN digits.
  bool? get allowRepeatedPinDigits;

  // ========== Biometric Authentication ==========
  /// The supported biometric types (FINGERPRINT, FACE, VOICE).
  List<String>? get supportedBiometricTypes;

  /// Whether to enable fallback to PIN/Password.
  bool? get enableBiometricFallback;

  /// The biometric authentication timeout.
  Duration? get biometricAuthTimeout;

  /// The maximum biometric retry attempts.
  int? get maxBiometricRetryAttempts;

  /// Whether to enable biometric template storage.
  bool? get enableBiometricTemplateStorage;

  /// Whether to require liveness detection.
  bool? get requireLivenessDetection;

  /// The biometric quality threshold (0.0 to 1.0).
  double? get biometricQualityThreshold;

  // ========== Data Encryption & Protection ==========
  /// The encryption algorithm (AES256, RSA2048, etc.).
  String? get encryptionAlgorithm;

  /// The key derivation function (PBKDF2, Argon2, etc.).
  String? get keyDerivationFunction;

  /// The key derivation iterations.
  int? get keyDerivationIterations;

  /// The salt length for key derivation.
  int? get saltLength;

  /// Whether to enable end-to-end encryption.
  bool? get enableEndToEndEncryption;

  /// Whether to enable data at rest encryption.
  bool? get enableDataAtRestEncryption;

  /// Whether to enable data in transit encryption.
  bool? get enableDataInTransitEncryption;

  /// The TLS/SSL version (TLS1.2, TLS1.3).
  String? get tlsVersion;

  /// Whether to enable certificate pinning.
  bool? get enableCertificatePinning;

  /// The certificate pinning hashes.
  List<String>? get certificatePinningHashes;

  /// Whether to enable HSTS (HTTP Strict Transport Security).
  bool? get enableHSTS;

  /// The HSTS max age in seconds.
  int? get hstsMaxAge;

  // ========== Privacy & Data Protection ==========
  /// Whether to enable data anonymization.
  bool? get enableDataAnonymization;

  /// The data retention period.
  Duration? get dataRetentionPeriod;

  /// Whether to enable right to be forgotten.
  bool? get enableRightToBeForgotten;

  /// Whether to enable data portability.
  bool? get enableDataPortability;

  /// The supported data export formats.
  List<String>? get supportedDataExportFormats;

  /// Whether to enable consent management.
  bool? get enableConsentManagement;

  /// The consent expiration period.
  Duration? get consentExpirationPeriod;

  /// Whether to enable privacy mode.
  bool? get enablePrivacyMode;

  /// Whether to enable incognito mode.
  bool? get enableIncognitoMode;

  // ========== Fraud Detection & Prevention ==========
  /// Whether to enable fraud detection.
  bool? get enableFraudDetection;

  /// The fraud detection sensitivity (LOW, MEDIUM, HIGH).
  String? get fraudDetectionSensitivity;

  /// Whether to enable velocity checking.
  bool? get enableVelocityChecking;

  /// The maximum transactions per minute.
  int? get maxTransactionsPerMinute;

  /// The maximum transactions per hour.
  int? get maxTransactionsPerHour;

  /// The maximum transactions per day.
  int? get maxTransactionsPerDay;

  /// Whether to enable geolocation fraud detection.
  bool? get enableGeolocationFraudDetection;

  /// The maximum distance for simultaneous logins (km).
  double? get maxSimultaneousLoginDistance;

  /// Whether to enable device reputation checking.
  bool? get enableDeviceReputationCheck;

  /// Whether to enable IP reputation checking.
  bool? get enableIPReputationCheck;

  /// The IP whitelist.
  List<String>? get ipWhitelist;

  /// The IP blacklist.
  List<String>? get ipBlacklist;

  // ========== Audit & Compliance ==========
  /// Whether to enable audit logging.
  bool? get enableAuditLogging;

  /// The audit log retention period.
  Duration? get auditLogRetentionPeriod;

  /// Whether to enable compliance reporting.
  bool? get enableComplianceReporting;

  /// The compliance standards (GDPR, CCPA, HIPAA, etc.).
  List<String>? get complianceStandards;

  /// Whether to enable data loss prevention.
  bool? get enableDataLossPrevention;

  /// Whether to enable screen recording detection.
  bool? get enableScreenRecordingDetection;

  /// Whether to enable screenshot prevention.
  bool? get enableScreenshotPrevention;

  /// Whether to enable watermarking.
  bool? get enableWatermarking;

  /// The watermark text.
  String? get watermarkText;

  // ========== Database Configuration ==========
  /// The database name.
  String? get databaseName;

  /// The database version.
  int? get databaseVersion;

  /// The maximum database connections.
  int? get maxDatabaseConnections;

  /// The database timeout.
  Duration? get databaseTimeout;

  /// Whether to enable database encryption.
  bool? get enableDatabaseEncryption;

  // ========== Cache Configuration ==========
  /// The maximum cache size in bytes.
  int? get maxCacheSize;

  /// The cache expiration time.
  Duration? get cacheExpirationTime;

  /// The maximum number of cache entries.
  int? get maxCacheEntries;

  /// Whether to enable disk cache.
  bool? get enableDiskCache;

  /// Whether to enable memory cache.
  bool? get enableMemoryCache;

  /// The cache directory path.
  String? get cacheDirectoryPath;

  // ========== Storage Configuration ==========
  /// The maximum file size for uploads in bytes.
  int? get maxFileUploadSize;

  /// The allowed file extensions for uploads.
  List<String>? get allowedFileExtensions;

  /// The storage bucket name.
  String? get storageBucketName;

  /// The storage region.
  String? get storageRegion;

  /// The CDN base URL.
  String? get cdnBaseUrl;

  // ========== Firebase ==========
  // Android
  String? get apiKeyAndroid;
  String? get appIdAndroid;
  String? get messagingSenderIdAndroid;

  // Ios
  String? get apiKeyIOS;
  String? get appIdIOS;
  String? get messagingSenderIdIOS;

  // ========== Push Notifications ==========
  /// The Firebase project ID.
  String? get firebaseProjectId;

  /// The Firebase API key.
  String? get firebaseApiKey;

  /// The Firebase sender ID.
  String? get firebaseSenderId;

  /// The OneSignal app ID.
  String? get oneSignalAppId;

  /// Whether push notifications are enabled.
  bool? get enablePushNotifications;

  // ========== Analytics & Monitoring ==========
  /// The Firebase Analytics enabled flag.
  bool? get enableFirebaseAnalytics;

  /// The Google Analytics tracking ID.
  String? get googleAnalyticsTrackingId;

  /// The Crashlytics enabled flag.
  bool? get enableCrashlytics;

  /// The Sentry DSN.
  String? get sentryDsn;

  /// Whether to enable performance monitoring.
  bool? get enablePerformanceMonitoring;

  /// The log level (debug, info, warning, error).
  String? get logLevel;

  /// Whether to enable remote logging.
  bool? get enableRemoteLogging;

  // ========== UI/UX Configuration ==========
  /// The default theme mode (light, dark, system).
  String? get defaultThemeMode;

  /// The primary color.
  String? get primaryColor;

  /// The secondary color.
  String? get secondaryColor;

  /// The default locale.
  String? get defaultLocale;

  /// The supported locales.
  List<String>? get supportedLocales;

  /// Whether to enable haptic feedback.
  bool? get enableHapticFeedback;

  /// The default animation duration.
  Duration? get defaultAnimationDuration;

  // ========== Feature Flags ==========
  /// Whether to enable experimental features.
  bool? get enableExperimentalFeatures;

  /// Whether to enable beta features.
  bool? get enableBetaFeatures;

  /// Whether to enable A/B testing.
  bool? get enableABTesting;

  /// The feature flags configuration.
  Map<String, bool>? get featureFlags;

  // ========== Social Media Integration ==========
  /// The Facebook app ID.
  String? get facebookAppId;

  /// The Twitter consumer key.
  String? get twitterConsumerKey;

  /// The Google sign-in client ID.
  String? get googleSignInClientId;

  /// The Apple sign-in service ID.
  String? get appleSignInServiceId;

  // ========== Payment Configuration ==========
  /// The Stripe publishable key.
  String? get stripePublishableKey;

  /// The PayPal client ID.
  String? get paypalClientId;

  /// Whether to enable in-app purchases.
  bool? get enableInAppPurchases;

  /// The supported payment methods.
  List<String>? get supportedPaymentMethods;

  // ========== Location & Maps ==========
  /// The Google Maps API key.
  String? get googleMapsApiKey;

  /// The location accuracy (high, medium, low).
  String? get locationAccuracy;

  /// The location update interval.
  Duration? get locationUpdateInterval;

  /// Whether to enable background location.
  bool? get enableBackgroundLocation;

  // ========== Device & Platform ==========
  /// The minimum supported OS version (iOS/Android).
  String? get minSupportedOSVersion;

  /// The target SDK version.
  int? get targetSdkVersion;

  /// Whether to enable deep linking.
  bool? get enableDeepLinking;

  /// The deep link scheme.
  String? get deepLinkScheme;

  /// Whether to enable app shortcuts (Android).
  bool? get enableAppShortcuts;

  // ========== Development & Testing ==========
  /// Whether to enable developer mode.
  bool? get enableDeveloperMode;

  /// Whether to show debug information.
  bool? get showDebugInfo;

  /// Whether to enable mock data.
  bool? get enableMockData;

  /// The test environment base URL.
  String? get testEnvironmentBaseUrl;

  /// Whether to enable integration tests.
  bool? get enableIntegrationTests;

  // ========== Performance ==========
  /// The maximum memory usage in MB.
  int? get maxMemoryUsage;

  /// The frame rate target (30, 60, 120).
  int? get targetFrameRate;

  /// Whether to enable performance profiling.
  bool? get enablePerformanceProfiling;

  /// The image compression quality (0.0 to 1.0).
  double? get imageCompressionQuality;

  /// The maximum concurrent operations.
  int? get maxConcurrentOperations;

  // ========== Accessibility ==========
  /// Whether to enable accessibility features.
  bool? get enableAccessibility;

  /// The default font size multiplier.
  double? get defaultFontSizeMultiplier;

  /// Whether to enable high contrast mode.
  bool? get enableHighContrastMode;

  /// Whether to enable screen reader support.
  bool? get enableScreenReaderSupport;

  // ========== Backup & Sync ==========
  /// Whether to enable automatic backup.
  bool? get enableAutomaticBackup;

  /// The backup interval.
  Duration? get backupInterval;

  /// Whether to enable cloud sync.
  bool? get enableCloudSync;

  /// The sync interval.
  Duration? get syncInterval;

  /// The maximum backup size in MB.
  int? get maxBackupSize;

  //! ========== URL Update Methods ==========
  /// Update the API base URL
  void updateApiBaseUrl(String newUrl);

  /// Update the WebSocket base URL
  void updateWebSocketBaseUrl(String newUrl);
}
