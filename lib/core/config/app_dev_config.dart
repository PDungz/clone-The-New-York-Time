import 'package:news_app/core/base/config/app_config_base.dart';
import 'package:news_app/core/config/config_env/env_dev.dart';

/// Development configuration for the News App
/// This configuration is used during development and testing phases
class AppDevConfig implements AppConfigBase {
  // Private variables to store dynamic URLs
  String? _dynamicApiBaseUrl;
  String? _dynamicWebSocketBaseUrl;

  // ========== API Configuration ==========
  @override
  String get apiBaseUrl => _dynamicApiBaseUrl ?? EnvDev.baseUrl; // The base URL for the API

  @override
  String get apiBaseUrlNYT => EnvDev.baseUrlNYT; // The base URL for the API

  @override
  String get apiKeyNYTimes => EnvDev.apiKeyNYTimes; // The API key

  //! ========== WebSocket Configuration ==========

  @override
  String get wsBaseUrl => _dynamicWebSocketBaseUrl ?? EnvDev.wsBaseUrl;

  @override
  String get wsNotificationNative => EnvDev.wsNotificationNative;

  @override
  String get wsNotificationUnread => EnvDev.wsNotificationUnread;

  //! ========== Auth API Endpoints ==========

  @override
  String get apiAuthLogin => EnvDev.apiAuthLogin;

  @override
  String get apiAuthBiometricLogin => EnvDev.apiAuthBiometricLogin;

  @override
  String get apiAuthRegister => EnvDev.apiAuthRegister;

  @override
  String get apiAuthRefresh => EnvDev.apiAuthRefresh;

  @override
  String get apiAuthLogout => EnvDev.apiAuthLogout;

  @override
  String get apiAuthChangePassword => EnvDev.apiAuthChangePassword;

  //! ========== Device API Endpoints ==========

  @override
  String get apiDeviceCreate => EnvDev.apiDeviceCreate;

  @override
  String get apiDeviceGetById => EnvDev.apiDeviceGetById;

  @override
  String get apiDeviceGetUserById => EnvDev.apiDeviceGetUserById;

  @override
  String get apiDeviceDeleteById => EnvDev.apiDeviceDeleteById;

  @override
  String get apiDeviceManagementCreate => EnvDev.apiDeviceManagementCreate;

  @override
  String get apiDeviceManagementListUser => EnvDev.apiDeviceManagementListUser;

  @override
  String get apiDeviceManagementDelete => EnvDev.apiDeviceManagementDelete;

  @override
  String get apiDeviceManagementUpdateBiometric => EnvDev.apiDeviceManagementUpdateBiometric;

  //! ========== Notification API Endpoints ==========

  @override
  String get apiNotificationsUser => EnvDev.apiNotificationsUser;

  @override
  String get apiNotificationsUserUnread => EnvDev.apiNotificationsUserUnread;

  @override
  String get apiNotificationsUserRead => EnvDev.apiNotificationsUserRead;

  @override
  String get apiNotificationsUserReadAll => EnvDev.apiNotificationsUserReadAll;

  @override
  String get apiNotificationsCountUnread => EnvDev.apiNotificationsCountUnread;

  @override
  String get apiNotificationsCategories => EnvDev.apiNotificationsCategories;

  @override
  String get apiNotificationsHealth => EnvDev.apiNotificationsHealth;

  @override
  String get apiNotificationsTopicSubscribe => EnvDev.apiNotificationsTopicSubscribe;

  @override
  String get apiNotificationsTopicUnsubscribe => EnvDev.apiNotificationsTopicUnsubscribe;

  @override
  String get apiNotificationsValidateToken => EnvDev.apiNotificationsValidateToken;

  //! ========== Dynamic URL Methods ==========

  @override
  String topStoriesUrl({required String section}) => EnvDev.topStoriesUrl(section: section);

  @override
  String apiDeviceManagementInfoIndentifierUserId({
    required String deviceIdentifier,
    required String userId,
  }) => EnvDev.apiDeviceManagementInfoIndentifierUserId(
    deviceIdentifier: deviceIdentifier,
    userId: userId,
  );

  @override
  String apiNotificationsUserCategory({required String categoryName}) =>
      EnvDev.apiNotificationsUserCategory(categoryName: categoryName);

  @override
  String apiNotificationsUserStatus({required String status}) =>
      EnvDev.apiNotificationsUserStatus(status: status);

  @override
  String apiNotificationsMarkRead({required String notificationId}) =>
      EnvDev.apiNotificationsMarkRead(notificationId: notificationId);

  @override
  String apiNotificationsCountStatus({required String status}) =>
      EnvDev.apiNotificationsCountStatus(status: status);

  @override
  String apiNotificationsDelete({required String notificationId}) =>
      EnvDev.apiNotificationsDelete(notificationId: notificationId);


  @override
  String? get webSocketBaseUrl => _dynamicWebSocketBaseUrl ?? EnvDev.wsBaseUrl; // The base URL for the WebSocket connection

  @override
  String? get webrtcSignalingUrl => ''; // The base URL for the WebRTC signaling server

  @override
  String? get webrtcStunUrl => ''; // The base URL for the WebRTC STUN server

  @override
  String? get webrtcTurnUrl => ''; // The base URL for the WebRTC TURN server

  @override
  String get apiVersion => ''; // The version of the API

  @override
  Duration? get apiTimeout => null; // The timeout duration for API requests

  @override
  Duration? get webSocketTimeout => null; // The timeout duration for WebSocket connections

  @override
  Duration? get webrtcTimeout => null; // The timeout duration for WebRTC connections

  @override
  int? get maxRetries => null; // The maximum number of retries for API requests

  @override
  Duration? get retryInterval => null; // The interval between retries for API requests

  @override
  int? get maxWebSocketConnections => null; // The maximum number of connections for WebSocket

  @override
  int? get maxWebRTCConnections => null; // The maximum number of connections for WebRTC

  @override
  int? get maxWebRTCDataChannelSize => null; // The maximum size of the WebRTC data channel

  @override
  int? get maxWebRTCMediaChannelSize => null; // The maximum size of the WebRTC media channel

  @override
  int? get maxWebRTCDataChannelBufferSize => null; // The maximum size of the WebRTC data channel buffer

  // ========== App Information ==========
  @override
  String get appName => ''; // The name of the application

  @override
  String get appVersion => '1.0.0'; // The version of the application

  @override
  String? get buildNumber => ''; // The build number of the application

  @override
  String get bundleId => ''; // The bundle identifier (iOS) or package name (Android)

  @override
  String get environment => ''; // The environment (dev, staging, production)

  @override
  bool get isDebugMode => false; // Whether the app is in debug mode

  @override
  bool get isProduction => false; // Whether the app is in production mode

  // ========== Authentication & Security ==========
  @override
  String? get oauthClientId => ''; // The OAuth client ID

  @override
  String? get oauthClientSecret => ''; // The OAuth client secret

  @override
  String? get oauthRedirectUri => ''; // The OAuth redirect URI

  @override
  List<String>? get oauthScopes => null; // The OAuth scopes

  @override
  String? get jwtSecretKey => ''; // The JWT secret key

  @override
  Duration? get jwtExpirationTime => null; // The JWT expiration time

  @override
  Duration? get refreshTokenExpirationTime => null; // The refresh token expiration time

  @override
  bool? get useBiometricAuth => null; // Whether to use biometric authentication

  @override
  String? get encryptionKey => ''; // The encryption key for local storage

  // ========== Device Management & Security ==========
  @override
  bool? get enableDeviceRegistration => null; // Whether to enable device registration

  @override
  int? get maxDevicesPerUser => null; // The maximum number of devices per user

  @override
  bool? get requireDeviceVerification => null; // Whether to require device verification

  @override
  Duration? get deviceVerificationTimeout => null; // The device verification timeout

  @override
  bool? get enableDeviceFingerprinting => null; // Whether to enable device fingerprinting

  @override
  Duration? get deviceSessionTimeout => null; // The device session timeout

  @override
  bool? get enableDeviceTracking => null; // Whether to enable device tracking

  @override
  bool? get requireDevicePin => null; // Whether to require device PIN/Pattern

  @override
  int? get devicePinRetryLimit => null; // The device PIN/Pattern retry limit

  @override
  Duration? get deviceLockoutDuration => null; // The device lockout duration after max retries

  @override
  bool? get enableRemoteDeviceWipe => null; // Whether to enable remote device wipe

  @override
  bool? get enableDeviceLocationTracking => null; // Whether to enable device location tracking

  @override
  Duration? get deviceCheckInInterval => null; // The device check-in interval

  @override
  bool? get enableDeviceComplianceCheck => null; // Whether to enable device compliance checking

  @override
  String? get minSecurityPatchLevel => ''; // The minimum required security patch level

  @override
  bool? get allowRootedDevices => null; // Whether to allow rooted/jailbroken devices

  @override
  bool? get enableDeviceCertificatePinning => null; // Whether to enable device certificate pinning

  // ========== Multi-Factor Authentication ==========
  @override
  bool? get enableMFA => null; // Whether to enable multi-factor authentication

  @override
  bool? get requireMFAForAllUsers => null; // Whether to require MFA for all users

  @override
  List<String>? get supportedMFAMethods => null; // The supported MFA methods (SMS, EMAIL, TOTP, PUSH)

  @override
  String? get defaultMFAMethod => ''; // The default MFA method

  @override
  Duration? get mfaTokenExpiration => null; // The MFA token expiration time

  @override
  int? get mfaBackupCodesCount => null; // The MFA backup codes count

  @override
  bool? get enableTOTP => null; // Whether to enable TOTP (Time-based OTP)

  @override
  int? get totpTimeStep => null; // The TOTP time step in seconds

  @override
  int? get totpCodeLength => null; // The TOTP code length

  @override
  bool? get enableSMSOTP => null; // Whether to enable SMS OTP

  @override
  Duration? get smsOTPExpiration => null; // The SMS OTP expiration time

  @override
  bool? get enableEmailOTP => null; // Whether to enable email OTP

  @override
  Duration? get emailOTPExpiration => null; // The email OTP expiration time

  @override
  bool? get enablePushMFA => null; // Whether to enable push notifications for MFA

  @override
  Duration? get pushMFATimeout => null; // The push MFA timeout

  // ========== Session Management ==========
  @override
  int? get maxConcurrentSessions => null; // The maximum concurrent sessions per user

  @override
  Duration? get sessionIdleTimeout => null; // The session idle timeout

  @override
  Duration? get sessionAbsoluteTimeout => null; // The absolute session timeout

  @override
  bool? get enableSessionSlidingExpiration => null; // Whether to enable session sliding expiration

  @override
  bool? get requireReAuthForSensitiveOps => null; // Whether to require re-authentication for sensitive operations

  @override
  Duration? get reAuthValidityPeriod => null; // The re-authentication validity period

  @override
  bool? get enableSSO => null; // Whether to enable single sign-on (SSO)

  @override
  Map<String, String>? get ssoProviderConfig => null; // The SSO provider configuration

  @override
  bool? get enableRememberMe => null; // Whether to enable remember me functionality

  @override
  Duration? get rememberMeDuration => null; // The remember me duration

  // ========== Password & PIN Security ==========
  @override
  int? get minPasswordLength => null; // The minimum password length

  @override
  int? get maxPasswordLength => null; // The maximum password length

  @override
  bool? get requirePasswordUppercase => null; // Whether to require uppercase letters in password

  @override
  bool? get requirePasswordLowercase => null; // Whether to require lowercase letters in password

  @override
  bool? get requirePasswordNumbers => null; // Whether to require numbers in password

  @override
  bool? get requirePasswordSpecialChars => null; // Whether to require special characters in password

  @override
  int? get passwordHistoryCount => null; // The password history count (prevent reuse)

  @override
  Duration? get passwordExpirationPeriod => null; // The password expiration period

  @override
  Duration? get minPasswordChangeInterval => null; // The minimum password change interval

  @override
  int? get maxLoginAttempts => null; // The maximum login attempts before lockout

  @override
  Duration? get accountLockoutDuration => null; // The account lockout duration

  @override
  bool? get enableProgressiveLockout => null; // Whether to enable progressive lockout delays

  @override
  int? get pinLength => null; // The PIN length

  @override
  bool? get allowSequentialPinPatterns => null; // Whether to allow sequential PIN patterns

  @override
  bool? get allowRepeatedPinDigits => null; // Whether to allow repeated PIN digits

  // ========== Biometric Authentication ==========
  @override
  List<String>? get supportedBiometricTypes => null; // The supported biometric types (FINGERPRINT, FACE, VOICE)

  @override
  bool? get enableBiometricFallback => null; // Whether to enable fallback to PIN/Password

  @override
  Duration? get biometricAuthTimeout => null; // The biometric authentication timeout

  @override
  int? get maxBiometricRetryAttempts => null; // The maximum biometric retry attempts

  @override
  bool? get enableBiometricTemplateStorage => null; // Whether to enable biometric template storage

  @override
  bool? get requireLivenessDetection => null; // Whether to require liveness detection

  @override
  double? get biometricQualityThreshold => null; // The biometric quality threshold (0.0 to 1.0)

  // ========== Data Encryption & Protection ==========
  @override
  String? get encryptionAlgorithm => ''; // The encryption algorithm (AES256, RSA2048, etc.)

  @override
  String? get keyDerivationFunction => ''; // The key derivation function (PBKDF2, Argon2, etc.)

  @override
  int? get keyDerivationIterations => null; // The key derivation iterations

  @override
  int? get saltLength => null; // The salt length for key derivation

  @override
  bool? get enableEndToEndEncryption => null; // Whether to enable end-to-end encryption

  @override
  bool? get enableDataAtRestEncryption => null; // Whether to enable data at rest encryption

  @override
  bool? get enableDataInTransitEncryption => null; // Whether to enable data in transit encryption

  @override
  String? get tlsVersion => ''; // The TLS/SSL version (TLS1.2, TLS1.3)

  @override
  bool? get enableCertificatePinning => null; // Whether to enable certificate pinning

  @override
  List<String>? get certificatePinningHashes => null; // The certificate pinning hashes

  @override
  bool? get enableHSTS => null; // Whether to enable HSTS (HTTP Strict Transport Security)

  @override
  int? get hstsMaxAge => null; // The HSTS max age in seconds

  // ========== Privacy & Data Protection ==========
  @override
  bool? get enableDataAnonymization => null; // Whether to enable data anonymization

  @override
  Duration? get dataRetentionPeriod => null; // The data retention period

  @override
  bool? get enableRightToBeForgotten => null; // Whether to enable right to be forgotten

  @override
  bool? get enableDataPortability => null; // Whether to enable data portability

  @override
  List<String>? get supportedDataExportFormats => null; // The supported data export formats

  @override
  bool? get enableConsentManagement => null; // Whether to enable consent management

  @override
  Duration? get consentExpirationPeriod => null; // The consent expiration period

  @override
  bool? get enablePrivacyMode => null; // Whether to enable privacy mode

  @override
  bool? get enableIncognitoMode => null; // Whether to enable incognito mode

  // ========== Fraud Detection & Prevention ==========
  @override
  bool? get enableFraudDetection => null; // Whether to enable fraud detection

  @override
  String? get fraudDetectionSensitivity => ''; // The fraud detection sensitivity (LOW, MEDIUM, HIGH)

  @override
  bool? get enableVelocityChecking => null; // Whether to enable velocity checking

  @override
  int? get maxTransactionsPerMinute => null; // The maximum transactions per minute

  @override
  int? get maxTransactionsPerHour => null; // The maximum transactions per hour

  @override
  int? get maxTransactionsPerDay => null; // The maximum transactions per day

  @override
  bool? get enableGeolocationFraudDetection => null; // Whether to enable geolocation fraud detection

  @override
  double? get maxSimultaneousLoginDistance => null; // The maximum distance for simultaneous logins (km)

  @override
  bool? get enableDeviceReputationCheck => null; // Whether to enable device reputation checking

  @override
  bool? get enableIPReputationCheck => null; // Whether to enable IP reputation checking

  @override
  List<String>? get ipWhitelist => null; // The IP whitelist

  @override
  List<String>? get ipBlacklist => null; // The IP blacklist

  // ========== Audit & Compliance ==========
  @override
  bool? get enableAuditLogging => null; // Whether to enable audit logging

  @override
  Duration? get auditLogRetentionPeriod => null; // The audit log retention period

  @override
  bool? get enableComplianceReporting => null; // Whether to enable compliance reporting

  @override
  List<String>? get complianceStandards => null; // The compliance standards (GDPR, CCPA, HIPAA, etc.)

  @override
  bool? get enableDataLossPrevention => null; // Whether to enable data loss prevention

  @override
  bool? get enableScreenRecordingDetection => null; // Whether to enable screen recording detection

  @override
  bool? get enableScreenshotPrevention => null; // Whether to enable screenshot prevention

  @override
  bool? get enableWatermarking => null; // Whether to enable watermarking

  @override
  String? get watermarkText => ''; // The watermark text

  // ========== Database Configuration ==========
  @override
  String? get databaseName => ''; // The database name

  @override
  int? get databaseVersion => null; // The database version

  @override
  int? get maxDatabaseConnections => null; // The maximum database connections

  @override
  Duration? get databaseTimeout => null; // The database timeout

  @override
  bool? get enableDatabaseEncryption => null; // Whether to enable database encryption

  // ========== Cache Configuration ==========
  @override
  int? get maxCacheSize => null; // The maximum cache size in bytes

  @override
  Duration? get cacheExpirationTime => null; // The cache expiration time

  @override
  int? get maxCacheEntries => null; // The maximum number of cache entries

  @override
  bool? get enableDiskCache => null; // Whether to enable disk cache

  @override
  bool? get enableMemoryCache => null; // Whether to enable memory cache

  @override
  String? get cacheDirectoryPath => ''; // The cache directory path

  // ========== Storage Configuration ==========
  @override
  int? get maxFileUploadSize => null; // The maximum file size for uploads in bytes

  @override
  List<String>? get allowedFileExtensions => null; // The allowed file extensions for uploads

  @override
  String? get storageBucketName => ''; // The storage bucket name

  @override
  String? get storageRegion => ''; // The storage region

  @override
  String? get cdnBaseUrl => ''; // The CDN base URL

  // ========== Firebase ==========
  // Android
  @override
  String? get apiKeyAndroid => EnvDev.apiKeyAndroid;
  @override
  String? get appIdAndroid => EnvDev.appIdAndroid;
  @override
  String? get messagingSenderIdAndroid => EnvDev.messagingSenderIdAndroid;

  // Ios
  @override
  String? get apiKeyIOS => EnvDev.apiKeyIOS;
  @override
  String? get appIdIOS => EnvDev.appIdIOS;
  @override
  String? get messagingSenderIdIOS => EnvDev.messagingSenderIdIOS;

  // ========== Push Notifications ==========
  @override
  String? get firebaseProjectId => ''; // The Firebase project ID

  @override
  String? get firebaseApiKey => ''; // The Firebase API key

  @override
  String? get firebaseSenderId => ''; // The Firebase sender ID

  @override
  String? get oneSignalAppId => ''; // The OneSignal app ID

  @override
  bool? get enablePushNotifications => null; // Whether push notifications are enabled

  // ========== Analytics & Monitoring ==========
  @override
  bool? get enableFirebaseAnalytics => null; // The Firebase Analytics enabled flag

  @override
  String? get googleAnalyticsTrackingId => ''; // The Google Analytics tracking ID

  @override
  bool? get enableCrashlytics => null; // The Crashlytics enabled flag

  @override
  String? get sentryDsn => ''; // The Sentry DSN

  @override
  bool? get enablePerformanceMonitoring => null; // Whether to enable performance monitoring

  @override
  String? get logLevel => ''; // The log level (debug, info, warning, error)

  @override
  bool? get enableRemoteLogging => null; // Whether to enable remote logging

  // ========== UI/UX Configuration ==========
  @override
  String? get defaultThemeMode => ''; // The default theme mode (light, dark, system)

  @override
  String? get primaryColor => ''; // The primary color

  @override
  String? get secondaryColor => ''; // The secondary color

  @override
  String? get defaultLocale => ''; // The default locale

  @override
  List<String>? get supportedLocales => null; // The supported locales

  @override
  bool? get enableHapticFeedback => null; // Whether to enable haptic feedback

  @override
  Duration? get defaultAnimationDuration => null; // The default animation duration

  // ========== Feature Flags ==========
  @override
  bool? get enableExperimentalFeatures => null; // Whether to enable experimental features

  @override
  bool? get enableBetaFeatures => null; // Whether to enable beta features

  @override
  bool? get enableABTesting => null; // Whether to enable A/B testing

  @override
  Map<String, bool>? get featureFlags => null; // The feature flags configuration

  // ========== Social Media Integration ==========
  @override
  String? get facebookAppId => ''; // The Facebook app ID

  @override
  String? get twitterConsumerKey => ''; // The Twitter consumer key

  @override
  String? get googleSignInClientId => ''; // The Google sign-in client ID

  @override
  String? get appleSignInServiceId => ''; // The Apple sign-in service ID

  // ========== Payment Configuration ==========
  @override
  String? get stripePublishableKey => ''; // The Stripe publishable key

  @override
  String? get paypalClientId => ''; // The PayPal client ID

  @override
  bool? get enableInAppPurchases => null; // Whether to enable in-app purchases

  @override
  List<String>? get supportedPaymentMethods => null; // The supported payment methods

  // ========== Location & Maps ==========
  @override
  String? get googleMapsApiKey => ''; // The Google Maps API key

  @override
  String? get locationAccuracy => ''; // The location accuracy (high, medium, low)

  @override
  Duration? get locationUpdateInterval => null; // The location update interval

  @override
  bool? get enableBackgroundLocation => null; // Whether to enable background location

  // ========== Device & Platform ==========
  @override
  String? get minSupportedOSVersion => ''; // The minimum supported OS version (iOS/Android)

  @override
  int? get targetSdkVersion => null; // The target SDK version

  @override
  bool? get enableDeepLinking => null; // Whether to enable deep linking

  @override
  String? get deepLinkScheme => ''; // The deep link scheme

  @override
  bool? get enableAppShortcuts => null; // Whether to enable app shortcuts (Android)

  // ========== Development & Testing ==========
  @override
  bool? get enableDeveloperMode => null; // Whether to enable developer mode

  @override
  bool? get showDebugInfo => null; // Whether to show debug information

  @override
  bool? get enableMockData => null; // Whether to enable mock data

  @override
  String? get testEnvironmentBaseUrl => ''; // The test environment base URL

  @override
  bool? get enableIntegrationTests => null; // Whether to enable integration tests

  // ========== Performance ==========
  @override
  int? get maxMemoryUsage => null; // The maximum memory usage in MB

  @override
  int? get targetFrameRate => null; // The frame rate target (30, 60, 120)

  @override
  bool? get enablePerformanceProfiling => null; // Whether to enable performance profiling

  @override
  double? get imageCompressionQuality => null; // The image compression quality (0.0 to 1.0)

  @override
  int? get maxConcurrentOperations => null; // The maximum concurrent operations

  // ========== Accessibility ==========
  @override
  bool? get enableAccessibility => null; // Whether to enable accessibility features

  @override
  double? get defaultFontSizeMultiplier => null; // The default font size multiplier

  @override
  bool? get enableHighContrastMode => null; // Whether to enable high contrast mode

  @override
  bool? get enableScreenReaderSupport => null; // Whether to enable screen reader support

  // ========== Backup & Sync ==========
  @override
  bool? get enableAutomaticBackup => null; // Whether to enable automatic backup

  @override
  Duration? get backupInterval => null; // The backup interval

  @override
  bool? get enableCloudSync => null; // Whether to enable cloud sync

  @override
  Duration? get syncInterval => null; // The sync interval

  @override
  int? get maxBackupSize => null; // The maximum backup size in MB

  //! ========== URL Update Methods ==========
  @override
  void updateApiBaseUrl(String newUrl) {
    _dynamicApiBaseUrl = newUrl;
  }

  @override
  void updateWebSocketBaseUrl(String newUrl) {
    _dynamicWebSocketBaseUrl = newUrl;
  }
}
