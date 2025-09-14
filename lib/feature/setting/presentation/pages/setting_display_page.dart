import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/global/setting/bloc/setting_cubit/setting_cubit.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/service/device/device_display/display_service.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class SettingDisplayPage extends StatefulWidget {
  const SettingDisplayPage({super.key});

  @override
  State<SettingDisplayPage> createState() => _SettingDisplayPageState();
}

class _SettingDisplayPageState extends State<SettingDisplayPage> {
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
          onPressed: () => AppNavigation.pop(),
          svgPath: $AssetsIconsFilledGen().backward,
          color: AppThemeManager.icon,
          padding: EdgeInsets.all(12.0),
        ),
        title: Text(
          LocaleKeys.setting_display_settings_title.tr,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 86),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    LocaleKeys.setting_display_settings_appearance.tr
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: AppThemeManager.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                DividerWidget(
                  color: AppThemeManager.divider,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    final themeMode = await DisplayService.instance.themeMode;
                    context.read<SettingCubit>().setTheme(themeMode);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          LocaleKeys.setting_display_settings_automatic.tr,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontFamily: 'Roboto'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleKeys.setting_display_settings_automatic_desc.tr,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: AppThemeManager.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DividerWidget(
                          color: AppThemeManager.divider,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.read<SettingCubit>().setTheme('dark'),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          LocaleKeys.setting_display_settings_dark.tr,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontFamily: 'Roboto'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleKeys.setting_display_settings_dark_desc.trArgs([
                            LocaleKeys.setting_display_settings_dark.tr,
                          ]),
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: AppThemeManager.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DividerWidget(
                          color: AppThemeManager.divider,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => context.read<SettingCubit>().setTheme('light'),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          LocaleKeys.setting_display_settings_light.tr,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontFamily: 'Roboto'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleKeys.setting_display_settings_dark_desc.trArgs([
                            LocaleKeys.setting_display_settings_light.tr,
                          ]),
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: AppThemeManager.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DividerWidget(
                  color: AppThemeManager.divider,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.setting_language.tr.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: AppThemeManager.textSecondary,
                        ),
                      ),
                      Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.language),
                        onSelected: context.read<SettingCubit>().setLanguage,
                        itemBuilder:
                            (context) => [
                              _buildLanguageMenuItem('English', 'en'),
                              _buildLanguageMenuItem('Tiếng Việt', 'vi'),
                              _buildLanguageMenuItem('日本語', 'ja'),
                            ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                DividerWidget(
                  color: AppThemeManager.divider,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    LocaleKeys.setting_display_settings_text_size.tr
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: AppThemeManager.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                DividerWidget(
                  color: AppThemeManager.divider,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Text.rich(
                    textAlign: TextAlign.justify,
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              LocaleKeys
                                  .setting_display_settings_text_size_desc
                                  .tr,

                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Roboto',
                            color: AppThemeManager.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${LocaleKeys.setting_display_settings_setting.tr} >',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${LocaleKeys.setting_display_settings_accessibility.tr} >',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${LocaleKeys.setting_display_settings_per_app_settings.tr}.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              LocaleKeys
                                  .setting_display_settings_per_app_settings_desc
                                  .tr,

                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Roboto',
                            color: AppThemeManager.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DividerWidget(
                  color: AppThemeManager.divider,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    LocaleKeys.setting_display_settings_preview.tr
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: AppThemeManager.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                DividerWidget(
                  color: AppThemeManager.divider,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.setting_display_settings_welcome_message.tr
                            .toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        LocaleKeys.setting_display_settings_nyt_intro.tr,
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppThemeManager.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        LocaleKeys.setting_display_settings_nyt_quote_author.tr,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: AppThemeManager.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildLanguageMenuItem(String label, String locale) {
    return PopupMenuItem<String>(
      value: locale,
      child: Row(children: [Text(label), const SizedBox(width: 8)]),
    );
  }
}
