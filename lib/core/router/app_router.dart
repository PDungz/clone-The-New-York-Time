import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/feature/auth/presentation/pages/auth_page.dart';
import 'package:news_app/feature/auth/presentation/pages/login_page.dart';
import 'package:news_app/feature/entry_point/presentation/pages/entry_point_page.dart';
import 'package:news_app/feature/home/presentation/pages/home_page.dart';
import 'package:news_app/feature/listen/presentation/pages/listen_page.dart';
import 'package:news_app/feature/news/presentation/pages/news_page.dart';
import 'package:news_app/feature/notification/presentation/pages/notification_page.dart';
import 'package:news_app/feature/play/presentation/pages/play_page.dart';
import 'package:news_app/feature/profile/presentation/pages/profile_pages.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_biometric_page.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_data_usage_page.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_device_manager.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_display_page.dart';
import 'package:news_app/feature/setting/presentation/pages/setting_page.dart';
import 'package:news_app/feature/splash/splash_page.dart';

class AppRouter {
  AppRouter._();

  //! Route paths
  static const String splash = '/';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String entryPoint = '/entry_point';
  static const String home = '/home';
  static const String news = '/news';
  static const String notification = '/notification';
  static const String listen = '/listen';
  static const String play = '/play';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String settingDisplaySettings = '/settings/display_setting';
  static const String settingDeviceManager = '/settings/device_manager';
  static const String settingDataUsage = '/settings/data_usage';
  static const String settingBiometric = '/settings/biometric';

  //! GoRouter instance
  static final GoRouter _router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true, // Bật để debug trong development
    routes: [
      // Splash route
      GoRoute(path: splash, name: 'splash', builder: (context, state) => const SplashPage()),

      // Auth routes
      GoRoute(
        path: auth,
        name: 'auth',
        builder: (context, state) => const AuthPage(),
        routes: [GoRoute(path: '/login', name: 'login', builder: (context, state) => LoginPage())],
      ),

      // Entry point route
      GoRoute(
        path: entryPoint,
        name: 'entryPoint',
        builder: (context, state) => const EntryPointPage(),
      ),

      // Main app routes
      GoRoute(path: home, name: 'home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: notification,
        name: 'notification',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(path: news, name: 'news', builder: (context, state) => const NewsPage()),
      GoRoute(path: listen, name: 'listen', builder: (context, state) => const ListenPage()),
      GoRoute(path: play, name: 'play', builder: (context, state) => const PlayPage()),
      GoRoute(path: profile, name: 'profile', builder: (context, state) => const ProfilePages()),

      // Settings routes
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingPage(),
        routes: [
          GoRoute(
            path: '/display_setting',
            name: 'settingDisplaySettings',
            builder: (context, state) => const SettingDisplayPage(),
          ),
          GoRoute(
            path: '/device_manager',
            name: 'settingDeviceManager',
            builder: (context, state) => const SettingDeviceManager(),
          ),
          GoRoute(
            path: '/data_usage',
            name: 'settingDataUsage',
            builder: (context, state) => const SettingDataUsagePage(),
          ),
          GoRoute(
            path: '/biometric',
            name: 'settingBiometric',
            builder: (context, state) => const SettingBiometricPage(),
          ),
        ],
      ),
    ],

    //! Error handling
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Page Not Found', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'No route defined for ${state.uri}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => context.go(home), child: const Text('Go Home')),
              ],
            ),
          ),
        ),
  );

  static GoRouter get router => _router;
}
