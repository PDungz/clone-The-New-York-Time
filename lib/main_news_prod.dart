import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/config/app_prod_config.dart';
import 'package:news_app/core/global/setting/bloc/setting_cubit/setting_cubit.dart';
import 'package:news_app/core/router/app_router.dart';
import 'package:news_app/core/service/cache/maintenance_service.dart';
import 'package:news_app/core/service/device/biometric/biometric_service.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/core/service/notification/firebase_messaging_service.dart';
import 'package:news_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'env/.env.prod');
  AppConfigManagerBase.initialize(AppProdConfig());
  await initDI();
  MaintenanceService.startPeriodicMaintenance();

  // Safe Firebase initialization
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('Firebase initialized with options');
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized - continuing with existing app');
    } else {
      debugPrint('Firebase error: $e');
      rethrow;
    }
  }

  await FirebaseMessagingService.initialize();
  await FirebaseMessagingService.handleTerminatedState();
  await BiometricService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => SettingCubit())],
      child: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, settingState) {
          return MaterialApp.router(
            title: 'News',
            theme: settingState.theme.toThemeData(),
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
