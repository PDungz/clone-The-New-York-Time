import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_theme.dart';

/// A singleton manager that provides global access to the current theme
class AppThemeManager {
  // Private constructor to prevent instantiation
  AppThemeManager._();

  // The current theme instance
  static late AppTheme _currentTheme;

  // Whether theme has been initialized
  static bool _initialized = false;

  /// Initialize with a theme
  static void initialize(AppTheme theme) {
    _currentTheme = theme;
    _initialized = true;
  }

  /// Update the current theme
  static void updateTheme(AppTheme theme) {
    _currentTheme = theme;
    _initialized = true;
  }

  /// Check if theme manager is initialized
  static bool get isInitialized => _initialized;

  /// Access the current theme
  static AppTheme get theme {
    assert(_initialized, 'AppThemeManager must be initialized before use');
    return _currentTheme;
  }

    
  static String get backgroundSplash => theme.backgroundSplash;

  // ===== COLORS =====

  // Brand Colors
  static Color get nytBlue => theme.nytBlue;
  static Color get nytSerif => theme.nytSerif;
  static Color get nytAccent => theme.nytAccent;
  static Color get nytWhite => theme.nytWhite;

  // Common Colors
  static Color get redAccent => theme.redAccent;
  static Color get success => theme.success;
  static Color get warning => theme.warning;
  static Color get info => theme.info;
  static Color get error => theme.error;

  // Special Elements
  static Color get premium => theme.premium;
  static Color get highlight => theme.highlight;
  static Color get linkVisited => theme.linkVisited;
  static Color get specialSection => theme.specialSection;
  static Color get breakingNews => theme.breakingNews;

  // Tags and Categories
  static Color get politics => theme.politics;
  static Color get business => theme.business;
  static Color get technology => theme.technology;
  static Color get science => theme.science;
  static Color get arts => theme.arts;
  static Color get opinion => theme.opinion;
  static Color get sports => theme.sports;

  // Theme Colors
  static Color get primary => theme.primary;
  static Color get primaryLight => theme.primaryLight;
  static Color get primaryDark => theme.primaryDark;
  static Color get secondary => theme.secondary;
  static Color get background => theme.background;
  static Color get scaffold => theme.scaffold;
  static Color get card => theme.card;
  static Color get dialog => theme.dialog;
  static Color get bottomSheet => theme.bottomSheet;
  static Color get snackbar => theme.snackbar;
  static Color get appBar => theme.appBar;
  static Color get textPrimary => theme.textPrimary;
  static Color get textSecondary => theme.textSecondary;
  static Color get textDisabled => theme.textDisabled;
  static Color get divider => theme.divider;
  static Color get border => theme.border;
  static Color get icon => theme.icon;
  static Color get unsetIcon => theme.unsetIcon;
  static Color get shadow => theme.shadow;
  static Color get overlay => theme.overlay;
  static Color get dim => theme.dim;
  static Color get printStyle => theme.printStyle;
  static Color get printBackground => theme.printBackground;

  // Gradients
  static List<Color> get premiumGradient => theme.premiumGradient;
  static List<Color> get fadeGradient => theme.fadeGradient;
  static List<Color> get darkFadeGradient => theme.darkFadeGradient;
  static List<Color> get featuredGradient => theme.featuredGradient;

  // Reading Modes
  static Color get sepia => theme.sepia;
  static Color get sepiaText => theme.sepiaText;
  static Color get nightMode => theme.nightMode;
  static Color get nightModeText => theme.nightModeText;
  static Color get printMode => theme.printMode;
  static Color get printModeText => theme.printModeText;

  // Interactive Elements
  static Color get buttonPrimary => theme.buttonPrimary;
  static Color get buttonPrimaryText => theme.buttonPrimaryText;
  static Color get buttonSecondary => theme.buttonSecondary;
  static Color get buttonSecondaryText => theme.buttonSecondaryText;
  static Color get selectionActive => theme.selectionActive;

  // Interactive States
  static Color get ripple => theme.ripple;
  static Color get hover => theme.hover;
  static Color get focus => theme.focus;

  // ===== TYPOGRAPHY =====

  // Font Families
  static String get fontFamilyDisplay => theme.fontFamilyDisplay;
  static String get fontFamilyHeadline => theme.fontFamilyHeadline;
  static String get fontFamilyTitle => theme.fontFamilyTitle;
  static String get fontFamilyBody => theme.fontFamilyBody;
  static String get fontFamilyLabel => theme.fontFamilyLabel;

  // Font Weights
  static FontWeight get lightFontWeight => theme.lightFontWeight;
  static FontWeight get regularFontWeight => theme.regularFontWeight;
  static FontWeight get mediumFontWeight => theme.mediumFontWeight;
  static FontWeight get semiBoldFontWeight => theme.semiBoldFontWeight;
  static FontWeight get boldFontWeight => theme.boldFontWeight;

  // Text Styles
  static TextStyle get displayLarge => theme.displayLarge;
  static TextStyle get displayMedium => theme.displayMedium;
  static TextStyle get displaySmall => theme.displaySmall;
  static TextStyle get headlineLarge => theme.headlineLarge;
  static TextStyle get headlineMedium => theme.headlineMedium;
  static TextStyle get headlineSmall => theme.headlineSmall;
  static TextStyle get titleLarge => theme.titleLarge;
  static TextStyle get titleMedium => theme.titleMedium;
  static TextStyle get titleSmall => theme.titleSmall;
  static TextStyle get bodyLarge => theme.bodyLarge;
  static TextStyle get bodyMedium => theme.bodyMedium;
  static TextStyle get bodySmall => theme.bodySmall;
  static TextStyle get labelLarge => theme.labelLarge;
  static TextStyle get labelMedium => theme.labelMedium;
  static TextStyle get labelSmall => theme.labelSmall;

  // ===== THEME DATA =====

  /// Get theme name
  static String get themeName => theme.themeName;

  /// Get theme brightness
  static Brightness get brightness => theme.brightness;

  /// Get the MaterialThemeData for this theme
  static ThemeData get themeData => theme.toThemeData();
}
