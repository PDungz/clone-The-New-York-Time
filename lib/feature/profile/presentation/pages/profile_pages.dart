import 'package:flutter/material.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  State<ProfilePages> createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      appBar: AppBarWidget(
        backgroundColor: AppThemeManager.appBar,
        title: Text(
          "Add your name",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
        ),
        actions: [
          IconButtonWidget(
            onPressed: () => AppNavigation.pushNamed(AppRouter.settings),
            svgPath: $AssetsIconsFilledGen().setting,
            color: AppThemeManager.icon,
            padding: EdgeInsets.all(12.0),
          ),
        ],
      ),

      body: Center(child: Text(LocaleKeys.common_you.tr)),
    );
  }
}
