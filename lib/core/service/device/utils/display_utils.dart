import 'package:flutter/material.dart';

class DisplayUtils {
  /// Phân loại màn hình theo kích thước
  static String getScreenSizeCategory(double inches) {
    if (inches < 4.0) return 'small';
    if (inches < 5.5) return 'normal';
    if (inches < 7.0) return 'large';
    return 'xlarge';
  }

  /// Phân loại density
  static String getDensityCategory(double density) {
    if (density <= 120) return 'ldpi';
    if (density <= 160) return 'mdpi';
    if (density <= 240) return 'hdpi';
    if (density <= 320) return 'xhdpi';
    if (density <= 480) return 'xxhdpi';
    return 'xxxhdpi';
  }

  /// Chuyển đổi dp sang px
  static double dpToPx(double dp, double density) {
    return dp * (density / 160);
  }

  /// Chuyển đổi px sang dp
  static double pxToDp(double px, double density) {
    return px / (density / 160);
  }

  /// Kiểm tra có phải tablet không
  static bool isTablet(double inches) {
    return inches >= 7.0;
  }

  /// Lấy orientation từ size
  static String getOrientationFromSize(Size size) {
    return size.width > size.height ? 'landscape' : 'portrait';
  }
}
