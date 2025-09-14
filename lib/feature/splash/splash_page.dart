import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/theme/app_dimension.dart';
import 'package:news_app/core/theme/app_nyt_color.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/core/utils/format_date.dart';
import 'package:packages/widget/layout/layout.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late bool isNextSplash = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () async {
      setState(() {
        isNextSplash = true;
      });
    });

    Future.delayed(Duration(seconds: 3), () async {
      if (isNextSplash) {
        AppNavigation.pushNamed(AppRouter.auth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      background: ColoredBox(
        color:
            isNextSplash
                ? AppNYTColors.lightBackground
                : AppNYTColors.darkBackground,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isNextSplash
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: SvgPicture.asset(
                    $AssetsIconsBrandGen().titleBrand,
                    colorFilter: ColorFilter.mode(
                      AppNYTColors.darkBackground,

                      BlendMode.srcIn,
                    ),
                  ),
                ).animate().slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: AppAnimationPresets.duration500,
                )
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: SvgPicture.asset(
                    $AssetsIconsBrandGen().titleBrand,
                    colorFilter: ColorFilter.mode(
                      AppNYTColors.lightBackground,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
            if (isNextSplash)
              Text(
                FormatDate.formatFullHumanReadable(
                  DateTime.now(),
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppNYTColors.darkBackground,
                ),
              ).animate().slideY(
                begin: 1.0,
                end: 0.0,
                duration: AppAnimationPresets.duration500,
              ),
          ],
        ),
      ),
    );
  }
}
