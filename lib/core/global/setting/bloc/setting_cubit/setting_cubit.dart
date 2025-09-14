import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/config/preference_key.dart';
import 'package:news_app/core/service/cache/cache_initialization_service.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/core/service/storage/shared_preference_manager.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/core/theme/dark_theme.dart';
import 'package:news_app/core/theme/light_theme.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/core/service/logger_service.dart';
import 'package:packages/core/utils/app_language_package.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SharedPreferenceManager _prefManager = getIt<SharedPreferenceManager>();

  // Available themes
  final Map<String, AppTheme> _availableThemes = {
    'light': LightTheme(),
    'dark': DarkTheme(),
  };

  // Available languages
  final List<String> _availableLanguages = ['en', 'vi', 'ja'];

  SettingCubit() : super(SettingState.initial()) {
    // Initialize the theme manager with the default theme
    if (!AppThemeManager.isInitialized) {
      AppThemeManager.initialize(_getThemeFromName(PreferenceKey.defaultTheme));
    }

    _loadSettingsFromPrefs();
    _loadCacheInfo();
  }

  // Load all settings from SharedPreferences
  Future<void> _loadSettingsFromPrefs() async {
    try {
      // Load theme setting
      final themeName = _prefManager.getStringWithDefault(
        PreferenceKey.theme,
        PreferenceKey.defaultTheme,
      );
      final theme = _getThemeFromName(themeName);

      // Update the theme manager
      AppThemeManager.updateTheme(theme);

      // Load language setting
      final language = _prefManager.getStringWithDefault(
        PreferenceKey.language,
        PreferenceKey.defaultLanguage,
      );
      AppLanguage.changeLocale(language);
      AppLanguagePackage.updateLocale(language);


      // Load notifications setting
      final notificationsEnabled = _prefManager.getBoolWithDefault(
        PreferenceKey.notificationsEnabled,
        PreferenceKey.defaultNotifications,
      );

      // Load font size setting
      final fontSize = _prefManager.getDoubleWithDefault(
        PreferenceKey.fontSize,
        PreferenceKey.defaultFontSize,
      );

      // Update state with all loaded settings
      emit(
        state.copyWith(
          themeName: themeName,
          theme: theme,
          language: language,
          notificationsEnabled: notificationsEnabled,
          fontSize: fontSize,
        ),
      );
    } catch (e) {
      printE("[SettingCubit] Error loading settings: $e");
      _setDefaultSettings();
    }
  }

  // Load cache information
  Future<void> _loadCacheInfo() async {
    try {
      emit(state.copyWith(isCacheLoading: true));

      final cacheSize =
          await CacheInitializationService.getFormattedCacheSize();
      final isEmpty = await CacheInitializationService.isCacheEmpty();

      emit(
        state.copyWith(
          cacheSize: cacheSize,
          isCacheEmpty: isEmpty,
          isCacheLoading: false,
        ),
      );
    } catch (e) {
      printE("[SettingCubit] Error loading cache info: $e");
      emit(
        state.copyWith(
          cacheSize: '0 B',
          isCacheEmpty: true,
          isCacheLoading: false,
        ),
      );
    }
  }

  // Helper method to get theme object from theme name
  AppTheme _getThemeFromName(String themeName) {
    return _availableThemes[themeName] ?? LightTheme();
  }

  // Set default settings if loading fails
  void _setDefaultSettings() {
    setSystemTheme();
    setLanguage(PreferenceKey.defaultLanguage);
    setNotifications(PreferenceKey.defaultNotifications);
    setFontSize(PreferenceKey.defaultFontSize);
  }

  /// Theme Methods

  // Toggle between light and dark themes
  void toggleTheme() {
    final newThemeName = state.isDarkMode ? 'light' : 'dark';
    setTheme(newThemeName);
  }

  // Set a specific theme by name
  Future<void> setTheme(String themeName) async {
    if (_availableThemes.containsKey(themeName)) {
      final newTheme = _getThemeFromName(themeName);

      // Update the theme manager
      AppThemeManager.updateTheme(newTheme);

      emit(state.copyWith(themeName: themeName, theme: newTheme));
      await _prefManager.saveData(PreferenceKey.theme, themeName);
    }
  }

  // Set theme based on system preference
  Future<void> setSystemTheme() async {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final newThemeName = brightness == Brightness.dark ? 'dark' : 'light';
    await setTheme(newThemeName);
  }

  /// Language Methods

  // Set language
  Future<void> setLanguage(String language) async {
    if (_availableLanguages.contains(language)) {
      AppLanguage.changeLocale(language);
      AppLanguagePackage.updateLocale(language);
      emit(state.copyWith(language: language));
      await _prefManager.saveData(PreferenceKey.language, language);
    }
  }

  // Toggle between available languages
  Future<void> toggleLanguage(String value) async {
    final currentIndex = _availableLanguages.indexOf(value);
    final newLanguage = _availableLanguages[currentIndex];

    await setLanguage(newLanguage);
  }

  /// Notification Methods

  // Toggle notifications on/off
  Future<void> toggleNotifications() async {
    final newValue = !state.notificationsEnabled;
    await setNotifications(newValue);
  }

  // Set notifications enabled/disabled
  Future<void> setNotifications(bool enabled) async {
    emit(state.copyWith(notificationsEnabled: enabled));
    await _prefManager.saveData(PreferenceKey.notificationsEnabled, enabled);
  }

  /// Font Size Methods

  // Set font size
  Future<void> setFontSize(double size) async {
    emit(state.copyWith(fontSize: size));
    await _prefManager.saveData(PreferenceKey.fontSize, size);
  }

  // Increase font size
  Future<void> increaseFontSize() async {
    final newSize = state.fontSize + 1.0;
    await setFontSize(newSize);
  }

  // Decrease font size
  Future<void> decreaseFontSize() async {
    final newSize = state.fontSize - 1.0;
    if (newSize >= 8.0) {
      // Prevent too small font
      await setFontSize(newSize);
    }
  }

  /// Cache Management Methods

  // Refresh cache information
  Future<void> refreshCacheInfo() async {
    await _loadCacheInfo();
  }

  // Clear all cache
  Future<bool> clearAllCache() async {
    try {
      emit(state.copyWith(isCacheClearing: true));

      final success = await CacheInitializationService.clearAllCaches();

      if (success) {
        printI("[SettingCubit] All cache cleared successfully");
        // Refresh cache info after clearing
        await _loadCacheInfo();
      } else {
        printE("[SettingCubit] Failed to clear all cache");
      }

      emit(state.copyWith(isCacheClearing: false));
      return success;
    } catch (e) {
      printE("[SettingCubit] Error clearing all cache: $e");
      emit(state.copyWith(isCacheClearing: false));
      return false;
    }
  }

  // Clear articles cache only
  Future<bool> clearArticlesCache() async {
    try {
      emit(state.copyWith(isCacheClearing: true));

      final success = await CacheInitializationService.clearArticlesCache();

      if (success) {
        printI("[SettingCubit] Articles cache cleared successfully");
        await _loadCacheInfo();
      } else {
        printE("[SettingCubit] Failed to clear articles cache");
      }

      emit(state.copyWith(isCacheClearing: false));
      return success;
    } catch (e) {
      printE("[SettingCubit] Error clearing articles cache: $e");
      emit(state.copyWith(isCacheClearing: false));
      return false;
    }
  }

  // Clear media cache only
  Future<bool> clearMediaCache() async {
    try {
      emit(state.copyWith(isCacheClearing: true));

      final success = await CacheInitializationService.clearMediaCache();

      if (success) {
        printI("[SettingCubit] Media cache cleared successfully");
        await _loadCacheInfo();
      } else {
        printE("[SettingCubit] Failed to clear media cache");
      }

      emit(state.copyWith(isCacheClearing: false));
      return success;
    } catch (e) {
      printE("[SettingCubit] Error clearing media cache: $e");
      emit(state.copyWith(isCacheClearing: false));
      return false;
    }
  }

  // Get detailed cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      return await CacheInitializationService.getCacheStats();
    } catch (e) {
      printE("[SettingCubit] Error getting cache stats: $e");
      return {'error': e.toString()};
    }
  }

  // Get cache health check
  Future<Map<String, dynamic>> getCacheHealthCheck() async {
    try {
      return await CacheInitializationService.getCacheHealthCheck();
    } catch (e) {
      printE("[SettingCubit] Error getting cache health: $e");
      return {'error': e.toString()};
    }
  }

  // Emergency cache reset
  Future<bool> emergencyCacheReset() async {
    try {
      emit(state.copyWith(isCacheClearing: true));

      final success = await CacheInitializationService.emergencyCacheReset();

      if (success) {
        printI("[SettingCubit] Emergency cache reset successful");
        await _loadCacheInfo();
      } else {
        printE("[SettingCubit] Emergency cache reset failed");
      }

      emit(state.copyWith(isCacheClearing: false));
      return success;
    } catch (e) {
      printE("[SettingCubit] Error during emergency cache reset: $e");
      emit(state.copyWith(isCacheClearing: false));
      return false;
    }
  }

  // Cleanup expired cache only
  Future<void> cleanupExpiredCache() async {
    try {
      emit(state.copyWith(isCacheClearing: true));

      await CacheInitializationService.cleanupExpiredCache();
      printI("[SettingCubit] Expired cache cleanup completed");

      await _loadCacheInfo();
      emit(state.copyWith(isCacheClearing: false));
    } catch (e) {
      printE("[SettingCubit] Error during expired cache cleanup: $e");
      emit(state.copyWith(isCacheClearing: false));
    }
  }

  /// Reset all settings to defaults
  Future<void> resetAllSettings() async {
    await setTheme(PreferenceKey.defaultTheme);
    await setLanguage(PreferenceKey.defaultLanguage);
    await setNotifications(PreferenceKey.defaultNotifications);
    await setFontSize(PreferenceKey.defaultFontSize);
  }
}
