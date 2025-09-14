import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/feature/home/presentation/pages/home_today_widget.dart';
import 'package:news_app/feature/home/presentation/widget/app_bar_home_widget.dart';
import 'package:news_app/feature/notification/presentation/bloc/notification_websocket_bloc/notification__websocket_bloc.dart';
import 'package:news_app/generated/locales.g.dart';
import 'package:packages/widget/layout/layout.dart';
import 'package:packages/widget/page_view/page_view_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 5;
  late final PageController _pageController;

  // Initialize NotificationBloc immediately, not late
  final NotificationWebSocketBloc _notificationBloc = getIt<NotificationWebSocketBloc>();

  final List<Widget> _pageView = [
    Container(child: Center(child: Text(LocaleKeys.home_game.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_audio.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_wirecutter.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_cooking.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_theAthletic.tr))),
    const HomeTodayWidget(),
    Container(child: Center(child: Text(LocaleKeys.home_lifestyle.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_greatReads.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_option.tr))),
    Container(child: Center(child: Text(LocaleKeys.home_sections.tr))),
  ];

  @override
  void initState() {
    super.initState();
    _initializePageController();
    _initializeNotificationBloc();
  }

  void _initializePageController() {
    // Validate _selectedTabIndex and initialize PageController
    if (_selectedTabIndex >= _pageView.length) {
      _selectedTabIndex = _pageView.length - 1;
    } else if (_selectedTabIndex < 0) {
      _selectedTabIndex = 0;
    }
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  void _initializeNotificationBloc() {
    // Initialize notification system when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check current state
      final currentState = _notificationBloc.state;

      // Connect if not already connected
      if (currentState is! NotificationWebSocketConnected) {
        _notificationBloc.add(const NotificationWebSocketConnectEvent());
      }

      _notificationBloc.add(const NotificationWebSocketSubscribeEvent());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationBloc.add(const NotificationWebSocketDisconnectEvent());
    });
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedTabIndex != index) {
      setState(() => _selectedTabIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutWidget(
      appBar: BlocProvider<NotificationWebSocketBloc>.value(
        value: _notificationBloc,
        child: AppBarHomeWidget(
          selectedTabIndex: _selectedTabIndex,
          pageController: _pageController,
          onTabSelected: _onTabSelected,
        ),
      ),
      body: PageViewWidget(
        controller: _pageController,
        pages: _pageView,
        onPageChanged: (index) {
          if (_selectedTabIndex != index) {
            setState(() => _selectedTabIndex = index);
          }
        },
        showIndicator: false,
      ),
    );
  }
}
