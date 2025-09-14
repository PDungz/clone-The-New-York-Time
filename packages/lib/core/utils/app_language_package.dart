import 'package:packages/generated/locales.g.dart';

class AppLanguagePackage {
  static final AppLanguagePackage _instance = AppLanguagePackage._internal();
  factory AppLanguagePackage() => _instance;
  AppLanguagePackage._internal();

  // Current locale for the package
  static String _currentLocale = 'en'; // Default locale

  /// Get current locale
  static String get currentLocale => _currentLocale;

  /// Update locale for the entire package
  /// Call this from your app's language settings
  static void updateLocale(String locale) {
    if (['en', 'vi', 'ja'].contains(locale)) {
      _currentLocale = locale;
      // Also update the main AppLanguage
      AppLanguage.changeLocale(locale);
    }
  }

  /// Get translation using current package locale
  static String tr(String key, {List<String>? args}) {
    return AppLanguage.get(key, args: args);
  }

  /// Get default field name using current package locale
  static String getDefaultFieldName(String key) {
    switch (key) {
      case 'field':
        return tr(LocaleKeys.validator_default_field);
      case 'name':
        return tr(LocaleKeys.validator_default_name);
      case 'number':
        return tr(LocaleKeys.validator_default_number);
      default:
        return key;
    }
  }

  /// Initialize package with locale
  static void initialize({String locale = 'en'}) {
    updateLocale(locale);
  }

  /// Get supported locales
  static List<String> get supportedLocales => ['en', 'vi', 'ja'];

  /// Check if locale is supported
  static bool isLocaleSupported(String locale) {
    return supportedLocales.contains(locale);
  }
}
