import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app/core/service/device/device_display/model/device_display_info.dart';
import 'package:screen_brightness/screen_brightness.dart';

class DeviceDisplayReader {
  static const MethodChannel _channel = MethodChannel('device_display_reader');

  /// Lấy tất cả thông tin display & UI từ device
  static Future<DeviceDisplayInfo> getDeviceDisplayInfo(
    BuildContext context,
  ) async {
    // Lấy thông tin cơ bản từ Flutter
    final mediaQuery = MediaQuery.of(context);
    final platformDispatcher = PlatformDispatcher.instance;

    // Lấy thông tin theme
    final brightness = platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    // Lấy thông tin font
    final textScaleFactor = mediaQuery.textScaleFactor;
    final baseFontSize = 16.0 * textScaleFactor;

    // Lấy thông tin màn hình
    final size = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final orientation = mediaQuery.orientation;

    // Tính toán kích thước màn hình
    final physicalWidth = size.width * devicePixelRatio;
    final physicalHeight = size.height * devicePixelRatio;
    final diagonal = _calculateScreenInches(
      physicalWidth,
      physicalHeight,
      devicePixelRatio,
    );

    // Lấy thông tin ngôn ngữ
    final locale = platformDispatcher.locale;
    final isRTL = _isRTLLanguage(locale.languageCode);

    // Lấy padding system
    final padding = mediaQuery.padding;

    // Lấy brightness từ system (nếu có)
    double screenBrightness = 1.0;
    try {
      screenBrightness = await ScreenBrightness().current;
    } catch (e) {
      // Fallback nếu không lấy được
      screenBrightness = 1.0;
    }

    // Lấy thông tin accessibility và animation từ native
    final nativeInfo = await _getNativeDisplayInfo();

    return DeviceDisplayInfo(
      // Theme
      themeMode: _getThemeMode(brightness),
      isDarkMode: isDarkMode,

      // Font
      fontSize: baseFontSize,
      textScaleFactor: textScaleFactor,
      fontFamily: _getSystemFontFamily(),
      isBoldTextEnabled: nativeInfo['isBoldTextEnabled'] ?? false,
      isLargeTextEnabled: textScaleFactor > 1.15,

      // Screen
      screenBrightness: screenBrightness,
      orientation:
          orientation == Orientation.portrait ? 'portrait' : 'landscape',
      screenWidth: size.width,
      screenHeight: size.height,
      devicePixelRatio: devicePixelRatio,
      screenDensity: _calculateDensity(devicePixelRatio),
      screenInches: diagonal,

      // Color & Accessibility
      isHighContrastEnabled: nativeInfo['isHighContrastEnabled'] ?? false,
      isInvertColorsEnabled: nativeInfo['isInvertColorsEnabled'] ?? false,
      colorScheme: _getColorScheme(nativeInfo),

      // Animation
      isReduceMotionEnabled: nativeInfo['isReduceMotionEnabled'] ?? false,
      animationDurationScale: nativeInfo['animationDurationScale'] ?? 1.0,
      transitionAnimationScale: nativeInfo['transitionAnimationScale'] ?? 1.0,

      // System
      languageCode: locale.languageCode,
      isRTL: isRTL,
      statusBarHeight: padding.top,
      navigationBarHeight: padding.bottom,
    );
  }

  /// Lấy thông tin từ native platform
  static Future<Map<String, dynamic>> _getNativeDisplayInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDisplayInfo',
      );
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      print('Error getting native display info: $e');
      return {};
    }
  }

  /// Xác định theme mode
  static String _getThemeMode(Brightness brightness) {
    // Trong Flutter, ta chỉ có thể biết current brightness
    // Không thể phân biệt được user chọn dark/light hay auto
    // Trừ khi dùng native channel
    return brightness == Brightness.dark ? 'dark' : 'light';
  }

  /// Lấy system font family
  static String _getSystemFontFamily() {
    if (Platform.isIOS) {
      return 'SF Pro Text';
    } else if (Platform.isAndroid) {
      return 'Roboto';
    }
    return 'System';
  }

  /// Tính toán screen density category
  static double _calculateDensity(double devicePixelRatio) {
    if (devicePixelRatio <= 1.0) return 120; // ldpi
    if (devicePixelRatio <= 1.5) return 160; // mdpi
    if (devicePixelRatio <= 2.0) return 240; // hdpi
    if (devicePixelRatio <= 3.0) return 320; // xhdpi
    if (devicePixelRatio <= 4.0) return 480; // xxhdpi
    return 640; // xxxhdpi
  }

  /// Tính toán kích thước màn hình (inches)
  static double _calculateScreenInches(
    double width,
    double height,
    double dpi,
  ) {
    final diagonal = (width * width + height * height) / (dpi * dpi);
    return diagonal;
  }

  /// Kiểm tra ngôn ngữ RTL
  static bool _isRTLLanguage(String languageCode) {
    const rtlLanguages = ['ar', 'he', 'fa', 'ur', 'ps', 'sd'];
    return rtlLanguages.contains(languageCode);
  }

  /// Xác định color scheme
  static String _getColorScheme(Map<String, dynamic> nativeInfo) {
    if (nativeInfo['isHighContrastEnabled'] == true) {
      return 'high_contrast';
    }
    if (nativeInfo['isInvertColorsEnabled'] == true) {
      return 'inverted';
    }
    return 'normal';
  }

  /// Lấy thông tin refresh rate
  static Future<double> getRefreshRate() async {
    try {
      final result = await _channel.invokeMethod<double>('getRefreshRate');
      return result ?? 60.0;
    } catch (e) {
      return 60.0;
    }
  }

  /// Lấy thông tin chi tiết về display modes
  static Future<List<Map<String, dynamic>>> getSupportedDisplayModes() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getSupportedDisplayModes',
      );
      return result?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Stream để lắng nghe thay đổi orientation
  static Stream<String> get orientationStream {
    return const EventChannel(
      'device_display_reader/orientation',
    ).receiveBroadcastStream().map((event) => event.toString());
  }

  /// Stream để lắng nghe thay đổi brightness
  static Stream<double> get brightnessStream {
    return const EventChannel(
      'device_display_reader/brightness',
    ).receiveBroadcastStream().map((event) => (event as num).toDouble());
  }
}
