import 'package:flutter/material.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class SettingTestingPage extends StatefulWidget {
  const SettingTestingPage({super.key});

  @override
  State<SettingTestingPage> createState() => _SettingTestingPageState();
}

class _SettingTestingPageState extends State<SettingTestingPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      appBar: AppBarWidget(
        backgroundColor: AppThemeManager.appBar.withValues(
          alpha: AppDimensions.opacity80,
        ),
        boxShadow: BoxShadow(
          color: AppThemeManager.shadow,
          blurRadius: AppDimensions.radius4,
          offset: const Offset(0, 1),
        ),
        paddingTop: AppDimensions.inset0,
        paddingBottom: AppDimensions.inset0,
        overlayColor: true,
        leading: IconButtonWidget(
          onPressed: () => Navigator.pop(context),
          svgPath: $AssetsIconsFilledGen().backward,
          color: AppThemeManager.icon,
          padding: EdgeInsets.all(AppDimensions.radius12),
        ),
        title: Text(
          "Testing",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontFamily: 'Roboto'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.inset20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
            ],
          ),
        ),
      ),
    );
  }
}
