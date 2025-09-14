
import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:packages/widget/shimmer/shimmer_widget.dart';

class LoadingNotificationWidget extends StatelessWidget {
  const LoadingNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            height: 20,
            borderRadius: 0,
            baseColor: AppThemeManager.nightModeText,
            highlightColor: AppThemeManager.nytAccent,
          ),
          const SizedBox(height: 12),
          ShimmerWidget(
            height: 180,
            borderRadius: 0,
            baseColor: AppThemeManager.nightModeText,
            highlightColor: AppThemeManager.nytAccent,
          ),
          const SizedBox(height: 12),
          ShimmerWidget(
            height: 16,
            width: 0.8.wp(context),
            borderRadius: 0,
            baseColor: AppThemeManager.nightModeText,
            highlightColor: AppThemeManager.nytAccent,
          ),
          const SizedBox(height: 12),
          ShimmerWidget(
            height: 32,
            borderRadius: 0,
            baseColor: AppThemeManager.nightModeText,
            highlightColor: AppThemeManager.nytAccent,
          ),
        ],
      ),
    );
  }
}