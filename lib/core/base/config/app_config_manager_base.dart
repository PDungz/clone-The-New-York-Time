import 'package:news_app/core/base/config/app_config_base.dart';
import 'package:packages/core/service/logger_service.dart';

class AppConfigManagerBase {
  static AppConfigManagerBase? _instance;
  static AppConfigBase? _config;

  // Private constructor
  AppConfigManagerBase._();

  // Singleton instance getter
  static AppConfigManagerBase get instance {
    _instance ??= AppConfigManagerBase._();
    return _instance!;
  }

  // Initialize the config (call this once in main.dart)
  static void initialize(AppConfigBase config) {
    _config = config;
  }

  // Get the current config
  static AppConfigBase get appConfig {
    if (_config == null) {
      throw Exception('AppConfig has not been initialized. Call AppConfigManagerBase.initialize() first.');
    }
    return _config!;
  }

  // ========== API Configuration ==========
  /// The base URL for the API.
  static String get apiBaseUrl => appConfig.apiBaseUrl;

  static String get apiBaseUrlNYT => appConfig.apiBaseUrlNYT;

  static String get apiKeyNYTimes => appConfig.apiKeyNYTimes;

  //! ========== WebSocket Configuration ==========

  /// The base URL for WebSocket connection
  static String get wsBaseUrl => appConfig.wsBaseUrl;
  static String get wsNotificationNative => appConfig.wsNotificationNative;
  static String get wsNotificationUnread => appConfig.wsNotificationUnread;

  //! ========== Auth API Endpoints ==========

  static String get apiAuthLogin => appConfig.apiAuthLogin;
  static String get apiAuthBiometricLogin => appConfig.apiAuthBiometricLogin;
  static String get apiAuthRegister => appConfig.apiAuthRegister;
  static String get apiAuthRefresh => appConfig.apiAuthRefresh;
  static String get apiAuthLogout => appConfig.apiAuthLogout;
  static String get apiAuthChangePassword => appConfig.apiAuthChangePassword;

  //! ========== Device API Endpoints ==========

  static String get apiDeviceCreate => appConfig.apiDeviceCreate;
  static String get apiDeviceGetById => appConfig.apiDeviceGetById;
  static String get apiDeviceGetUserById => appConfig.apiDeviceGetUserById;
  static String get apiDeviceDeleteById => appConfig.apiDeviceDeleteById;
  static String get apiDeviceManagementCreate => appConfig.apiDeviceManagementCreate;
  static String get apiDeviceManagementListUser => appConfig.apiDeviceManagementListUser;
  static String get apiDeviceManagementDelete => appConfig.apiDeviceManagementDelete;
  static String get apiDeviceManagementUpdateBiometric => appConfig.apiDeviceManagementUpdateBiometric;

  //! ========== Notification API Endpoints ==========

  static String get apiNotificationsUser => appConfig.apiNotificationsUser;
  static String get apiNotificationsUserUnread => appConfig.apiNotificationsUserUnread;
  static String get apiNotificationsUserRead => appConfig.apiNotificationsUserRead;
  static String get apiNotificationsUserReadAll => appConfig.apiNotificationsUserReadAll;
  static String get apiNotificationsCountUnread => appConfig.apiNotificationsCountUnread;
  static String get apiNotificationsCategories => appConfig.apiNotificationsCategories;
  static String get apiNotificationsHealth => appConfig.apiNotificationsHealth;
  static String get apiNotificationsTopicSubscribe => appConfig.apiNotificationsTopicSubscribe;
  static String get apiNotificationsTopicUnsubscribe => appConfig.apiNotificationsTopicUnsubscribe;
  static String get apiNotificationsValidateToken => appConfig.apiNotificationsValidateToken;

  //! ========== Dynamic URL Methods ==========

  /// Top stories endpoint with section parameter
  static String topStoriesUrl({required String section}) => appConfig.topStoriesUrl(section: section);

  /// Device management info with device identifier and user ID
  static String apiDeviceManagementInfoIndentifierUserId({required String deviceIdentifier, required String userId}) =>
      appConfig.apiDeviceManagementInfoIndentifierUserId(deviceIdentifier: deviceIdentifier, userId: userId);

  /// Notifications by category
  static String apiNotificationsUserCategory({required String categoryName}) =>
      appConfig.apiNotificationsUserCategory(categoryName: categoryName);

  /// Notifications by status
  static String apiNotificationsUserStatus({required String status}) =>
      appConfig.apiNotificationsUserStatus(status: status);

  /// Mark notification as read
  static String apiNotificationsMarkRead({required String notificationId}) =>
      appConfig.apiNotificationsMarkRead(notificationId: notificationId);

  /// Count notifications by status
  static String apiNotificationsCountStatus({required String status}) =>
      appConfig.apiNotificationsCountStatus(status: status);

  /// Delete notification
  static String apiNotificationsDelete({required String notificationId}) =>
      appConfig.apiNotificationsDelete(notificationId: notificationId);

  //! ========== API Configuration ==========

  /// The base URL for the WebSocket connection.
  static String? get webSocketBaseUrl => appConfig.webSocketBaseUrl;

  /// The base URL for the WebRTC signaling server.
  static String? get webrtcSignalingUrl => appConfig.webrtcSignalingUrl;

  /// The base URL for the WebRTC STUN server.
  static String? get webrtcStunUrl => appConfig.webrtcStunUrl;

  /// The base URL for the WebRTC TURN server.
  static String? get webrtcTurnUrl => appConfig.webrtcTurnUrl;

  /// The version of the API.
  static String get apiVersion => appConfig.apiVersion;

  /// The timeout duration for API requests.
  static Duration? get apiTimeout => appConfig.apiTimeout;

  /// The timeout duration for WebSocket connections.
  static Duration? get webSocketTimeout => appConfig.webSocketTimeout;

  /// The timeout duration for WebRTC connections.
  static Duration? get webrtcTimeout => appConfig.webrtcTimeout;

  /// The maximum number of retries for API requests.
  static int? get maxRetries => appConfig.maxRetries;

  /// The interval between retries for API requests.
  static Duration? get retryInterval => appConfig.retryInterval;

  /// The maximum number of connections for WebSocket.
  static int? get maxWebSocketConnections => appConfig.maxWebSocketConnections;

  /// The maximum number of connections for WebRTC.
  static int? get maxWebRTCConnections => appConfig.maxWebRTCConnections;

  /// The maximum size of the WebRTC data channel.
  static int? get maxWebRTCDataChannelSize => appConfig.maxWebRTCDataChannelSize;

  /// The maximum size of the WebRTC media channel.
  static int? get maxWebRTCMediaChannelSize => appConfig.maxWebRTCMediaChannelSize;

  /// The maximum size of the WebRTC data channel buffer.
  static int? get maxWebRTCDataChannelBufferSize => appConfig.maxWebRTCDataChannelBufferSize;

  // ========== App Information ==========
  /// The name of the application.
  static String get appName => appConfig.appName;

  /// The version of the application.
  static String get appVersion => appConfig.appVersion;

  /// The build number of the application.
  static String? get buildNumber => appConfig.buildNumber;

  /// The bundle identifier (iOS) or package name (Android).
  static String get bundleId => appConfig.bundleId;

  /// The environment (dev, staging, production).
  static String get environment => appConfig.environment;

  /// Whether the app is in debug mode.
  static bool get isDebugMode => appConfig.isDebugMode;

  /// Whether the app is in production mode.
  static bool get isProduction => appConfig.isProduction;

  // ========== Authentication & Security ==========
  /// The OAuth client ID.
  static String? get oauthClientId => appConfig.oauthClientId;

  /// The OAuth client secret.
  static String? get oauthClientSecret => appConfig.oauthClientSecret;

  /// The OAuth redirect URI.
  static String? get oauthRedirectUri => appConfig.oauthRedirectUri;

  /// The OAuth scopes.
  static List<String>? get oauthScopes => appConfig.oauthScopes;

  /// The JWT secret key.
  static String? get jwtSecretKey => appConfig.jwtSecretKey;

  /// The JWT expiration time.
  static Duration? get jwtExpirationTime => appConfig.jwtExpirationTime;

  /// The refresh token expiration time.
  static Duration? get refreshTokenExpirationTime => appConfig.refreshTokenExpirationTime;

  /// Whether to use biometric authentication.
  static bool? get useBiometricAuth => appConfig.useBiometricAuth;

  /// The encryption key for local storage.
  static String? get encryptionKey => appConfig.encryptionKey;

  // ========== Device Management & Security ==========
  /// Whether to enable device registration.
  static bool? get enableDeviceRegistration => appConfig.enableDeviceRegistration;

  /// The maximum number of devices per user.
  static int? get maxDevicesPerUser => appConfig.maxDevicesPerUser;

  /// Whether to require device verification.
  static bool? get requireDeviceVerification => appConfig.requireDeviceVerification;

  /// The device verification timeout.
  static Duration? get deviceVerificationTimeout => appConfig.deviceVerificationTimeout;

  /// Whether to enable device fingerprinting.
  static bool? get enableDeviceFingerprinting => appConfig.enableDeviceFingerprinting;

  /// The device session timeout.
  static Duration? get deviceSessionTimeout => appConfig.deviceSessionTimeout;

  /// Whether to enable device tracking.
  static bool? get enableDeviceTracking => appConfig.enableDeviceTracking;

  /// Whether to require device PIN/Pattern.
  static bool? get requireDevicePin => appConfig.requireDevicePin;

  /// The device PIN/Pattern retry limit.
  static int? get devicePinRetryLimit => appConfig.devicePinRetryLimit;

  /// The device lockout duration after max retries.
  static Duration? get deviceLockoutDuration => appConfig.deviceLockoutDuration;

  /// Whether to enable remote device wipe.
  static bool? get enableRemoteDeviceWipe => appConfig.enableRemoteDeviceWipe;

  /// Whether to enable device location tracking.
  static bool? get enableDeviceLocationTracking => appConfig.enableDeviceLocationTracking;

  /// The device check-in interval.
  static Duration? get deviceCheckInInterval => appConfig.deviceCheckInInterval;

  /// Whether to enable device compliance checking.
  static bool? get enableDeviceComplianceCheck => appConfig.enableDeviceComplianceCheck;

  /// The minimum required security patch level.
  static String? get minSecurityPatchLevel => appConfig.minSecurityPatchLevel;

  /// Whether to allow rooted/jailbroken devices.
  static bool? get allowRootedDevices => appConfig.allowRootedDevices;

  /// Whether to enable device certificate pinning.
  static bool? get enableDeviceCertificatePinning => appConfig.enableDeviceCertificatePinning;

  // ========== Multi-Factor Authentication ==========
  /// Whether to enable multi-factor authentication.
  static bool? get enableMFA => appConfig.enableMFA;

  /// Whether to require MFA for all users.
  static bool? get requireMFAForAllUsers => appConfig.requireMFAForAllUsers;

  /// The supported MFA methods (SMS, EMAIL, TOTP, PUSH).
  static List<String>? get supportedMFAMethods => appConfig.supportedMFAMethods;

  /// The default MFA method.
  static String? get defaultMFAMethod => appConfig.defaultMFAMethod;

  /// The MFA token expiration time.
  static Duration? get mfaTokenExpiration => appConfig.mfaTokenExpiration;

  /// The MFA backup codes count.
  static int? get mfaBackupCodesCount => appConfig.mfaBackupCodesCount;

  /// Whether to enable TOTP (Time-based OTP).
  static bool? get enableTOTP => appConfig.enableTOTP;

  /// The TOTP time step in seconds.
  static int? get totpTimeStep => appConfig.totpTimeStep;

  /// The TOTP code length.
  static int? get totpCodeLength => appConfig.totpCodeLength;

  /// Whether to enable SMS OTP.
  static bool? get enableSMSOTP => appConfig.enableSMSOTP;

  /// The SMS OTP expiration time.
  static Duration? get smsOTPExpiration => appConfig.smsOTPExpiration;

  /// Whether to enable email OTP.
  static bool? get enableEmailOTP => appConfig.enableEmailOTP;

  /// The email OTP expiration time.
  static Duration? get emailOTPExpiration => appConfig.emailOTPExpiration;

  /// Whether to enable push notifications for MFA.
  static bool? get enablePushMFA => appConfig.enablePushMFA;

  /// The push MFA timeout.
  static Duration? get pushMFATimeout => appConfig.pushMFATimeout;

  // ========== Session Management ==========
  /// The maximum concurrent sessions per user.
  static int? get maxConcurrentSessions => appConfig.maxConcurrentSessions;

  /// The session idle timeout.
  static Duration? get sessionIdleTimeout => appConfig.sessionIdleTimeout;

  /// The absolute session timeout.
  static Duration? get sessionAbsoluteTimeout => appConfig.sessionAbsoluteTimeout;

  /// Whether to enable session sliding expiration.
  static bool? get enableSessionSlidingExpiration => appConfig.enableSessionSlidingExpiration;

  /// Whether to require re-authentication for sensitive operations.
  static bool? get requireReAuthForSensitiveOps => appConfig.requireReAuthForSensitiveOps;

  /// The re-authentication validity period.
  static Duration? get reAuthValidityPeriod => appConfig.reAuthValidityPeriod;

  /// Whether to enable single sign-on (SSO).
  static bool? get enableSSO => appConfig.enableSSO;

  /// The SSO provider configuration.
  static Map<String, String>? get ssoProviderConfig => appConfig.ssoProviderConfig;

  /// Whether to enable remember me functionality.
  static bool? get enableRememberMe => appConfig.enableRememberMe;

  /// The remember me duration.
  static Duration? get rememberMeDuration => appConfig.rememberMeDuration;

  // ========== Password & PIN Security ==========
  /// The minimum password length.
  static int? get minPasswordLength => appConfig.minPasswordLength;

  /// The maximum password length.
  static int? get maxPasswordLength => appConfig.maxPasswordLength;

  /// Whether to require uppercase letters in password.
  static bool? get requirePasswordUppercase => appConfig.requirePasswordUppercase;

  /// Whether to require lowercase letters in password.
  static bool? get requirePasswordLowercase => appConfig.requirePasswordLowercase;

  /// Whether to require numbers in password.
  static bool? get requirePasswordNumbers => appConfig.requirePasswordNumbers;

  /// Whether to require special characters in password.
  static bool? get requirePasswordSpecialChars => appConfig.requirePasswordSpecialChars;

  /// The password history count (prevent reuse).
  static int? get passwordHistoryCount => appConfig.passwordHistoryCount;

  /// The password expiration period.
  static Duration? get passwordExpirationPeriod => appConfig.passwordExpirationPeriod;

  /// The minimum password change interval.
  static Duration? get minPasswordChangeInterval => appConfig.minPasswordChangeInterval;

  /// The maximum login attempts before lockout.
  static int? get maxLoginAttempts => appConfig.maxLoginAttempts;

  /// The account lockout duration.
  static Duration? get accountLockoutDuration => appConfig.accountLockoutDuration;

  /// Whether to enable progressive lockout delays.
  static bool? get enableProgressiveLockout => appConfig.enableProgressiveLockout;

  /// The PIN length.
  static int? get pinLength => appConfig.pinLength;

  /// Whether to allow sequential PIN patterns.
  static bool? get allowSequentialPinPatterns => appConfig.allowSequentialPinPatterns;

  /// Whether to allow repeated PIN digits.
  static bool? get allowRepeatedPinDigits => appConfig.allowRepeatedPinDigits;

  // ========== Biometric Authentication ==========
  /// The supported biometric types (FINGERPRINT, FACE, VOICE).
  static List<String>? get supportedBiometricTypes => appConfig.supportedBiometricTypes;

  /// Whether to enable fallback to PIN/Password.
  static bool? get enableBiometricFallback => appConfig.enableBiometricFallback;

  /// The biometric authentication timeout.
  static Duration? get biometricAuthTimeout => appConfig.biometricAuthTimeout;

  /// The maximum biometric retry attempts.
  static int? get maxBiometricRetryAttempts => appConfig.maxBiometricRetryAttempts;

  /// Whether to enable biometric template storage.
  static bool? get enableBiometricTemplateStorage => appConfig.enableBiometricTemplateStorage;

  /// Whether to require liveness detection.
  static bool? get requireLivenessDetection => appConfig.requireLivenessDetection;

  /// The biometric quality threshold (0.0 to 1.0).
  static double? get biometricQualityThreshold => appConfig.biometricQualityThreshold;

  // ========== Data Encryption & Protection ==========
  /// The encryption algorithm (AES256, RSA2048, etc.).
  static String? get encryptionAlgorithm => appConfig.encryptionAlgorithm;

  /// The key derivation function (PBKDF2, Argon2, etc.).
  static String? get keyDerivationFunction => appConfig.keyDerivationFunction;

  /// The key derivation iterations.
  static int? get keyDerivationIterations => appConfig.keyDerivationIterations;

  /// The salt length for key derivation.
  static int? get saltLength => appConfig.saltLength;

  /// Whether to enable end-to-end encryption.
  static bool? get enableEndToEndEncryption => appConfig.enableEndToEndEncryption;

  /// Whether to enable data at rest encryption.
  static bool? get enableDataAtRestEncryption => appConfig.enableDataAtRestEncryption;

  /// Whether to enable data in transit encryption.
  static bool? get enableDataInTransitEncryption => appConfig.enableDataInTransitEncryption;

  /// The TLS/SSL version (TLS1.2, TLS1.3).
  static String? get tlsVersion => appConfig.tlsVersion;

  /// Whether to enable certificate pinning.
  static bool? get enableCertificatePinning => appConfig.enableCertificatePinning;

  /// The certificate pinning hashes.
  static List<String>? get certificatePinningHashes => appConfig.certificatePinningHashes;

  /// Whether to enable HSTS (HTTP Strict Transport Security).
  static bool? get enableHSTS => appConfig.enableHSTS;

  /// The HSTS max age in seconds.
  static int? get hstsMaxAge => appConfig.hstsMaxAge;

  // ========== Privacy & Data Protection ==========
  /// Whether to enable data anonymization.
  static bool? get enableDataAnonymization => appConfig.enableDataAnonymization;

  /// The data retention period.
  static Duration? get dataRetentionPeriod => appConfig.dataRetentionPeriod;

  /// Whether to enable right to be forgotten.
  static bool? get enableRightToBeForgotten => appConfig.enableRightToBeForgotten;

  /// Whether to enable data portability.
  static bool? get enableDataPortability => appConfig.enableDataPortability;

  /// The supported data export formats.
  static List<String>? get supportedDataExportFormats => appConfig.supportedDataExportFormats;

  /// Whether to enable consent management.
  static bool? get enableConsentManagement => appConfig.enableConsentManagement;

  /// The consent expiration period.
  static Duration? get consentExpirationPeriod => appConfig.consentExpirationPeriod;

  /// Whether to enable privacy mode.
  static bool? get enablePrivacyMode => appConfig.enablePrivacyMode;

  /// Whether to enable incognito mode.
  static bool? get enableIncognitoMode => appConfig.enableIncognitoMode;

  // ========== Fraud Detection & Prevention ==========
  /// Whether to enable fraud detection.
  static bool? get enableFraudDetection => appConfig.enableFraudDetection;

  /// The fraud detection sensitivity (LOW, MEDIUM, HIGH).
  static String? get fraudDetectionSensitivity => appConfig.fraudDetectionSensitivity;

  /// Whether to enable velocity checking.
  static bool? get enableVelocityChecking => appConfig.enableVelocityChecking;

  /// The maximum transactions per minute.
  static int? get maxTransactionsPerMinute => appConfig.maxTransactionsPerMinute;

  /// The maximum transactions per hour.
  static int? get maxTransactionsPerHour => appConfig.maxTransactionsPerHour;

  /// The maximum transactions per day.
  static int? get maxTransactionsPerDay => appConfig.maxTransactionsPerDay;

  /// Whether to enable geolocation fraud detection.
  static bool? get enableGeolocationFraudDetection => appConfig.enableGeolocationFraudDetection;

  /// The maximum distance for simultaneous logins (km).
  static double? get maxSimultaneousLoginDistance => appConfig.maxSimultaneousLoginDistance;

  /// Whether to enable device reputation checking.
  static bool? get enableDeviceReputationCheck => appConfig.enableDeviceReputationCheck;

  /// Whether to enable IP reputation checking.
  static bool? get enableIPReputationCheck => appConfig.enableIPReputationCheck;

  /// The IP whitelist.
  static List<String>? get ipWhitelist => appConfig.ipWhitelist;

  /// The IP blacklist.
  static List<String>? get ipBlacklist => appConfig.ipBlacklist;

  // ========== Audit & Compliance ==========
  /// Whether to enable audit logging.
  static bool? get enableAuditLogging => appConfig.enableAuditLogging;

  /// The audit log retention period.
  static Duration? get auditLogRetentionPeriod => appConfig.auditLogRetentionPeriod;

  /// Whether to enable compliance reporting.
  static bool? get enableComplianceReporting => appConfig.enableComplianceReporting;

  /// The compliance standards (GDPR, CCPA, HIPAA, etc.).
  static List<String>? get complianceStandards => appConfig.complianceStandards;

  /// Whether to enable data loss prevention.
  static bool? get enableDataLossPrevention => appConfig.enableDataLossPrevention;

  /// Whether to enable screen recording detection.
  static bool? get enableScreenRecordingDetection => appConfig.enableScreenRecordingDetection;

  /// Whether to enable screenshot prevention.
  static bool? get enableScreenshotPrevention => appConfig.enableScreenshotPrevention;

  /// Whether to enable watermarking.
  static bool? get enableWatermarking => appConfig.enableWatermarking;

  /// The watermark text.
  static String? get watermarkText => appConfig.watermarkText;

  // ========== Database Configuration ==========
  /// The database name.
  static String? get databaseName => appConfig.databaseName;

  /// The database version.
  static int? get databaseVersion => appConfig.databaseVersion;

  /// The maximum database connections.
  static int? get maxDatabaseConnections => appConfig.maxDatabaseConnections;

  /// The database timeout.
  static Duration? get databaseTimeout => appConfig.databaseTimeout;

  /// Whether to enable database encryption.
  static bool? get enableDatabaseEncryption => appConfig.enableDatabaseEncryption;

  // ========== Cache Configuration ==========
  /// The maximum cache size in bytes.
  static int? get maxCacheSize => appConfig.maxCacheSize;

  /// The cache expiration time.
  static Duration? get cacheExpirationTime => appConfig.cacheExpirationTime;

  /// The maximum number of cache entries.
  static int? get maxCacheEntries => appConfig.maxCacheEntries;

  /// Whether to enable disk cache.
  static bool? get enableDiskCache => appConfig.enableDiskCache;

  /// Whether to enable memory cache.
  static bool? get enableMemoryCache => appConfig.enableMemoryCache;

  /// The cache directory path.
  static String? get cacheDirectoryPath => appConfig.cacheDirectoryPath;

  //! ========== URL Update Methods ==========

  /// Update the API base URL
  static void updateApiBaseUrl(String newUrl) {
    if (_config != null) {
      _config!.updateApiBaseUrl(newUrl);
      printS('Update Api Base Url: $newUrl');
    } else {
      throw Exception('AppConfig has not been initialized. Call AppConfigManagerBase.initialize() first.');
    }
  }

  /// Update the WebSocket base URL
  static void updateWebSocketBaseUrl(String newUrl) {
    if (_config != null) {
      _config!.updateWebSocketBaseUrl(newUrl);
      printS('Update Ws Base Url: $newUrl');
    } else {
      throw Exception('AppConfig has not been initialized. Call AppConfigManagerBase.initialize() first.');
    }
  }

  // ========== Storage Configuration ==========
  /// The maximum file size for uploads in bytes.
  static int? get maxFileUploadSize => appConfig.maxFileUploadSize;

  /// The allowed file extensions for uploads.
  static List<String>? get allowedFileExtensions => appConfig.allowedFileExtensions;

  /// The storage bucket name.
  static String? get storageBucketName => appConfig.storageBucketName;

  /// The storage region.
  static String? get storageRegion => appConfig.storageRegion;

  /// The CDN base URL.
  static String? get cdnBaseUrl => appConfig.cdnBaseUrl;

  // ========== Firebase ==========
  // Android
  static String? get apiKeyAndroid => appConfig.apiKeyAndroid;
  static String? get appIdAndroid => appConfig.appIdAndroid;
  static String? get messagingSenderIdAndroid => appConfig.messagingSenderIdAndroid;

  // Ios
  static String? get apiKeyIOS => appConfig.apiKeyIOS;
  static String? get appIdIOS => appConfig.appIdIOS;
  static String? get messagingSenderIdIOS => appConfig.messagingSenderIdIOS;

  // ========== Push Notifications ==========
  /// The Firebase project ID.
  static String? get firebaseProjectId => appConfig.firebaseProjectId;

  /// The Firebase API key.
  static String? get firebaseApiKey => appConfig.firebaseApiKey;

  /// The Firebase sender ID.
  static String? get firebaseSenderId => appConfig.firebaseSenderId;

  /// The OneSignal app ID.
  static String? get oneSignalAppId => appConfig.oneSignalAppId;

  /// Whether push notifications are enabled.
  static bool? get enablePushNotifications => appConfig.enablePushNotifications;

  // ========== Analytics & Monitoring ==========
  /// The Firebase Analytics enabled flag.
  static bool? get enableFirebaseAnalytics => appConfig.enableFirebaseAnalytics;

  /// The Google Analytics tracking ID.
  static String? get googleAnalyticsTrackingId => appConfig.googleAnalyticsTrackingId;

  /// The Crashlytics enabled flag.
  static bool? get enableCrashlytics => appConfig.enableCrashlytics;

  /// The Sentry DSN.
  static String? get sentryDsn => appConfig.sentryDsn;

  /// Whether to enable performance monitoring.
  static bool? get enablePerformanceMonitoring => appConfig.enablePerformanceMonitoring;

  /// The log level (debug, info, warning, error).
  static String? get logLevel => appConfig.logLevel;

  /// Whether to enable remote logging.
  static bool? get enableRemoteLogging => appConfig.enableRemoteLogging;

  // ========== UI/UX Configuration ==========
  /// The default theme mode (light, dark, system).
  static String? get defaultThemeMode => appConfig.defaultThemeMode;

  /// The primary color.
  static String? get primaryColor => appConfig.primaryColor;

  /// The secondary color.
  static String? get secondaryColor => appConfig.secondaryColor;

  /// The default locale.
  static String? get defaultLocale => appConfig.defaultLocale;

  /// The supported locales.
  static List<String>? get supportedLocales => appConfig.supportedLocales;

  /// Whether to enable haptic feedback.
  static bool? get enableHapticFeedback => appConfig.enableHapticFeedback;

  /// The default animation duration.
  static Duration? get defaultAnimationDuration => appConfig.defaultAnimationDuration;

  // ========== Feature Flags ==========
  /// Whether to enable experimental features.
  static bool? get enableExperimentalFeatures => appConfig.enableExperimentalFeatures;

  /// Whether to enable beta features.
  static bool? get enableBetaFeatures => appConfig.enableBetaFeatures;

  /// Whether to enable A/B testing.
  static bool? get enableABTesting => appConfig.enableABTesting;

  /// The feature flags configuration.
  static Map<String, bool>? get featureFlags => appConfig.featureFlags;

  // ========== Social Media Integration ==========
  /// The Facebook app ID.
  static String? get facebookAppId => appConfig.facebookAppId;

  /// The Twitter consumer key.
  static String? get twitterConsumerKey => appConfig.twitterConsumerKey;

  /// The Google sign-in client ID.
  static String? get googleSignInClientId => appConfig.googleSignInClientId;

  /// The Apple sign-in service ID.
  static String? get appleSignInServiceId => appConfig.appleSignInServiceId;

  // ========== Payment Configuration ==========
  /// The Stripe publishable key.
  static String? get stripePublishableKey => appConfig.stripePublishableKey;

  /// The PayPal client ID.
  static String? get paypalClientId => appConfig.paypalClientId;

  /// Whether to enable in-app purchases.
  static bool? get enableInAppPurchases => appConfig.enableInAppPurchases;

  /// The supported payment methods.
  static List<String>? get supportedPaymentMethods => appConfig.supportedPaymentMethods;

  // ========== Location & Maps ==========
  /// The Google Maps API key.
  static String? get googleMapsApiKey => appConfig.googleMapsApiKey;

  /// The location accuracy (high, medium, low).
  static String? get locationAccuracy => appConfig.locationAccuracy;

  /// The location update interval.
  static Duration? get locationUpdateInterval => appConfig.locationUpdateInterval;

  /// Whether to enable background location.
  static bool? get enableBackgroundLocation => appConfig.enableBackgroundLocation;

  // ========== Device & Platform ==========
  /// The minimum supported OS version (iOS/Android).
  static String? get minSupportedOSVersion => appConfig.minSupportedOSVersion;

  /// The target SDK version.
  static int? get targetSdkVersion => appConfig.targetSdkVersion;

  /// Whether to enable deep linking.
  static bool? get enableDeepLinking => appConfig.enableDeepLinking;

  /// The deep link scheme.
  static String? get deepLinkScheme => appConfig.deepLinkScheme;

  /// Whether to enable app shortcuts (Android).
  static bool? get enableAppShortcuts => appConfig.enableAppShortcuts;

  // ========== Development & Testing ==========
  /// Whether to enable developer mode.
  static bool? get enableDeveloperMode => appConfig.enableDeveloperMode;

  /// Whether to show debug information.
  static bool? get showDebugInfo => appConfig.showDebugInfo;

  /// Whether to enable mock data.
  static bool? get enableMockData => appConfig.enableMockData;

  /// The test environment base URL.
  static String? get testEnvironmentBaseUrl => appConfig.testEnvironmentBaseUrl;

  /// Whether to enable integration tests.
  static bool? get enableIntegrationTests => appConfig.enableIntegrationTests;

  // ========== Performance ==========
  /// The maximum memory usage in MB.
  static int? get maxMemoryUsage => appConfig.maxMemoryUsage;

  /// The frame rate target (30, 60, 120).
  static int? get targetFrameRate => appConfig.targetFrameRate;

  /// Whether to enable performance profiling.
  static bool? get enablePerformanceProfiling => appConfig.enablePerformanceProfiling;

  /// The image compression quality (0.0 to 1.0).
  static double? get imageCompressionQuality => appConfig.imageCompressionQuality;

  /// The maximum concurrent operations.
  static int? get maxConcurrentOperations => appConfig.maxConcurrentOperations;

  // ========== Accessibility ==========
  /// Whether to enable accessibility features.
  static bool? get enableAccessibility => appConfig.enableAccessibility;

  /// The default font size multiplier.
  static double? get defaultFontSizeMultiplier => appConfig.defaultFontSizeMultiplier;

  /// Whether to enable high contrast mode.
  static bool? get enableHighContrastMode => appConfig.enableHighContrastMode;

  /// Whether to enable screen reader support.
  static bool? get enableScreenReaderSupport => appConfig.enableScreenReaderSupport;

  // ========== Backup & Sync ==========
  /// Whether to enable automatic backup.
  static bool? get enableAutomaticBackup => appConfig.enableAutomaticBackup;

  /// The backup interval.
  static Duration? get backupInterval => appConfig.backupInterval;

  /// Whether to enable cloud sync.
  static bool? get enableCloudSync => appConfig.enableCloudSync;

  /// The sync interval.
  static Duration? get syncInterval => appConfig.syncInterval;

  /// The maximum backup size in MB.
  static int? get maxBackupSize => appConfig.maxBackupSize;
}
