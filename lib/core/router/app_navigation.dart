// lib/core/router/app_navigation.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

class AppNavigation {
  static final GoRouter _router = AppRouter.router;
  
  // Helper để lấy navigator context từ GoRouter
  static NavigatorState? get _navigator {
    return _router.routerDelegate.navigatorKey.currentState;
  }

  // Basic navigation methods
  static void go(String path, {Object? arguments}) {
    _router.go(path, extra: arguments);
  }

  static void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? arguments,
  }) {
    _router.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: arguments,
    );
  }

  static Future<T?> push<T extends Object?>(String path, {Object? arguments}) {
    return _router.push(path, extra: arguments);
  }

  static Future<T?> pushReplacement<T extends Object?>(String path, {Object? arguments}) {
    return _router.pushReplacement(path, extra: arguments);
  }

  static void pop<T extends Object?>([T? result]) {
    _router.pop(result);
  }

  static bool canPop() {
    return _router.canPop();
  }

  // Widget-based navigation methods (không cần context)
  static Future<T?> pushWidget<T extends Object?>(
    Widget widget, {
    bool fullscreenDialog = false,
    RouteSettings? settings,
  }) {
    final navigator = _navigator;
    if (navigator == null) {
      throw Exception('Navigator not found. GoRouter not initialized properly');
    }

    return navigator.push<T>(
      MaterialPageRoute<T>(
        builder: (context) => widget,
        fullscreenDialog: fullscreenDialog,
        settings: settings,
      ),
    );
  }

  static Future<T?> pushWidgetReplacement<T extends Object?, TO extends Object?>(
    Widget widget, {
    bool fullscreenDialog = false,
    RouteSettings? settings,
    TO? result,
  }) {
    final navigator = _navigator;
    if (navigator == null) {
      throw Exception('Navigator not found. GoRouter not initialized properly');
    }

    return navigator.pushReplacement<T, TO>(
      MaterialPageRoute<T>(
        builder: (context) => widget,
        fullscreenDialog: fullscreenDialog,
        settings: settings,
      ),
      result: result,
    );
  }

  static Future<T?> pushWidgetAndRemoveUntil<T extends Object?>(
    Widget widget,
    bool Function(Route<dynamic>) predicate, {
    bool fullscreenDialog = false,
    RouteSettings? settings,
  }) {
    final navigator = _navigator;
    if (navigator == null) {
      throw Exception('Navigator not found. GoRouter not initialized properly');
    }

    return navigator.pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(
        builder: (context) => widget,
        fullscreenDialog: fullscreenDialog,
        settings: settings,
      ),
      predicate,
    );
  }

  // Custom route-based navigation (không cần context)
  static Future<T?> pushRoute<T extends Object?>(Route<T> route) {
    final navigator = _navigator;
    if (navigator == null) {
      throw Exception('Navigator not found. GoRouter not initialized properly');
    }

    return navigator.push<T>(route);
  }

  // Flutter-style navigation methods (giống Navigator)
  static Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return push(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return pushReplacement(routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    // GoRouter: go() tự động clear stack
    go(routeName, arguments: arguments);
    return Future.value(null);
  }

  // Stack manipulation methods
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    while (_router.canPop()) {
      _router.pop();
      // Note: GoRouter không có exact equivalent của predicate function
    }
  }

  static void popUntilPath(String path) {
    while (_router.canPop() && _router.routerDelegate.currentConfiguration.uri.toString() != path) {
      _router.pop();
    }
  }

  // Helper methods
  static void clearStackAndGo(String path, {Object? arguments}) {
    _router.go(path, extra: arguments);
  }

  // // Convenient route methods
  // static void toSplash({Object? arguments}) => go(AppRouter.splash, arguments: arguments);
  // static void toAuth({Object? arguments}) => go(AppRouter.auth, arguments: arguments);
  // static void toLogin({Object? arguments}) => go(AppRouter.login, arguments: arguments);
  // static void toEntryPoint({Object? arguments}) => go(AppRouter.entryPoint, arguments: arguments);
  // static void toHome({Object? arguments}) => go(AppRouter.home, arguments: arguments);
  // static void toNews({Object? arguments}) => go(AppRouter.news, arguments: arguments);
  // static void toListen({Object? arguments}) => go(AppRouter.listen, arguments: arguments);
  // static void toPlay({Object? arguments}) => go(AppRouter.play, arguments: arguments);
  // static void toProfile({Object? arguments}) => go(AppRouter.profile, arguments: arguments);
  // static void toSettings({Object? arguments}) => go(AppRouter.settings, arguments: arguments);
  // static void toSettingDisplaySettings({Object? arguments}) => go(AppRouter.settingDisplaySettings, arguments: arguments);
  // static void toSettingDeviceManager({Object? arguments}) => go(AppRouter.settingDeviceManager, arguments: arguments);
  // static void toSettingDataUsage({Object? arguments}) => go(AppRouter.settingDataUsage, arguments: arguments);

  // // Push methods (keep navigation stack)
  // static Future<T?> pushToSplash<T extends Object?>({Object? arguments}) => push(AppRouter.splash, arguments: arguments);
  // static Future<T?> pushToAuth<T extends Object?>({Object? arguments}) => push(AppRouter.auth, arguments: arguments);
  // static Future<T?> pushToLogin<T extends Object?>({Object? arguments}) => push(AppRouter.login, arguments: arguments);
  // static Future<T?> pushToHome<T extends Object?>({Object? arguments}) => push(AppRouter.home, arguments: arguments);
  // static Future<T?> pushToNews<T extends Object?>({Object? arguments}) => push(AppRouter.news, arguments: arguments);
  // static Future<T?> pushToListen<T extends Object?>({Object? arguments}) => push(AppRouter.listen, arguments: arguments);
  // static Future<T?> pushToPlay<T extends Object?>({Object? arguments}) => push(AppRouter.play, arguments: arguments);
  // static Future<T?> pushToProfile<T extends Object?>({Object? arguments}) => push(AppRouter.profile, arguments: arguments);
  // static Future<T?> pushToSettings<T extends Object?>({Object? arguments}) => push(AppRouter.settings, arguments: arguments);

  // Special navigation methods
  static void logout() {
    pushNamedAndRemoveUntil(AppRouter.auth, (route) => false);
  }

  static void backToHome() {
    pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
  }

  static void loginSuccess() {
    pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
  }
}
