import 'package:news_app/core/native/base_native_service.dart';

class DisplayService {
  static final DisplayService _instance = DisplayService._();
  static DisplayService get instance => _instance;

  final BaseNativeService _channel = BaseNativeService('display_service');

  DisplayService._();

  /// Get all display information
  Future<Map<String, dynamic>> getDisplayInfo() async {
    final result = await _channel.call<Map<dynamic, dynamic>>('getDisplayInfo');
    return Map<String, dynamic>.from(result ?? {});
  }

  /// Get screen refresh rate
  Future<double> getRefreshRate() async {
    final result = await _channel.call<double>('getRefreshRate');
    return result ?? 60.0;
  }

  /// Set screen brightness (0.0 to 1.0)
  Future<bool> setBrightness(double brightness) async {
    final result = await _channel.call<bool>('setBrightness', brightness);
    return result ?? false;
  }

  /// Check if device is in portrait mode
  Future<bool> isPortrait() async {
    final result = await _channel.call<bool>('isPortrait');
    return result ?? true;
  }

  /// Check if device is in landscape mode
  Future<bool> isLandscape() async {
    final result = await _channel.call<bool>('isLandscape');
    return result ?? false;
  }

  /// Check if dark mode is enabled
  Future<bool> isDarkMode() async {
    final result = await _channel.call<bool>('isDarkMode');
    return result ?? false;
  }

  /// Get screen size {width: double, height: double}
  Future<Map<String, double>> getScreenSize() async {
    final result = await _channel.call<Map<dynamic, dynamic>>('getScreenSize');
    return Map<String, double>.from(result ?? {'width': 0.0, 'height': 0.0});
  }

  /// Get screen diagonal in inches
  Future<double> getScreenInches() async {
    final result = await _channel.call<double>('getScreenInches');
    return result ?? 0.0;
  }

  // ========================= STREAMS =========================

  /// Listen to orientation changes (portrait/landscape)
  Stream<String> get orientationStream => _channel.stream<String>('display_service/orientation');

  /// Listen to brightness changes (0.0 to 1.0)
  Stream<double> get brightnessStream => _channel.stream<double>('display_service/brightness');

  // ========================= CONVENIENCE GETTERS =========================

  /// Get specific display properties quickly
  Future<String> get orientation async {
    final info = await getDisplayInfo();
    return info['orientation'] ?? 'portrait';
  }

  Future<double> get screenBrightness async {
    final info = await getDisplayInfo();
    return (info['screenBrightness'] ?? 1.0).toDouble();
  }

  Future<double> get fontSize async {
    final info = await getDisplayInfo();
    return (info['fontSize'] ?? 16.0).toDouble();
  }

  Future<String> get themeMode async {
    final info = await getDisplayInfo();
    return info['themeMode'] ?? 'auto';
  }

  Future<bool> get isLargeTextEnabled async {
    final info = await getDisplayInfo();
    return info['isLargeTextEnabled'] ?? false;
  }

  Future<bool> get isReduceMotionEnabled async {
    final info = await getDisplayInfo();
    return info['isReduceMotionEnabled'] ?? false;
  }

  Future<String> get languageCode async {
    final info = await getDisplayInfo();
    return info['languageCode'] ?? 'en';
  }
}
