import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/global/setting/bloc/setting_cubit/setting_cubit.dart';
import 'package:news_app/core/service/storage/secure_storage_manager.dart';
import 'package:news_app/core/theme/app_nyt_color.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/button_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';
import 'package:packages/widget/layout/layout.dart';
import 'package:packages/widget/switch_widget/switch_widget.dart';
// Import native service

class SettingDataUsagePage extends StatefulWidget {
  const SettingDataUsagePage({super.key});

  @override
  State<SettingDataUsagePage> createState() => _SettingDataUsageState();
}

class _SettingDataUsageState extends State<SettingDataUsagePage> {
  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      appBar: AppBarWidget(
        backgroundColor: AppThemeManager.appBar.withValues(alpha: 0.8),
        boxShadow: BoxShadow(
          color: AppThemeManager.shadow,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        paddingTop: 0,
        paddingBottom: 0,
        overlayColor: true,
        leading: IconButtonWidget(
          onPressed: () => Navigator.pop(context),
          svgPath: $AssetsIconsFilledGen().backward,
          color: AppThemeManager.icon,
          padding: EdgeInsets.all(12.0),
        ),
        title: Text(
          LocaleKeys.setting_data_usage_title.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Column(
              children: [
                DividerWidget(color: AppThemeManager.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.setting_data_usage_automatic_refresh.tr,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                        ),
                      ),
                      SwitchWidget(inactiveThumbColor: AppNYTColors.lightBackground),
                    ],
                  ),
                ),
                DividerWidget(color: AppThemeManager.divider),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text(
                    LocaleKeys.setting_data_usage_automatic_refresh_desc.tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: AppThemeManager.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DividerWidget(color: AppThemeManager.divider),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.setting_data_usage_download_images.tr,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto'),
                        ),
                      ),
                      SwitchWidget(inactiveThumbColor: AppNYTColors.lightBackground),
                    ],
                  ),
                ),
                DividerWidget(color: AppThemeManager.divider),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Text(
                    LocaleKeys.setting_data_usage_download_images_desc.tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: AppThemeManager.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DividerWidget(color: AppThemeManager.divider),
              ],
            ),
            ButtonWidget(
              label: 'Clear cache',
              textStyle: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontFamily: 'Roboto', color: AppThemeManager.error),
              backgroundColor: AppThemeManager.background,
              onPressed: () async {
                context.read<SettingCubit>().clearAllCache();
                final SecureStorageManager settingDataUsageState =
                    await SecureStorageManager.getInstance();
                await settingDataUsageState.deleteAll();
              },
            ),
            DividerWidget(color: AppThemeManager.divider),
          ],
        ),
      ),
    );
  }
}
