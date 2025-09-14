import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';

class ButtonSettingWidget extends StatelessWidget {
  const ButtonSettingWidget({
    super.key,
    required this.text,
    this.onTap,
    this.showIcon = false,
    this.border,
  });
  final String text;
  final VoidCallback? onTap;
  final bool showIcon;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              border ??
              Border(
                bottom: BorderSide(
                  color: AppThemeManager.divider,
                ),
              ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontFamily: 'Roboto'),
                ),
              ),
              if (showIcon)
                SvgPicture.asset(
                  $AssetsIconsFilledGen().forward,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    AppThemeManager.icon,
                    BlendMode.srcIn,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingInfoWidget extends StatelessWidget {
  const SettingInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DividerWidget(color: AppThemeManager.divider),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.setting_title.tr.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontFamily: 'Roboto',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.setting_not_subscribed.tr.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: AppThemeManager.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'phvndung0306@gmail.com',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }
}
