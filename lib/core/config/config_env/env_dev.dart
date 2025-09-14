import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvDev {
  EnvDev._();

  //! NYTimes API Config
  /// Base URL for the API
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get baseUrlNYT => dotenv.env['API_BASE_URL_NYT'] ?? '';
  static String get versionApi => dotenv.env['API_VERSION'] ?? '';
  static String get apiKeyNYTimes => dotenv.env['API_KEY'] ?? '';

  // Firebase Config
  // Android
  static String get apiKeyAndroid => dotenv.env['API_KEY_ANDROID'] ?? '';
  static String get appIdAndroid => dotenv.env['APP_ID_ANDROID'] ?? '';
  static String get messagingSenderIdAndroid => dotenv.env['MESSAGING_SENDER_ID_ANDROID'] ?? '';

  // Ios
  static String get apiKeyIOS => dotenv.env['API_KEY_IOS'] ?? '';
  static String get appIdIOS => dotenv.env['APP_ID_IOS'] ?? '';
  static String get messagingSenderIdIOS => dotenv.env['MESSAGING_SENDER_ID_IOS'] ?? '';

  // Top stories endpoint
  static String topStoriesUrl({required String section}) =>
      '${dotenv.env['TOP_STORIES_ENDPOINT']}'.replaceAll('{section}', section);

  //! NYTimes server CTM config

  //? Websocket Config
  static String get wsBaseUrl => dotenv.env['WS_BASE_URL_WEBSOCKET'] ?? '';
  static String get wsNotificationNative => dotenv.env['WS_NOTIFICATION_NATIVE'] ?? '';
  static String get wsNotificationUnread => dotenv.env['WS_NOTIFICATION_UNREAD'] ?? '';

  //? API Endpoints
  // Auth
  static String get apiAuthLogin => dotenv.env['API_LOGIN'] ?? '';
  static String get apiAuthBiometricLogin => dotenv.env['API_BIOMETRIC_LOGIN'] ?? '';
  static String get apiAuthRegister => dotenv.env['API_REGISTER'] ?? '';
  static String get apiAuthRefresh => dotenv.env['API_REFRESH'] ?? '';
  static String get apiAuthLogout => dotenv.env['API_LOGOUT'] ?? '';
  static String get apiAuthChangePassword => dotenv.env['API_CHANGE_PASSWORD'] ?? '';
  
  // Device
  static String get apiDeviceCreate => dotenv.env['API_DEVICE_CREATE'] ?? '';
  static String get apiDeviceGetById => dotenv.env['API_DEVICE_GET_BY_ID'] ?? '';
  static String get apiDeviceGetUserById => dotenv.env['API_DEVICE_GET_USER_BY_ID'] ?? '';
  static String get apiDeviceDeleteById => dotenv.env['API_DEVICE_DELETE_BY_ID'] ?? '';
  static String get apiDeviceManagementCreate => dotenv.env['API_DEVICE_MANAGEMENT_CREATE'] ?? '';
  static String get apiDeviceManagementListUser =>
      dotenv.env['API_DEVICE_MANAGEMENT_LIST_USER'] ?? '';
  static String get apiDeviceManagementDelete => dotenv.env['API_DEVICE_MANAGEMENT_DELETE'] ?? '';
  static String get apiDeviceManagementUpdateBiometric =>
      dotenv.env['API_DEVICE_MANAGEMENT_UPDATE_BIOMETRIC'] ?? '';
  static String apiDeviceManagementInfoIndentifierUserId({
    required String deviceIdentifier,
    required String userId,
  }) => '${dotenv.env['API_DEVICE_MANAGEMENT_INFO_IDENTIFIER_USER_ID']}'
      .replaceAll('{deviceIdentifier}', deviceIdentifier)
      .replaceAll('{userId}', userId);

  //? Notification API Endpoints
  // User endpoints
  static String get apiNotificationsUser => dotenv.env['API_NOTIFICATIONS_USER'] ?? '';
  static String get apiNotificationsUserUnread => dotenv.env['API_NOTIFICATIONS_USER_UNREAD'] ?? '';
  static String get apiNotificationsUserRead => dotenv.env['API_NOTIFICATIONS_USER_READ'] ?? '';
  static String get apiNotificationsUserReadAll =>
      dotenv.env['API_NOTIFICATIONS_MARK_ALL_READ'] ?? '';
  static String get apiNotificationsCountUnread =>
      dotenv.env['API_NOTIFICATIONS_COUNT_UNREAD'] ?? '';

  // Dynamic endpoints with parameters
  static String apiNotificationsUserCategory({required String categoryName}) =>
      '${dotenv.env['API_NOTIFICATIONS_USER_CATEGORY']}'.replaceAll('{categoryName}', categoryName);

  static String apiNotificationsUserStatus({required String status}) =>
      '${dotenv.env['API_NOTIFICATIONS_USER_STATUS']}'.replaceAll('{status}', status);

  static String apiNotificationsMarkRead({required String notificationId}) =>
      '${dotenv.env['API_NOTIFICATIONS_MARK_READ']}'.replaceAll('{notificationId}', notificationId);

  static String apiNotificationsCountStatus({required String status}) =>
      '${dotenv.env['API_NOTIFICATIONS_COUNT_STATUS']}'.replaceAll('{status}', status);

  static String apiNotificationsDelete({required String notificationId}) =>
      '${dotenv.env['API_NOTIFICATIONS_DELETE']}'.replaceAll('{notificationId}', notificationId);

  // General endpoints
  static String get apiNotificationsCategories => dotenv.env['API_NOTIFICATIONS_CATEGORIES'] ?? '';
  static String get apiNotificationsHealth => dotenv.env['API_NOTIFICATIONS_HEALTH'] ?? '';

  // Topic management endpoints
  static String get apiNotificationsTopicSubscribe =>
      dotenv.env['API_NOTIFICATIONS_TOPIC_SUBSCRIBE'] ?? '';
  static String get apiNotificationsTopicUnsubscribe =>
      dotenv.env['API_NOTIFICATIONS_TOPIC_UNSUBSCRIBE'] ?? '';
  static String get apiNotificationsValidateToken =>
      dotenv.env['API_NOTIFICATIONS_VALIDATE_TOKEN'] ?? '';
}
