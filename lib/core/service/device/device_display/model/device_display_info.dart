class DeviceDisplayInfo {
  // Theme Information
  final String themeMode; // "dark", "light", "auto"
  final bool isDarkMode;

  // Font Information
  final double fontSize;
  final double textScaleFactor;
  final String fontFamily;
  final bool isBoldTextEnabled;
  final bool isLargeTextEnabled;

  // Screen Information
  final double screenBrightness; // 0.0 - 1.0
  final String orientation; // "portrait", "landscape"
  final double screenWidth;
  final double screenHeight;
  final double devicePixelRatio;
  final double screenDensity;
  final double screenInches;

  // Color & Accessibility
  final bool isHighContrastEnabled;
  final bool isInvertColorsEnabled;
  final String colorScheme; // "normal", "high_contrast", "inverted"

  // Animation & Motion
  final bool isReduceMotionEnabled;
  final double animationDurationScale;
  final double transitionAnimationScale;

  // System Information
  final String languageCode;
  final bool isRTL;
  final double statusBarHeight;
  final double navigationBarHeight;

  const DeviceDisplayInfo({
    required this.themeMode,
    required this.isDarkMode,
    required this.fontSize,
    required this.textScaleFactor,
    required this.fontFamily,
    required this.isBoldTextEnabled,
    required this.isLargeTextEnabled,
    required this.screenBrightness,
    required this.orientation,
    required this.screenWidth,
    required this.screenHeight,
    required this.devicePixelRatio,
    required this.screenDensity,
    required this.screenInches,
    required this.isHighContrastEnabled,
    required this.isInvertColorsEnabled,
    required this.colorScheme,
    required this.isReduceMotionEnabled,
    required this.animationDurationScale,
    required this.transitionAnimationScale,
    required this.languageCode,
    required this.isRTL,
    required this.statusBarHeight,
    required this.navigationBarHeight,
  });

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'isDarkMode': isDarkMode,
      'fontSize': fontSize,
      'textScaleFactor': textScaleFactor,
      'fontFamily': fontFamily,
      'isBoldTextEnabled': isBoldTextEnabled,
      'isLargeTextEnabled': isLargeTextEnabled,
      'screenBrightness': screenBrightness,
      'orientation': orientation,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'devicePixelRatio': devicePixelRatio,
      'screenDensity': screenDensity,
      'screenInches': screenInches,
      'isHighContrastEnabled': isHighContrastEnabled,
      'isInvertColorsEnabled': isInvertColorsEnabled,
      'colorScheme': colorScheme,
      'isReduceMotionEnabled': isReduceMotionEnabled,
      'animationDurationScale': animationDurationScale,
      'transitionAnimationScale': transitionAnimationScale,
      'languageCode': languageCode,
      'isRTL': isRTL,
      'statusBarHeight': statusBarHeight,
      'navigationBarHeight': navigationBarHeight,
    };
  }

  @override
  String toString() {
    return '''
DeviceDisplayInfo:
  Theme: $themeMode (isDark: $isDarkMode)
  Font: ${fontSize}px, scale: $textScaleFactor, family: $fontFamily
  Screen: ${screenWidth.toInt()}x${screenHeight.toInt()}, ${screenInches.toStringAsFixed(1)}", density: $screenDensity
  Brightness: ${(screenBrightness * 100).toInt()}%
  Orientation: $orientation
  Accessibility: contrast=$isHighContrastEnabled, motion=$isReduceMotionEnabled, bold=$isBoldTextEnabled
  Language: $languageCode (RTL: $isRTL)
    ''';
  }
}
