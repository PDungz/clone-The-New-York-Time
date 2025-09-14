// core/di/dependency_injection.dart (Updated)
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app/core/base/api/api_service.dart';
import 'package:news_app/core/base/api/api_service_v2.dart';
import 'package:news_app/core/global/device/data/data_source/device_remote_data_source.dart';
import 'package:news_app/core/global/device/data/repository_impl/device_repository_impl.dart';
import 'package:news_app/core/global/device/domain/repository/device_repository.dart';
import 'package:news_app/core/global/device/domain/use_case/device_use_case.dart';
import 'package:news_app/core/service/cache/cache_initialization_service.dart';
import 'package:news_app/core/service/storage/shared_preference_manager.dart';
import 'package:news_app/feature/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:news_app/feature/auth/data/repository_impl/auth_repository_impl.dart';
import 'package:news_app/feature/auth/domain/repository/auth_repository.dart';
import 'package:news_app/feature/auth/domain/use_case/auth_use_case.dart';
import 'package:news_app/feature/home/data/data_source/local/top_stories_local_data_source.dart';
import 'package:news_app/feature/home/data/data_source/remote/topstories_remote_data_source.dart';
import 'package:news_app/feature/home/data/repository_impl/topstories_repository_impl.dart';
import 'package:news_app/feature/home/domain/repository/topstories_repository.dart';
import 'package:news_app/feature/home/domain/use_case/topstories_use_case.dart';
import 'package:news_app/feature/notification/data/data_source/remote/notification_data_source.dart';
import 'package:news_app/feature/notification/data/data_source/web_socket/notification_websocket_data_source.dart';
import 'package:news_app/feature/notification/data/repository_imp./notification_repository_impl.dart';
import 'package:news_app/feature/notification/data/repository_imp./notification_websocket_repository_impl.dart';
import 'package:news_app/feature/notification/domain/repository/notification_repository.dart';
import 'package:news_app/feature/notification/domain/repository/notification_websocket_repository.dart';
import 'package:news_app/feature/notification/domain/use_case/notification_use_case.dart';
import 'package:news_app/feature/notification/domain/use_case/notification_websocket_user_case.dart';
import 'package:news_app/feature/notification/presentation/bloc/notification_websocket_bloc/notification__websocket_bloc.dart';
import 'package:packages/core/network/network_info.dart';

final getIt = GetIt.instance;

Future<void> initDI() async {
  //! Registering SharedPreferenceManager
  getIt.registerSingleton<SharedPreferenceManager>(await SharedPreferenceManager.getInstance());

  //! Cache
  await CacheInitializationService.initialize();

  // Network Info
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: getIt<Connectivity>()),
  );

  //! API Service
  getIt.registerLazySingleton<ApiService>(() => ApiService.instance);
  getIt.registerLazySingleton<ApiServiceV2>(() => ApiServiceV2.instance);

  //! Data Sources

  //? Data layer Home
  getIt.registerLazySingleton<TopStoriesRemoteDataSource>(
    () => TopStoriesRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  // Local Data Sources
  getIt.registerLazySingleton<TopStoriesLocalDataSource>(() => TopStoriesLocalDataSourceImpl());

  //? Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

  //? Device
  getIt.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(apiServiceV2: getIt<ApiServiceV2>()),
  );

  //? Notification Remote Data Source
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(),
  );

  //? Notification WebSocket Data Source
  getIt.registerLazySingleton<NotificationWebsocketDataSource>(
    () => NotificationWebsocketDataSourceImpl(),
  );

  //! Repository
  //? Repository Layer Home
  getIt.registerLazySingleton<TopStoriesRepository>(
    () => TopStoriesRepositoryImpl(
      remoteDataSource: getIt<TopStoriesRemoteDataSource>(),
      localDataSource: getIt<TopStoriesLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  //? Repository Layer Auth
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: getIt()));

  //? Device Repository
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(deviceRemoteDataSource: getIt()),
  );

  //? Notification Repository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: getIt<NotificationRemoteDataSource>()),
  );

  //? Notification WebSocket Repository
  getIt.registerLazySingleton<NotificationWebsocketRepository>(
    () => NotificationWebsocketRepositoryImpl(getIt<NotificationWebsocketDataSource>()),
  );

  //! Use Case
  //? Use Case Layer Home
  getIt.registerSingleton<TopStoriesUseCase>(TopStoriesUseCase(topStoriesRepository: getIt()));

  //? Auth
  getIt.registerSingleton<AuthUseCase>(AuthUseCase(authRepository: getIt()));

  //? Device
  getIt.registerSingleton<DeviceUseCase>(DeviceUseCase(deviceRepository: getIt()));

  //? Notification Use Case
  getIt.registerSingleton<NotificationUseCase>(
    NotificationUseCase(getIt<NotificationRepository>()),
  );

  //? Notification WebSocket Use Case
  getIt.registerSingleton<NotificationWebsocketUseCase>(
    NotificationWebsocketUseCase(getIt<NotificationWebsocketRepository>()),
  );

  //! BLoC
  //? Notification BLoC - Singleton để duy trì state across app
  getIt.registerSingleton<NotificationWebSocketBloc>(NotificationWebSocketBloc());
}
