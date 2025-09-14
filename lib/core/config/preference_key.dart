// preference_keys.dart
/// Centralized place to store all preference keys used in the application
class PreferenceKey {
  // App Settings
  static const String theme = 'app_theme';
  static const String language = 'app_language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fontSize = 'font_size';

  // User related
  static const String userId = 'user_id';
  static const String userToken = 'user_token';
  static const String userEmail = 'user_email';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLoginDate = 'last_login_date';

  // App state
  static const String lastTab = 'last_tab';
  static const String onboardingComplete = 'onboarding_complete';

  // Feature specific
  static const String searchHistory = 'search_history';
  static const String recentItems = 'recent_items';
  static const String favoriteItems = 'favorite_items';

  // Common default values
  static const String defaultTheme = 'light';
  static const String defaultLanguage = 'en';
  static const bool defaultNotifications = true;
  static const double defaultFontSize = 14.0;
}
