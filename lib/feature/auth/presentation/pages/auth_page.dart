import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/theme/app_nyt_color.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/button/button_widget.dart';
import 'package:packages/widget/divider_widget/divider_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      background: Image.asset(
        AppThemeManager.backgroundSplash,
        fit: BoxFit.cover,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 54),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    SvgPicture.asset(
                      $AssetsIconsBrandGen().titleBrand,
                      colorFilter: ColorFilter.mode(
                        AppNYTColors.darkTextPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                    DividerWidget(color: AppNYTColors.darkDivider),
                    const SizedBox(height: 12),
                    Text(
                      LocaleKeys.auth_description.tr,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppNYTColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              ButtonWidget(
                backgroundColor: AppNYTColors.darkButtonPrimary,
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppNYTColors.darkButtonPrimaryText,
                  fontFamily: 'Roboto',
                ),
                sizeMode: ButtonSizeMode.fitContent,
                borderRadius: 4,
                padding: EdgeInsets.symmetric(horizontal: 82, vertical: 12),
                label: LocaleKeys.auth_login_button.tr,
                onPressed: () => AppNavigation.pushNamed( AppRouter.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
