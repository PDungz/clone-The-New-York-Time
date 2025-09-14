import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/base/api/token_session_manager.dart';
import 'package:news_app/core/global/setting/bloc/setting_cubit/setting_cubit.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/home/domain/enum/home_page_section_enum.dart';
import 'package:news_app/feature/home/presentation/bloc/top_stories_bloc/top_stories_bloc.dart';
import 'package:news_app/feature/home/presentation/pages/home_page.dart';
import 'package:news_app/feature/listen/presentation/pages/listen_page.dart';
import 'package:news_app/feature/play/presentation/pages/play_page.dart';
import 'package:news_app/feature/profile/presentation/pages/profile_pages.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/bottom_navigation_app_bar/bottom_navigation_app_bar.dart';
import 'package:packages/widget/layout/layout.dart';

class EntryPointPage extends StatefulWidget {
  const EntryPointPage({super.key, this.currentPage, this.selectIndexPage});

  final Widget? currentPage;
  final int? selectIndexPage;

  @override
  State<EntryPointPage> createState() => _EntryPointPageState();
}

class _EntryPointPageState extends State<EntryPointPage> {
  late int _currentIndex;
  late final List<Widget> _pageScreens;

  @override
  void initState() {
    super.initState();
    _pageScreens = [HomePage(), ListenPage(), PlayPage(), ProfilePages()];

    if (widget.currentPage != null) {
      _pageScreens.add(widget.currentPage!);
    }

    _currentIndex =
        widget.selectIndexPage != null &&
                widget.selectIndexPage! >= 0 &&
                widget.selectIndexPage! < _pageScreens.length
            ? widget.selectIndexPage!
            : 0;

    // Khởi tạo và start TokenSessionManager
    TokenSessionManager.instance
        .initialize(
          onTokenExpired: () {
            if (mounted) {
              AppNavigation.pushNamed(AppRouter.login);
            }
          },
        )
        .then((_) {
          TokenSessionManager.instance.startTokenMonitoring();
        });
  }

  void _nextPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  TopStoriesBloc()..add(
                    LoadTopStoriesEvent(section: HomePageSectionEnum.home.name),
                  ),
        ),
      ],
      child: LayoutWidget(
        background: ColoredBox(color: AppThemeManager.background),
        body: PageTransitionSwitcher(
          transitionBuilder:
              (child, primaryAnimation, secondaryAnimation) =>
                  SharedAxisTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  ),
          child: _pageScreens[_currentIndex],
        ),
        // Only wrap the bottom navigation bar with BlocBuilder for more targeted rebuilds
        bottomNavigationBar: BlocBuilder<SettingCubit, SettingState>(
          builder: (context, state) {
            return BottomNavigationAppBarWidget(
              buildContext: context,
              boxShadow: BoxShadow(
                color: AppThemeManager.shadow,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              itemPadding: const EdgeInsets.symmetric(horizontal: 24),
              onNextPage: _nextPage,
              selectedIconColor: AppThemeManager.icon,
              unselectedIconColor: AppThemeManager.unsetIcon,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: 'Roboto'),
              navigationItems: <NavigationItem>[
                NavigationItem(
                  icon: $AssetsIconsFilledGen().logo,
                  label: LocaleKeys.common_home.tr,
                ),
                NavigationItem(
                  icon: $AssetsIconsFilledGen().listen,
                  label: LocaleKeys.common_listen.tr,
                ),
                NavigationItem(
                  icon: $AssetsIconsFilledGen().play,
                  label: LocaleKeys.common_play.tr,
                ),
                NavigationItem(
                  icon: $AssetsIconsFilledGen().profile,
                  label: LocaleKeys.common_you.tr,
                ),
              ],
              showLabels: true,
              background: AppThemeManager.background,
              initialSelectedIndex: _currentIndex,
              iconSize: 26.0,
            );
          },
        ),
      ),
    );
  }
}
