import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:packages/gen/assets.gen.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? size;
  final Widget? logo;

  const LoadingWidget({
    super.key,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.size,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIndicatorColor = indicatorColor ?? Colors.black;
    final effectiveSize = size ?? 100;
    final logoSize = effectiveSize * 0.5;

    return Material(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading animation stack
            SizedBox(
              width: effectiveSize,
              height: effectiveSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple effect
                  SpinKitRipple(
                    color: effectiveIndicatorColor,
                    size: effectiveSize,
                    borderWidth: effectiveSize * 0.4,
                  ),
                  // Middle ring
                  SpinKitRing(
                    color: effectiveIndicatorColor,
                    size: effectiveSize * 0.6,
                    lineWidth: 4,
                  ),
                  // Inner pulse
                  SpinKitPulse(color: effectiveIndicatorColor, size: effectiveSize * 0.8),
                  // Logo in center
                  logo ?? _buildDefaultLogo(logoSize, effectiveIndicatorColor),
                ],
              ),
            ),
            // Message display
            if (message != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  message!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Static method for backward compatibility
  static void loadingDialog(
    BuildContext context, {
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
    double? size,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: backgroundColor ?? Colors.black87.withValues(alpha: 0.3),
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            content: LoadingWidget(
              message: message,
              backgroundColor: Colors.transparent,
              indicatorColor: indicatorColor,
              size: size,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultLogo(double logoSize, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: logoSize,
        height: logoSize,
        padding: EdgeInsets.all(logoSize * 0.16),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: SvgPicture.asset(
          $AssetsIconsFilledGen().logo,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }

  static void dismissLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
