import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app/core/router/app_navigation.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/theme/theme_manager.dart';
import 'package:news_app/feature/home/domain/enum/home_page_section_enum.dart';
import 'package:news_app/feature/home/domain/extension/home_page_section_extension.dart';
import 'package:news_app/feature/notification/presentation/bloc/notification_websocket_bloc/notification__websocket_bloc.dart';
import 'package:news_app/gen/assets.gen.dart';
import 'package:packages/widget/app_bar/app_bar_widget.dart';
import 'package:packages/widget/button/icon_button_widget.dart';
import 'package:packages/widget/tab_label/tab_label_widget.dart';

class AppBarHomeWidget extends StatelessWidget {
  const AppBarHomeWidget({
    super.key,
    required this.selectedTabIndex,
    required this.pageController,
    required this.onTabSelected,
  });

  final int selectedTabIndex;
  final PageController pageController;
  final Function(int index) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      backgroundColor: AppThemeManager.appBar,
      boxShadow: BoxShadow(
        color: AppThemeManager.shadow,
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
      leading: BlocBuilder<NotificationWebSocketBloc, NotificationWebSocketState>(
        builder: (context, state) {
          // Extract real-time data from BLoC state
          bool hasNotification = false;
          String displayText = '';
          bool hasNewMessage = false;

          if (state is NotificationWebSocketConnected) {
            hasNotification = state.hasNotificationWebSocket; // shouldShowBadge from real-time data
            displayText = state.displayText; // "29", "99+", etc. from real-time data
            hasNewMessage = state.hasNewMessage; // animation flag from real-time data
          }
          return SizedBox(
            height: 36,
            width: 68,
            child: GestureDetector(
              onTap: () {
                // Mark as read when tapped if there are notifications
                // if (hasNotification) {
                //   context.read<NotificationBloc>().add(const NotificationMarkAllAsReadEvent());
                // }
                // getIt<NotificationUseCase>().getUserNotifications(page: 0, size: 20);
                AppNavigation.pushNamed(AppRouter.notification);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child:
                    hasNotification // Use real-time hasNotification instead of hardcoded
                        ? Stack(
                          children: [
                            // Use hasNewMessage from real-time data for animation
                            hasNewMessage
                                ? LottieBuilder.asset(
                                  $AssetsIconsLottieGen().bell,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  delegates: LottieDelegates(
                                    values: [
                                      ValueDelegate.color(const [
                                        '**',
                                      ], value: AppThemeManager.icon),
                                    ],
                                  ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    $AssetsIconsFilledGen().bell,
                                    height: 24,
                                    width: 24,
                                    colorFilter: ColorFilter.mode(
                                      AppThemeManager.icon,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),

                            // Badge with real-time count
                            if (displayText.isNotEmpty) // Only show if there's actual count
                              Positioned(
                                left: 16,
                                top: 0,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppThemeManager.redAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayText, // Use real-time displayText (already formatted)
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppThemeManager.nytWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                        : Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            $AssetsIconsFilledGen().bell,
                            height: 24,
                            width: 24,
                            colorFilter: ColorFilter.mode(AppThemeManager.icon, BlendMode.srcIn),
                          ),
                        ),
              ),
            ),
          );
        },
      ),
      paddingTop: 0,
      paddingBottom: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 88, right: 88),
        child: SvgPicture.asset(
          $AssetsIconsBrandGen().titleBrand,
          height: 28,
          colorFilter: ColorFilter.mode(AppThemeManager.textPrimary, BlendMode.srcIn),
        ),
      ),
      actions: [
        IconButtonWidget(
          svgPath: $AssetsIconsFilledGen().search,
          size: 24,
          color: AppThemeManager.icon,
          padding: const EdgeInsets.only(right: 12.0),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: TabLabelWidget(
          isScrollable: true,
          labels: [
            HomePageSectionEnum.game.localized,
            HomePageSectionEnum.audio.localized,
            HomePageSectionEnum.wirecutter.localized,
            HomePageSectionEnum.cooking.localized,
            HomePageSectionEnum.theAthletic.localized,
            HomePageSectionEnum.home.localized,
            HomePageSectionEnum.lifestyle.localized,
            HomePageSectionEnum.greatReads.localized,
            HomePageSectionEnum.option.localized,
            HomePageSectionEnum.sections.localized,
          ],
          selectedTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppThemeManager.icon,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
          unselectedTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppThemeManager.unsetIcon,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
          fitIndicatorToText: true,
          paddingTabel: EdgeInsets.zero,
          touchAreaPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          indicatorColor: AppThemeManager.icon,
          selectedIndex: selectedTabIndex,
          onTap: onTabSelected,
          spaceBetweenLabelAndIndicator: false,
          indicatorHeight: 4,
          showSelectedShadow: false,
          unselectedColor: AppThemeManager.unsetIcon,
        ),
      ),
    );
  }
}
