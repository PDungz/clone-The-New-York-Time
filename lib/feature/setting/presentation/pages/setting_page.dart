import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_test_page.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_testing_page.dart';
import 'package:news_app/feature/setting/presentation/widget/setting_common_widget.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            AppNavigation.pushNamed(AppRouter.login);
          }
        },
        child: LayoutWidget(
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
              LocaleKeys.setting_my_account.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
            ),
            actions: [
              IconButtonWidget(
                onPressed: () {},
                svgPath: $AssetsIconsFilledGen().setting,
                color: AppThemeManager.icon,
                padding: EdgeInsets.all(12.0),
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 64),
                SettingInfoWidget(),
                const SizedBox(height: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        LocaleKeys.setting_account.tr.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: AppThemeManager.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_subscribe.tr,
                      border: Border.symmetric(
                        horizontal: BorderSide(color: AppThemeManager.divider),
                      ),
                    ),
                    ButtonSettingWidget(text: LocaleKeys.setting_restore_subscription.tr),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        LocaleKeys.setting_app_setting.tr.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: AppThemeManager.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_biometric_setting.tr,
                      showIcon: true,
                      border: Border.symmetric(
                        horizontal: BorderSide(color: AppThemeManager.divider),
                      ),
                      onTap: () => AppNavigation.pushNamed(AppRouter.settingBiometric),
                    ),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_privacy_setting.tr,
                      showIcon: true,
                    ),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_display_settings_title.tr,
                      showIcon: true,
                      onTap: () => AppNavigation.pushNamed(AppRouter.settingDisplaySettings),
                    ),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_data_usage_title.tr,
                      showIcon: true,
                      onTap: () => AppNavigation.pushNamed(AppRouter.settingDataUsage),
                    ),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_autoplay_videos.tr,
                      showIcon: true,
                    ),
                    ButtonSettingWidget(
                      text: LocaleKeys.setting_device_manager_title.tr,
                      showIcon: true,
                      onTap: () => AppNavigation.pushNamed(AppRouter.settingDeviceManager),
                    ),
                    ButtonSettingWidget(
                      text: "Setting Device Test",
                      showIcon: true,
                      onTap:
                          () => AppNavigation.pushWidget(SettingTestPage(),
                          ),
                    ),
                    ButtonSettingWidget(
                      text: "Setting Testing",
                      showIcon: true,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingTestingPage()),
                          ),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return ButtonSettingWidget(
                          text: "Logout",
                          onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
