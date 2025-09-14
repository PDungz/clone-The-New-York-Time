// notification_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/feature/notification/presentation/bloc/notification_bloc/notification_bloc.dart';
import 'package:news_app/feature/notification/presentation/pages/notification_breaking_news_page.dart';
import 'package:news_app/feature/notification/presentation/pages/notification_system_page.dart';
import 'package:news_app/feature/notification/presentation/widget/app_bar_notification_widget.dart';
import 'package:packages/widget/layout/layout.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with AutomaticKeepAliveClientMixin {
  int _selectedTabIndex = 0;
  late final PageController _pageController;
  bool _isDisposed = false;

  // Tạo riêng bloc cho từng tab
  late final NotificationBloc _breakingNewsBloc;
  late final NotificationBloc _systemBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializePageController();
    // Khởi tạo riêng bloc cho từng tab
    _breakingNewsBloc = NotificationBloc();
    _systemBloc = NotificationBloc();
  }

  void _initializePageController() {
    if (_selectedTabIndex >= 2) {
      _selectedTabIndex = 1;
    } else if (_selectedTabIndex < 0) {
      _selectedTabIndex = 0;
    }
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pageController.dispose();
    _breakingNewsBloc.close();
    _systemBloc.close();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void _onTabSelected(int index) {
    if (!_isDisposed && _selectedTabIndex != index) {
      _safeSetState(() => _selectedTabIndex = index);
      
      if (_pageController.hasClients && !_isDisposed) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    if (!_isDisposed && _selectedTabIndex != index) {
      _safeSetState(() => _selectedTabIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isDisposed) {
      return const SizedBox.shrink();
    }

    return LayoutWidget(
      appBar: AppBarNotificationWidget(
        selectedTabIndex: _selectedTabIndex,
        pageController: _pageController,
        onTabSelected: _onTabSelected,
      ),
      body: Column(
        children: [
          const SizedBox(height: 180),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Wrap mỗi page với BlocProvider riêng
                BlocProvider.value(
                  value: _breakingNewsBloc,
                  child: const NotificationBreakingNewsPage(),
                ),
                BlocProvider.value(value: _systemBloc, child: const NotificationSystemPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
