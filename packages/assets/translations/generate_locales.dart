import 'dart:convert';
import 'dart:io';

/// Main entry point for the localization generator.
/// This script reads JSON translation files and generates Dart code for
/// localization support in a Flutter application.
void main() {
  // Directory containing JSON translation files
  final translationsDir = 'assets/translations';
  generateLocaleKeys(translationsDir);
}

/// Generates localization keys and translation maps from JSON files.
///
/// This function:
/// 1. Reads all JSON translation files from the specified directory
/// 2. Checks for duplicate keys across nested structures
/// 3. Generates a Dart file with necessary classes for localization
///
/// @param translationsDir Path to the directory containing translation JSON files
void generateLocaleKeys(String translationsDir) {
  try {
    // Get all JSON files in the directory
    final dir = Directory(translationsDir);
    if (!dir.existsSync()) {
      print('Directory $translationsDir does not exist');
      return;
    }

    final jsonFiles =
        dir
            .listSync()
            .where((file) => file is File && file.path.endsWith('.json'))
            .toList();

    if (jsonFiles.isEmpty) {
      print('No JSON files found in $translationsDir');
      return;
    }

    // Read the first file to create keys structure
    final firstFile = jsonFiles.first as File;
    final firstJsonString = firstFile.readAsStringSync();
    final firstJsonData = json.decode(firstJsonString) as Map<String, dynamic>;

    // Create output file
    final outputFile = File('lib/generated/locales.g.dart');
    final outputDirectory = outputFile.parent;
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    // Read all language files
    final localesMap = <String, Map<String, dynamic>>{};

    for (final file in jsonFiles) {
      if (file is File) {
        final localeCode = _getLocaleCodeFromPath(file.path);
        final jsonString = file.readAsStringSync();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        localesMap[localeCode] = jsonData;
      }
    }

    // Check for duplicate keys
    final duplicateKeys = _checkDuplicateKeys(firstJsonData);
    if (duplicateKeys.isNotEmpty) {
      print('WARNING: Duplicate keys found:');
      for (final key in duplicateKeys) {
        print('  - $key');
      }
      print(
        'Please resolve these duplicates to ensure proper translation behavior.',
      );
    }

    // Generate code
    final localeKeysCode = generateLocaleKeysClass(firstJsonData);
    final localesCode = generateLocalesClass(localesMap);
    final appTranslation = generateAppTranslationClass(
      localesMap.keys.toList(),
    );

    // Write file
    outputFile.writeAsStringSync('''
// DO NOT EDIT. This is code generated automatically.
// ignore_for_file: lines_longer_than_80_chars
// ignore: avoid_classes_with_only_static_members

$appTranslation

$localeKeysCode

$localesCode

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
''');

    print('Successfully generated locales.g.dart!');
  } catch (e) {
    print('Error: $e');
  }
}

/// Extracts the locale code from a file path
///
/// @param path The file path
/// @return The locale code (file name without extension)
String _getLocaleCodeFromPath(String path) {
  // Get filename without extension
  final fileName = path.split('/').last.split('.').first;
  return fileName;
}

/// Checks for duplicate translation keys in nested JSON structure
///
/// @param jsonData The JSON data to check
/// @return A list of duplicate key paths found
List<String> _checkDuplicateKeys(Map<String, dynamic> jsonData) {
  final allKeys = <String>{};
  final duplicates = <String>[];

  void checkForDuplicates(Map<String, dynamic> json, String prefix) {
    json.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '${prefix}_$key';

      if (value is Map<String, dynamic>) {
        checkForDuplicates(value, fullKey);
      } else {
        if (allKeys.contains(fullKey)) {
          duplicates.add(fullKey);
        } else {
          allKeys.add(fullKey);
        }
      }
    });
  }

  checkForDuplicates(jsonData, '');
  return duplicates;
}

/// Generates the AppTranslation class code
///
/// @param localeCodes List of locale codes (e.g. ['en', 'fr'])
/// @return Generated Dart code as a string
String generateAppTranslationClass(List<String> localeCodes) {
  final buffer = StringBuffer();
  buffer.writeln('/// Contains translation maps for all supported locales');
  buffer.writeln('class AppTranslation {');
  buffer.write('  static Map<String, Map<String, String>> translations = {');

  for (final locale in localeCodes) {
    buffer.write('\n    \'$locale\': Locales.$locale,');
  }

  buffer.writeln('\n  };');
  buffer.writeln('}');
  return buffer.toString();
}

/// Generates the LocaleKeys class with static constants for all translation keys
///
/// @param jsonData The JSON data structure from the first locale file
/// @return Generated Dart code as a string
String generateLocaleKeysClass(Map<String, dynamic> jsonData) {
  final buffer = StringBuffer();
  buffer.writeln('/// Contains all translation keys as static constants');
  buffer.writeln('/// ');
  buffer.writeln('/// Usage: LocaleKeys.some_key.tr');
  buffer.writeln('class LocaleKeys {');
  buffer.writeln('  LocaleKeys._();');

  // Create list of keys
  final keys = <String>[];
  _extractKeys(jsonData, '', keys);

  // Create static constants
  for (final key in keys) {
    buffer.writeln('  static const $key = \'$key\';');
  }

  buffer.writeln('}');
  return buffer.toString();
}

/// Generates the Locales class with translation maps for each locale
///
/// @param localesMap Map of locale codes to their translation JSON data
/// @return Generated Dart code as a string
String generateLocalesClass(Map<String, Map<String, dynamic>> localesMap) {
  final buffer = StringBuffer();
  buffer.writeln('/// Contains translation maps for each supported locale');
  buffer.writeln('class Locales {');

  // Create map for each language
  for (final entry in localesMap.entries) {
    final locale = entry.key;
    final jsonData = entry.value;

    buffer.writeln('  /// Translations for $locale locale');
    buffer.writeln('  static const $locale = {');

    // Collect all flattened key-values from nested JSON
    final flattenedMap = <String, String>{};
    _flattenJson(jsonData, '', flattenedMap);

    // Write all key-values to buffer
    flattenedMap.forEach((key, value) {
      // Escape single quotes in value
      final escapedValue = value.replaceAll('\'', '\\\'');
      buffer.writeln('    \'$key\': \'$escapedValue\',');
    });

    buffer.writeln('  };');
  }

  buffer.writeln('}');
  return buffer.toString();
}

/// Extracts all translation keys from a nested JSON structure
///
/// @param json The JSON data to extract keys from
/// @param prefix Current key prefix for nested structures
/// @param keys List to populate with found keys
void _extractKeys(Map<String, dynamic> json, String prefix, List<String> keys) {
  json.forEach((key, value) {
    final newKey = prefix.isEmpty ? key : '${prefix}_$key';

    if (value is Map<String, dynamic>) {
      _extractKeys(value, newKey, keys);
    } else {
      // Add key in snake_case format
      keys.add(newKey);
    }
  });
}

/// Flattens a nested JSON structure into a single-level map
///
/// @param json The JSON data to flatten
/// @param prefix Current key prefix for nested structures
/// @param result Map to populate with flattened key-value pairs
void _flattenJson(
  Map<String, dynamic> json,
  String prefix,
  Map<String, String> result,
) {
  json.forEach((key, value) {
    final newKey = prefix.isEmpty ? key : '${prefix}_$key';

    if (value is Map<String, dynamic>) {
      _flattenJson(value, newKey, result);
    } else {
      // Convert value to string if not already a string
      result[newKey] = value.toString();
    }
  });
}
