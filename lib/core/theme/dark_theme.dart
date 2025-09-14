import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/app_nyt_color.dart';
import 'package:news_app/core/theme/base_theme.dart';
import 'package:news_app/gen/assets.gen.dart';

class DarkTheme extends BaseTheme {
  @override
  String get themeName => 'Dark Theme';

  @override
  Brightness get brightness => Brightness.dark;

  // ===== BRACKGROUND =====
  @override
  String get backgroundSplash =>
      $AssetsImagesBackgroundGen().backgroundLoginTwo.path;

  // ===== COLORS =====
  // ===== Brand Colors =====
  @override
  Color get nytBlue => AppNYTColors.nytBlue;

  @override
  Color get nytSerif => AppNYTColors.nytSerif;

  @override
  Color get nytAccent => AppNYTColors.nytAccent;

  // ===== Common Colors =====
  @override
  Color get redAccent => AppNYTColors.redAccent;

  @override
  Color get success => AppNYTColors.success;

  @override
  Color get warning => AppNYTColors.warning;

  @override
  Color get info => AppNYTColors.info;

  @override
  Color get error => AppNYTColors.error;

  // ===== Special Elements =====
  @override
  Color get premium => AppNYTColors.premium;

  @override
  Color get highlight => AppNYTColors.darkHighlight; // Use dark highlight

  @override
  Color get linkVisited => AppNYTColors.linkVisited;

  @override
  Color get specialSection => AppNYTColors.specialSection;

  @override
  Color get breakingNews => AppNYTColors.breakingNews;

  // ===== Tags and Categories =====
  @override
  Color get politics => AppNYTColors.politics;

  @override
  Color get business => AppNYTColors.business;

  @override
  Color get technology => AppNYTColors.technology;

  @override
  Color get science => AppNYTColors.science;

  @override
  Color get arts => AppNYTColors.arts;

  @override
  Color get opinion => AppNYTColors.opinion;

  @override
  Color get sports => AppNYTColors.sports;

  // ===== Theme Colors =====
  @override
  Color get primary => AppNYTColors.darkPrimary;

  @override
  Color get primaryLight => AppNYTColors.darkPrimaryLight;

  @override
  Color get primaryDark => AppNYTColors.darkPrimaryDark;

  @override
  Color get secondary => AppNYTColors.darkSecondary;

  @override
  Color get background => AppNYTColors.darkBackground;

  @override
  Color get scaffold => AppNYTColors.darkScaffold;

  @override
  Color get card => AppNYTColors.darkCard;

  @override
  Color get dialog => AppNYTColors.darkDialog;

  @override
  Color get bottomSheet => AppNYTColors.darkBottomSheet;

  @override
  Color get snackbar => AppNYTColors.darkSnackbar;

  @override
  Color get appBar => AppNYTColors.darkAppBar;

  @override
  Color get textPrimary => AppNYTColors.darkTextPrimary;

  @override
  Color get textSecondary => AppNYTColors.darkTextSecondary;

  @override
  Color get textDisabled => AppNYTColors.darkTextDisabled;

  @override
  Color get divider => AppNYTColors.darkDivider;

  @override
  Color get border => AppNYTColors.darkBorder;

  @override
  Color get icon => AppNYTColors.darkIcon;

  @override
  Color get unsetIcon => AppNYTColors.darkUnsetIcon;

  @override
  Color get shadow => AppNYTColors.darkShadow;

  @override
  Color get overlay => AppNYTColors.darkOverlay;

  @override
  Color get dim => AppNYTColors.darkDim;

  @override
  Color get printStyle => AppNYTColors.darkPrintStyle;

  @override
  Color get printBackground => AppNYTColors.darkPrintBackground;

  // ===== Gradients =====
  @override
  List<Color> get premiumGradient => AppNYTColors.premiumGradient;

  @override
  List<Color> get fadeGradient => AppNYTColors.darkFadeGradient; // Use dark fade gradient

  @override
  List<Color> get darkFadeGradient => AppNYTColors.darkFadeGradient;

  @override
  List<Color> get featuredGradient => AppNYTColors.featuredGradient;

  // ===== Reading Modes =====
  @override
  Color get sepia => AppNYTColors.sepia;

  @override
  Color get sepiaText => AppNYTColors.sepiaText;

  @override
  Color get nightMode => AppNYTColors.nightMode;

  @override
  Color get nightModeText => AppNYTColors.nightModeText;

  @override
  Color get printMode => AppNYTColors.printMode;

  @override
  Color get printModeText => AppNYTColors.printModeText;

  // ===== Interactive Elements - DARK THEME SPECIFIC =====
  @override
  Color get buttonPrimary => AppNYTColors.darkButtonPrimary; // Light button for dark theme

  @override
  Color get buttonPrimaryText => AppNYTColors.darkButtonPrimaryText; // Dark text

  @override
  Color get buttonSecondary => AppNYTColors.darkButtonSecondary; // Dark button

  @override
  Color get buttonSecondaryText => AppNYTColors.darkButtonSecondaryText; // Light text

  @override
  Color get selectionActive => AppNYTColors.darkSelectionActive;

  // ===== Interactive States - DARK THEME SPECIFIC =====
  @override
  Color get ripple => AppNYTColors.darkRipple;

  @override
  Color get hover => AppNYTColors.darkHover;

  @override
  Color get focus => AppNYTColors.darkFocus;

  // ===== TYPOGRAPHY =====
  @override
  String get fontFamilyDisplay => 'Merriweather';
  @override
  String get fontFamilyHeadline => 'Merriweather';
  @override
  String get fontFamilyTitle => 'Merriweather';
  @override
  String get fontFamilyBody => 'Merriweather';
  @override
  String get fontFamilyLabel => 'Merriweather';

  /// Font family for display text ElevatedButton.
  @override
  String get fontFamilyElevatedButton => "Roboto";

  @override
  FontWeight get lightFontWeight => FontWeight.w300;

  @override
  FontWeight get regularFontWeight => FontWeight.w400;

  @override
  FontWeight get mediumFontWeight => FontWeight.w500;

  @override
  FontWeight get semiBoldFontWeight => FontWeight.w600;

  @override
  FontWeight get boldFontWeight => FontWeight.w700;

  // ===== TEXT STYLES =====

  @override
  TextStyle get displayLarge => TextStyle(
    fontSize: AppDimensions.font56,
    fontWeight: boldFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get displayMedium => TextStyle(
    fontSize: AppDimensions.font42,
    fontWeight: boldFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get displaySmall => TextStyle(
    fontSize: AppDimensions.font36,
    fontWeight: boldFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get headlineLarge => TextStyle(
    fontSize: AppDimensions.font32,
    fontWeight: boldFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get headlineMedium => TextStyle(
    fontSize: AppDimensions.font28,
    fontWeight: boldFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get headlineSmall => TextStyle(
    fontSize: AppDimensions.font24,
    fontWeight: mediumFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get titleLarge => TextStyle(
    fontSize: AppDimensions.font22,
    fontWeight: mediumFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_5,
  );

  @override
  TextStyle get titleMedium => TextStyle(
    fontSize: AppDimensions.font20,
    fontWeight: mediumFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_5,
  );

  @override
  TextStyle get titleSmall => TextStyle(
    fontSize: AppDimensions.font18,
    fontWeight: mediumFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_5,
  );

  @override
  TextStyle get bodyLarge => TextStyle(
    fontSize: AppDimensions.font16,
    fontWeight: regularFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_5,
  );

  @override
  TextStyle get bodyMedium => TextStyle(
    fontSize: AppDimensions.font14,
    fontWeight: regularFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_5,
  );

  @override
  TextStyle get bodySmall => TextStyle(
    fontSize: AppDimensions.font12,
    fontWeight: regularFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_5,
  );

  @override
  TextStyle get labelLarge => TextStyle(
    fontSize: AppDimensions.font16,
    fontWeight: regularFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get labelMedium => TextStyle(
    fontSize: AppDimensions.font14,
    fontWeight: regularFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  @override
  TextStyle get labelSmall => TextStyle(
    fontSize: AppDimensions.font12,
    fontWeight: regularFontWeight,
    color: textPrimary,
    height: AppDimensions.lineHeight1_2,
  );

  // Generates a [ThemeData] object from the current theme tokens.
  @override
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
        secondaryContainer: secondary.withValues(alpha: 0.8),
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
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
        ),
        textStyle: bodyMedium,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: nytBlue,
        inactiveTrackColor: nytBlue.withValues(alpha: 0.3),
        thumbColor: nytBlue,
        overlayColor: nytBlue.withValues(alpha: 0.2),
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
            return textDisabled.withValues(alpha: 0.5);
          } else if (states.contains(WidgetState.selected)) {
            return nytBlue.withValues(alpha: 0.5);
          }
          return textSecondary.withValues(alpha: 0.3);
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
          textStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return labelMedium.copyWith(
                color: textDisabled,
                fontWeight: mediumFontWeight,
                fontFamily: fontFamilyElevatedButton,
              );
            }
            return labelMedium.copyWith(
              color: buttonPrimaryText,
              fontWeight: mediumFontWeight,
              letterSpacing: 0.5,
              fontFamily: fontFamilyElevatedButton,
            );
          }),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppDimensions.inset16,
              vertical: AppDimensions.inset12,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
          textStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return labelMedium.copyWith(
                color: textDisabled,
                fontWeight: mediumFontWeight,
                fontFamily: fontFamilyElevatedButton,
              );
            }
            return labelMedium.copyWith(
              color: buttonPrimaryText,
              fontWeight: mediumFontWeight,
              letterSpacing: 0.5,
              fontFamily: fontFamilyElevatedButton,
            );
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
              borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
          textStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return labelMedium.copyWith(
                color: textDisabled,
                fontWeight: mediumFontWeight,
                fontFamily: fontFamilyElevatedButton,
              );
            }
            return labelMedium.copyWith(
              color: buttonPrimaryText,
              fontWeight: mediumFontWeight,
              letterSpacing: 0.5,
              fontFamily: fontFamilyElevatedButton,
            );
          }),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              horizontal: AppDimensions.inset16,
              vertical: AppDimensions.inset12,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
          borderSide: BorderSide(color: nytBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
          borderSide: BorderSide(color: error),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius4),
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
