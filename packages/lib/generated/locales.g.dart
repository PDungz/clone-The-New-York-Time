// DO NOT EDIT. This is code generated automatically.
// ignore_for_file: lines_longer_than_80_chars
// ignore: avoid_classes_with_only_static_members

/// Contains translation maps for all supported locales
class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'ja': Locales.ja,
    'en': Locales.en,
    'vi': Locales.vi,
  };
}


/// Contains all translation keys as static constants
/// 
/// Usage: LocaleKeys.some_key.tr
class LocaleKeys {
  LocaleKeys._();
  static const format_date_time_ago_second = 'format_date_time_ago_second';
  static const format_date_time_ago_minute = 'format_date_time_ago_minute';
  static const format_date_time_ago_hour = 'format_date_time_ago_hour';
  static const format_date_time_ago_day = 'format_date_time_ago_day';
  static const format_date_time_ago_month = 'format_date_time_ago_month';
  static const format_date_time_ago_year = 'format_date_time_ago_year';
  static const format_date_time_ago_short_second = 'format_date_time_ago_short_second';
  static const format_date_time_ago_short_minute = 'format_date_time_ago_short_minute';
  static const format_date_time_ago_short_hour = 'format_date_time_ago_short_hour';
  static const format_date_time_ago_short_day = 'format_date_time_ago_short_day';
  static const format_date_time_ago_short_month = 'format_date_time_ago_short_month';
  static const format_date_time_ago_short_year = 'format_date_time_ago_short_year';
  static const format_date_now = 'format_date_now';
  static const validator_email_required = 'validator_email_required';
  static const validator_email_invalid = 'validator_email_invalid';
  static const validator_password_required = 'validator_password_required';
  static const validator_password_min_length = 'validator_password_min_length';
  static const validator_password_uppercase = 'validator_password_uppercase';
  static const validator_password_lowercase = 'validator_password_lowercase';
  static const validator_password_number = 'validator_password_number';
  static const validator_password_special = 'validator_password_special';
  static const validator_phone_required = 'validator_phone_required';
  static const validator_phone_invalid = 'validator_phone_invalid';
  static const validator_field_required = 'validator_field_required';
  static const validator_field_min_length = 'validator_field_min_length';
  static const validator_field_max_length = 'validator_field_max_length';
  static const validator_number_required = 'validator_number_required';
  static const validator_number_invalid = 'validator_number_invalid';
  static const validator_number_positive = 'validator_number_positive';
  static const validator_age_required = 'validator_age_required';
  static const validator_age_invalid = 'validator_age_invalid';
  static const validator_age_range = 'validator_age_range';
  static const validator_url_required = 'validator_url_required';
  static const validator_url_invalid = 'validator_url_invalid';
  static const validator_confirm_password_required = 'validator_confirm_password_required';
  static const validator_confirm_password_mismatch = 'validator_confirm_password_mismatch';
  static const validator_name_required = 'validator_name_required';
  static const validator_name_invalid = 'validator_name_invalid';
  static const validator_date_required = 'validator_date_required';
  static const validator_date_format_invalid = 'validator_date_format_invalid';
  static const validator_date_invalid = 'validator_date_invalid';
  static const validator_default_field = 'validator_default_field';
  static const validator_default_name = 'validator_default_name';
  static const validator_default_number = 'validator_default_number';
}


/// Contains translation maps for each supported locale
class Locales {
  /// Translations for ja locale
  static const ja = {
    'format_date_time_ago_second': '%s秒前',
    'format_date_time_ago_minute': '%s分前',
    'format_date_time_ago_hour': '%s時間前',
    'format_date_time_ago_day': '%s日前',
    'format_date_time_ago_month': '%sヶ月前',
    'format_date_time_ago_year': '%s年前',
    'format_date_time_ago_short_second': '%s秒前',
    'format_date_time_ago_short_minute': '%s分前',
    'format_date_time_ago_short_hour': '%s時前',
    'format_date_time_ago_short_day': '%s日前',
    'format_date_time_ago_short_month': '%sヶ月前',
    'format_date_time_ago_short_year': '%s年前',
    'format_date_now': '今',
    'validator_email_required': 'メールアドレスは必須です',
    'validator_email_invalid': 'メールアドレスの形式が無効です',
    'validator_password_required': 'パスワードは必須です',
    'validator_password_min_length': 'パスワードは%s文字以上である必要があります',
    'validator_password_uppercase': 'パスワードには大文字を1つ以上含める必要があります',
    'validator_password_lowercase': 'パスワードには小文字を1つ以上含める必要があります',
    'validator_password_number': 'パスワードには数字を1つ以上含める必要があります',
    'validator_password_special': 'パスワードには特殊文字を1つ以上含める必要があります',
    'validator_phone_required': '電話番号は必須です',
    'validator_phone_invalid': '電話番号が無効です',
    'validator_field_required': '%sは必須です',
    'validator_field_min_length': '%sは%s文字以上である必要があります',
    'validator_field_max_length': '%sは%s文字以下である必要があります',
    'validator_number_required': '%sは必須です',
    'validator_number_invalid': '%sは有効な数字である必要があります',
    'validator_number_positive': '%sは正の数である必要があります',
    'validator_age_required': '年齢は必須です',
    'validator_age_invalid': '年齢は有効な整数である必要があります',
    'validator_age_range': '年齢は0から150の間である必要があります',
    'validator_url_required': 'URLは必須です',
    'validator_url_invalid': 'URLの形式が無効です',
    'validator_confirm_password_required': 'パスワードの確認は必須です',
    'validator_confirm_password_mismatch': 'パスワードが一致しません',
    'validator_name_required': '%sは必須です',
    'validator_name_invalid': '%sは文字とスペースのみ含むことができます',
    'validator_date_required': '日付は必須です',
    'validator_date_format_invalid': '日付の形式が無効です (dd/mm/yyyy)',
    'validator_date_invalid': '無効な日付です',
    'validator_default_field': 'この項目',
    'validator_default_name': '名前',
    'validator_default_number': '数値',
  };
  /// Translations for en locale
  static const en = {
    'format_date_time_ago_second': '%s seconds ago',
    'format_date_time_ago_minute': '%s minutes ago',
    'format_date_time_ago_hour': '%s hours ago',
    'format_date_time_ago_day': '%s days ago',
    'format_date_time_ago_month': '%s months ago',
    'format_date_time_ago_year': '%s years ago',
    'format_date_time_ago_short_second': '%ss ago',
    'format_date_time_ago_short_minute': '%sm ago',
    'format_date_time_ago_short_hour': '%sh ago',
    'format_date_time_ago_short_day': '%sd ago',
    'format_date_time_ago_short_month': '%smo ago',
    'format_date_time_ago_short_year': '%sy ago',
    'format_date_now': 'now',
    'validator_email_required': 'Email is required',
    'validator_email_invalid': 'Invalid email format',
    'validator_password_required': 'Password is required',
    'validator_password_min_length': 'Password must be at least %s characters',
    'validator_password_uppercase': 'Password must contain at least 1 uppercase letter',
    'validator_password_lowercase': 'Password must contain at least 1 lowercase letter',
    'validator_password_number': 'Password must contain at least 1 number',
    'validator_password_special': 'Password must contain at least 1 special character',
    'validator_phone_required': 'Phone number is required',
    'validator_phone_invalid': 'Invalid phone number',
    'validator_field_required': '%s is required',
    'validator_field_min_length': '%s must be at least %s characters',
    'validator_field_max_length': '%s must not exceed %s characters',
    'validator_number_required': '%s is required',
    'validator_number_invalid': '%s must be a valid number',
    'validator_number_positive': '%s must be a positive number',
    'validator_age_required': 'Age is required',
    'validator_age_invalid': 'Age must be a valid integer',
    'validator_age_range': 'Age must be between 0 and 150',
    'validator_url_required': 'URL is required',
    'validator_url_invalid': 'Invalid URL format',
    'validator_confirm_password_required': 'Confirm password is required',
    'validator_confirm_password_mismatch': 'Passwords do not match',
    'validator_name_required': '%s is required',
    'validator_name_invalid': '%s can only contain letters and spaces',
    'validator_date_required': 'Date is required',
    'validator_date_format_invalid': 'Invalid date format (dd/mm/yyyy)',
    'validator_date_invalid': 'Invalid date',
    'validator_default_field': 'This field',
    'validator_default_name': 'Name',
    'validator_default_number': 'Number',
  };
  /// Translations for vi locale
  static const vi = {
    'format_date_time_ago_second': '%s giây trước',
    'format_date_time_ago_minute': '%s phút trước',
    'format_date_time_ago_hour': '%s giờ trước',
    'format_date_time_ago_day': '%s ngày trước',
    'format_date_time_ago_month': '%s tháng trước',
    'format_date_time_ago_year': '%s năm trước',
    'format_date_time_ago_short_second': '%sg trước',
    'format_date_time_ago_short_minute': '%sp trước',
    'format_date_time_ago_short_hour': '%sh trước',
    'format_date_time_ago_short_day': '%sd trước',
    'format_date_time_ago_short_month': '%sth trước',
    'format_date_time_ago_short_year': '%sy trước',
    'format_date_now': 'bây giờ',
    'validator_email_required': 'Email không được để trống',
    'validator_email_invalid': 'Email không hợp lệ',
    'validator_password_required': 'Mật khẩu không được để trống',
    'validator_password_min_length': 'Mật khẩu phải có ít nhất %s ký tự',
    'validator_password_uppercase': 'Mật khẩu phải có ít nhất 1 chữ hoa',
    'validator_password_lowercase': 'Mật khẩu phải có ít nhất 1 chữ thường',
    'validator_password_number': 'Mật khẩu phải có ít nhất 1 số',
    'validator_password_special': 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt',
    'validator_phone_required': 'Số điện thoại không được để trống',
    'validator_phone_invalid': 'Số điện thoại không hợp lệ',
    'validator_field_required': '%s không được để trống',
    'validator_field_min_length': '%s phải có ít nhất %s ký tự',
    'validator_field_max_length': '%s không được vượt quá %s ký tự',
    'validator_number_required': '%s không được để trống',
    'validator_number_invalid': '%s phải là một số hợp lệ',
    'validator_number_positive': '%s phải là số dương',
    'validator_age_required': 'Tuổi không được để trống',
    'validator_age_invalid': 'Tuổi phải là một số nguyên',
    'validator_age_range': 'Tuổi phải từ 0 đến 150',
    'validator_url_required': 'URL không được để trống',
    'validator_url_invalid': 'URL không hợp lệ',
    'validator_confirm_password_required': 'Xác nhận mật khẩu không được để trống',
    'validator_confirm_password_mismatch': 'Mật khẩu xác nhận không khớp',
    'validator_name_required': '%s không được để trống',
    'validator_name_invalid': '%s chỉ được chứa chữ cái và khoảng trắng',
    'validator_date_required': 'Ngày không được để trống',
    'validator_date_format_invalid': 'Định dạng ngày không hợp lệ (dd/mm/yyyy)',
    'validator_date_invalid': 'Ngày không hợp lệ',
    'validator_default_field': 'Trường này',
    'validator_default_name': 'Tên',
    'validator_default_number': 'Số',
  };
}


/// Main class for handling application language and translations.
/// 
/// This class provides methods to change the current locale and retrieve
/// translated strings based on keys.
class AppLanguage {
  static final _instance = AppLanguage._internal();
  factory AppLanguage() => _instance;
  AppLanguage._internal();
  
  /// Gets the current locale code (e.g. 'en', 'fr')
  static String get currentLocale => _locale;
  static String _locale = 'en';
  
  /// Changes the application's current locale
  /// 
  /// @param locale The locale code to switch to (e.g. 'en', 'fr')
  static void changeLocale(String locale) {
    if (AppTranslation.translations.containsKey(locale)) {
      _locale = locale;
    }
  }
  
  /// Retrieves a translated string for the given key
  /// 
  /// @param key The translation key to look up
  /// @param args Optional list of arguments to replace '%s' placeholders in the translated string
  /// @return The translated string, or the key itself if no translation is found
  static String get(String key, {List<String>? args}) {
    String value = AppTranslation.translations[_locale]?[key] ?? key;
    
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        value = value.replaceFirst('%s', args[i]);
      }
    }
    
    return value;
  }
}

/// Extension on String for easy translation access
/// 
/// Usage:
/// ```dart
/// Text(LocaleKeys.welcome.tr)
/// // or with parameters:
/// Text(LocaleKeys.hello_name.trArgs(['John']))
/// ```
extension LocaleKeysExtension on String {
  /// Get the translation for this key
  String get tr => AppLanguage.get(this);
  
  /// Get the translation with argument substitution
  String trArgs(List<String> args) => AppLanguage.get(this, args: args);
}
