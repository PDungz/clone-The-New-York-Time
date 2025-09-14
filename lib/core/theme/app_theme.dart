import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_dimension.dart';

/// Abstract base class defining the full design system of the application.
///
/// This class serves as a centralized contract for managing colors, text styles,
/// component dimensions, animations, and Flutter's ThemeData mapping.
/// Implement this class to provide concrete design tokens for your app.
abstract class AppTheme {
  /// Unique name of the theme, used for selection or debugging.
  String get themeName;

  /// Theme brightness, e.g., [Brightness.light] or [Brightness.dark].
  Brightness get brightness;

  // ===== BRACKGROUND =====
  String get backgroundSplash;

  // ===== COLORS =====

  // ===== Brand Colors =====
  Color get nytBlue; // NYT signature blue for links/buttons
  Color get nytSerif; // Nearly black for headlines
  Color get nytAccent; // Subtle accent for UI elements
  Color get nytWhite;

  // ===== Common Colors =====
  Color get redAccent; // NYT-style alert red
  Color get success; // Muted success green
  Color get warning; // Muted warning amber
  Color get info; // Same as NYT blue
  Color get error; // Error/destructive actions

  // ===== Special Elements =====
  Color get premium; // Gold color for premium/subscription content
  Color get highlight; // Text highlight color (light theme)

  Color get linkVisited; // Visited links
  Color get specialSection; // Special news sections
  Color get breakingNews; // Breaking news indicator

  // ===== Tags and Categories =====
  Color get politics; // Politics tag
  Color get business; // Business tag
  Color get technology; // Technology tag
  Color get science; // Science tag
  Color get arts; // Arts & Culture tag
  Color get opinion; // Opinion tag
  Color get sports; // Sports tag

  // ===== Theme Colors =====
  Color get primary; // Not pure black, dark charcoal
  Color get primaryLight; // Mid-tone gray
  Color get primaryDark; // Very dark gray but not black
  Color get secondary; // Muted bluish-gray
  Color get background; // Off-white background
  Color get scaffold; // Slightly more off-white
  Color get card; // White for cards
  Color get dialog; // White for dialogs
  Color get bottomSheet; // Bottom sheet background
  Color get snackbar; // Snackbar background
  Color get appBar; // App bar background
  Color get textPrimary; // Dark gray for primary text
  Color get textSecondary; // Medium gray for secondary text
  Color get textDisabled; // Light gray for disabled text
  Color get divider; // Light gray divider
  Color get border; // Very light gray border
  Color get icon; // Icon color
  Color get unsetIcon; // Icon color
  Color get shadow; // Light shadow
  Color get overlay; // Overlay color
  Color get dim; // Dim effect for modals
  Color get printStyle; // Print-like text
  Color get printBackground; // Newspaper texture background

  // ===== Gradients =====
  List<Color> get premiumGradient; // Premium content gradient
  List<Color> get fadeGradient; // Content fade gradient (light)
  List<Color> get darkFadeGradient; // Content fade gradient (dark)
  List<Color> get featuredGradient; // Featured content

  // ===== Reading Modes =====
  Color get sepia; // Sepia reading background
  Color get sepiaText; // Sepia reading text
  Color get nightMode; // Night reading background
  Color get nightModeText; // Night reading text
  Color get printMode; // Print reading background
  Color get printModeText; // Print reading text

  // ===== Interactive Elements =====
  Color get buttonPrimary; // Primary button background
  Color get buttonPrimaryText; // Primary button text
  Color get buttonSecondary; // Secondary button background
  Color get buttonSecondaryText; // Secondary button text
  Color get selectionActive; // Active selection

  // ===== Interactive States =====
  Color get ripple; // Ripple effect dark theme
  Color get hover; // Hover state light theme
  Color get focus; // Focus state light theme

  // ===== TYPOGRAPHY =====

  /// Font family for display text.
  String get fontFamilyDisplay;

  /// Font family for headline text.
  String get fontFamilyHeadline;

  /// Font family for title text.
  String get fontFamilyTitle;

  /// Font family for body text.
  String get fontFamilyBody;

  /// Font family for label text.
  String get fontFamilyLabel;

  /// Font family for display text ElevatedButton.
  String get fontFamilyElevatedButton;

  /// Font weight for light text.
  FontWeight get lightFontWeight;

  /// Font weight for regular text.
  FontWeight get regularFontWeight;

  /// Font weight for medium text.
  FontWeight get mediumFontWeight;

  /// Font weight for semi-bold text.
  FontWeight get semiBoldFontWeight;

  /// Font weight for bold text.
  FontWeight get boldFontWeight;

  /// Text style for displayLarge.
  TextStyle get displayLarge;

  /// Text style for displayMedium.
  TextStyle get displayMedium;

  /// Text style for displaySmall.
  TextStyle get displaySmall;

  /// Text style for headlineLarge.
  TextStyle get headlineLarge;

  /// Text style for headlineMedium.
  TextStyle get headlineMedium;

  /// Text style for headlineSmall.
  TextStyle get headlineSmall;

  /// Text style for titleLarge.
  TextStyle get titleLarge;

  /// Text style for titleMedium.
  TextStyle get titleMedium;

  /// Text style for titleSmall.
  TextStyle get titleSmall;

  /// Text style for bodyLarge.
  TextStyle get bodyLarge;

  /// Text style for bodyMedium.
  TextStyle get bodyMedium;

  /// Text style for bodySmall.
  TextStyle get bodySmall;

  /// Text style for labelLarge.
  TextStyle get labelLarge;

  /// Text style for labelMedium.
  TextStyle get labelMedium;

  /// Text style for labelSmall.
  TextStyle get labelSmall;

  /// Generates a [ThemeData] object from the current theme tokens.
  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      fontFamily: fontFamilyBody,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffold,
      cardColor: card,
      dividerColor: divider,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: ColorScheme(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: secondary,
        secondaryContainer: secondary.withValues(
          alpha: (0.8 * 255).roundToDouble(),
        ),
        surface: card,
        error: error,
        onPrimary: buttonPrimaryText,
        onSecondary: buttonPrimaryText,
        onSurface: textPrimary,
        onError: buttonPrimaryText,
        brightness: brightness,
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
      typography: Typography.material2021(),
      appBarTheme: AppBarTheme(
        color: appBar,
        elevation: AppDimensions.elevation4,
        shadowColor: shadow,
        iconTheme: IconThemeData(color: icon),
        titleTextStyle: titleLarge.copyWith(color: textPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: buttonPrimary,
        foregroundColor: buttonPrimaryText,
        elevation: AppDimensions.elevation8,
        splashColor: ripple,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackbar,
        contentTextStyle: bodyMedium.copyWith(color: buttonPrimaryText),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomSheet,
        selectedItemColor: nytBlue,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: labelMedium,
        unselectedLabelStyle: labelSmall,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: nytSerif,
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
        ),
        textStyle: labelSmall.copyWith(color: buttonPrimaryText),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
        ),
        textStyle: bodyMedium,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: nytBlue,
        inactiveTrackColor: nytBlue.withValues(
          alpha: (0.3 * 255).roundToDouble(),
        ),
        thumbColor: nytBlue,
        overlayColor: nytBlue.withValues(alpha: (0.2 * 255).roundToDouble()),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return textDisabled;
          }
          return nytBlue;
        }),
        checkColor: WidgetStateProperty.all(buttonPrimaryText),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return textDisabled;
          }
          return nytBlue;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return textDisabled;
          } else if (states.contains(WidgetState.selected)) {
            return nytBlue;
          }
          return buttonSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return textDisabled.withValues(alpha: (0.5 * 255).roundToDouble());
          } else if (states.contains(WidgetState.selected)) {
            return nytBlue.withValues(alpha: (0.5 * 255).roundToDouble());
          }
          return textSecondary.withValues(alpha: (0.3 * 255).roundToDouble());
        }),
      ),
      iconTheme: IconThemeData(color: icon, size: AppDimensions.icon24),
      dialogTheme: DialogTheme(
        backgroundColor: dialog,
        elevation: AppDimensions.elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return textDisabled;
            }
            return buttonPrimary;
          }),
          foregroundColor: WidgetStateProperty.all(buttonPrimaryText),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppDimensions.inset16,
              vertical: AppDimensions.inset12,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return hover;
            } else if (states.contains(WidgetState.focused)) {
              return focus;
            } else if (states.contains(WidgetState.pressed)) {
              return ripple;
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return textDisabled;
            }
            return nytBlue;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: textDisabled);
            }
            return BorderSide(color: border);
          }),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppDimensions.inset16,
              vertical: AppDimensions.inset12,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return hover;
            } else if (states.contains(WidgetState.focused)) {
              return focus;
            } else if (states.contains(WidgetState.pressed)) {
              return ripple;
            }
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return textDisabled;
            }
            return nytBlue;
          }),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppDimensions.inset16,
              vertical: AppDimensions.inset12,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius8),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return hover;
            } else if (states.contains(WidgetState.focused)) {
              return focus;
            } else if (states.contains(WidgetState.pressed)) {
              return ripple;
            }
            return null;
          }),
        ),
      ),
      cardTheme: CardTheme(
        elevation: AppDimensions.elevation4,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius12),
        ),
        margin: EdgeInsets.zero,
        color: card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hoverColor: hover,
        focusColor: focus,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: nytBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: textDisabled),
        ),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
        hintStyle: bodyMedium.copyWith(color: textDisabled),
        errorStyle: bodySmall.copyWith(color: error),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.inset16,
          vertical: AppDimensions.inset12,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bottomSheet,
        modalBackgroundColor: bottomSheet,
        elevation: AppDimensions.elevation16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radius16),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: card,
        textColor: textPrimary,
        iconColor: icon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.inset16,
          vertical: AppDimensions.inset8,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: AppDimensions.inset8,
      ),
    );
  }
}
