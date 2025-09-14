# Flutter Architecture Template

## Architectural Patterns

### Clean Architecture (Recommended)

Clean Architecture chia ứng dụng thành các lớp độc lập, tuân theo Dependency Rule: các lớp bên trong không phụ thuộc vào các lớp bên ngoài.

```
lib/
├── core/                           # Shared infrastructure & utilities
├── features/                       # Feature-based modules
│   └── [feature_name]/
│       ├── data/                   # Data Layer
│       ├── domain/                 # Domain Layer  
│       └── presentation/           # Presentation Layer
└── shared/                         # Shared components
```

#### Layer Responsibilities

**1. Presentation Layer (`presentation/`)**
```
presentation/
├── bloc/                          # State management (BLoC/Cubit)
├── pages/                         # UI screens
├── widgets/                       # Feature-specific widgets
└── controllers/                   # Controllers (if using GetX/Riverpod)
```

**2. Domain Layer (`domain/`)**
```
domain/
├── entities/                      # Business entities (pure Dart objects)
├── repositories/                  # Repository abstractions
├── usecases/                      # Business logic use cases
├── enums/                         # Domain enums
└── extensions/                    # Domain-specific extensions
```

**3. Data Layer (`data/`)**
```
data/
├── datasources/
│   ├── local/                     # Local data (Hive, SQLite, SharedPreferences)
│   └── remote/                    # API calls, external services
├── models/                        # Data models with JSON serialization
├── repositories/                  # Repository implementations
└── mappers/                       # Entity <-> Model converters
```

## State Management Options

### 1. BLoC/Cubit Pattern (Recommended)

**Structure:**
```
bloc/
├── [feature]_bloc.dart           # Business logic component
├── [feature]_event.dart          # Events
├── [feature]_state.dart          # States
└── [feature]_cubit.dart          # Simple state management (alternative)
```

**Implementation Template:**
```dart
// Events
abstract class FeatureEvent extends Equatable {
  const FeatureEvent();
  @override
  List<Object> get props => [];
}

class LoadData extends FeatureEvent {}
class RefreshData extends FeatureEvent {}

// States
abstract class FeatureState extends Equatable {
  const FeatureState();
  @override
  List<Object> get props => [];
}

class FeatureInitial extends FeatureState {}
class FeatureLoading extends FeatureState {}
class FeatureLoaded extends FeatureState {
  final List<Entity> data;
  const FeatureLoaded(this.data);
  @override
  List<Object> get props => [data];
}
class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final UseCase useCase;
  
  FeatureBloc({required this.useCase}) : super(FeatureInitial()) {
    on<LoadData>(_onLoadData);
    on<RefreshData>(_onRefreshData);
  }
  
  Future<void> _onLoadData(LoadData event, Emitter<FeatureState> emit) async {
    emit(FeatureLoading());
    try {
      final result = await useCase.execute();
      emit(FeatureLoaded(result));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}
```

### 2. Riverpod (Alternative)

**Structure:**
```
providers/
├── [feature]_provider.dart       # State providers
├── [feature]_notifier.dart       # StateNotifier classes
└── [feature]_repository_provider.dart # Repository providers
```

### 3. GetX (Alternative)

**Structure:**
```
controllers/
├── [feature]_controller.dart     # GetX controller
└── [feature]_binding.dart        # Dependency binding
```

## Dependency Injection

### Using GetIt (Recommended)

**Structure:**
```
core/
└── di/
    ├── injection_container.dart   # Main DI setup
    ├── data_di.dart              # Data layer dependencies  
    ├── domain_di.dart            # Domain layer dependencies
    └── presentation_di.dart      # Presentation layer dependencies
```

**Implementation Template:**
```dart
// injection_container.dart
final GetIt getIt = GetIt.instance;

Future<void> setupDI() async {
  // External dependencies
  await _setupExternalDependencies();
  
  // Core dependencies  
  await _setupCoreDependencies();
  
  // Feature dependencies
  await _setupFeatureDependencies();
}

Future<void> _setupExternalDependencies() async {
  // HTTP client
  getIt.registerLazySingleton<Dio>(() => Dio());
  
  // Local storage
  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  
  // Database
  getIt.registerLazySingleton<Database>(() => DatabaseImpl());
}

Future<void> _setupFeatureDependencies() async {
  // Data sources
  getIt.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<Repository>(
    () => RepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton<UseCase>(
    () => UseCase(repository: getIt()),
  );
  
  // BLoCs
  getIt.registerFactory<FeatureBloc>(
    () => FeatureBloc(useCase: getIt()),
  );
}
```

## Navigation

### Using GoRouter (Recommended)

**Structure:**
```
core/
└── router/
    ├── app_router.dart           # Main router configuration
    ├── route_names.dart          # Route name constants
    └── route_guards.dart         # Authentication guards
```

**Implementation Template:**
```dart
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/feature/:id',
        name: 'feature',
        builder: (context, state) => FeaturePage(
          id: state.pathParameters['id']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Nested routes
        ],
      ),
    ],
    redirect: (context, state) {
      // Authentication logic
      final isLoggedIn = AuthService.isLoggedIn;
      if (!isLoggedIn && state.location != '/login') {
        return '/login';
      }
      return null;
    },
  );
  
  static GoRouter get router => _router;
}
```

## Core Infrastructure

### API Service

**Structure:**
```
core/
└── network/
    ├── api_service.dart          # Main API client
    ├── interceptors/
    │   ├── auth_interceptor.dart
    │   ├── logging_interceptor.dart
    │   └── retry_interceptor.dart
    ├── models/
    │   ├── api_response.dart
    │   └── api_error.dart
    └── exceptions/
        └── network_exceptions.dart
```

**Implementation Template:**
```dart
class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(),
      RetryInterceptor(),
      ErrorInterceptor(),
    ]);
  }
  
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
  
  T _handleResponse<T>(Response response) {
    if (response.statusCode == 200) {
      return response.data;
    }
    throw NetworkException(
      message: 'Request failed with status: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }
}
```

### Error Handling

**Structure:**
```
core/
└── error/
    ├── failures.dart             # Abstract failure classes
    ├── exceptions.dart           # Concrete exceptions
    └── error_handler.dart        # Global error handling
```

**Implementation Template:**
```dart
// failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// exceptions.dart
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException({
    required this.message,
    this.statusCode,
  });
  
  static NetworkException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(message: 'Connection timeout');
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Receive timeout');
      case DioExceptionType.badResponse:
        return NetworkException(
          message: 'Server error',
          statusCode: error.response?.statusCode,
        );
      default:
        return NetworkException(message: 'Network error occurred');
    }
  }
}
```

## Data Management

### Local Storage Options

**1. Hive (Recommended for complex data)**
```dart
// Model with Hive annotations
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String name;
  
  @HiveField(2)
  late String email;
}

// Repository implementation
class UserLocalDataSource {
  static const String _boxName = 'users';
  
  Future<Box<UserModel>> get _box async =>
      await Hive.openBox<UserModel>(_boxName);
  
  Future<void> cacheUser(UserModel user) async {
    final box = await _box;
    await box.put(user.id, user);
  }
  
  Future<UserModel?> getUser(String id) async {
    final box = await _box;
    return box.get(id);
  }
}
```

**2. SharedPreferences (Simple key-value)**
```dart
class PreferencesService {
  static const String _tokenKey = 'auth_token';
  static const String _themeKey = 'app_theme';
  
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
```

**3. SQLite with Sqflite (Relational data)**
```dart
class DatabaseHelper {
  static const String _dbName = 'app_database.db';
  static const int _dbVersion = 1;
  
  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }
}
```

## Testing Strategy

### Test Structure
```
test/
├── unit/                         # Unit tests
│   ├── core/
│   └── features/
├── widget/                       # Widget tests
└── integration/                  # Integration tests
    └── test/
```

### Unit Test Template
```dart
// Domain layer test
class MockRepository extends Mock implements Repository {}

void main() {
  late UseCase useCase;
  late MockRepository mockRepository;
  
  setUp(() {
    mockRepository = MockRepository();
    useCase = UseCase(repository: mockRepository);
  });
  
  group('UseCase', () {
    test('should return data when repository call is successful', () async {
      // Arrange
      final testData = [Entity(id: '1', name: 'Test')];
      when(() => mockRepository.getData())
          .thenAnswer((_) async => Right(testData));
      
      // Act
      final result = await useCase.execute();
      
      // Assert
      expect(result, Right(testData));
      verify(() => mockRepository.getData()).called(1);
    });
  });
}
```

### Widget Test Template
```dart
void main() {
  testWidgets('should display loading indicator when loading', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FeatureBloc>(
          create: (_) => FeatureBloc()..add(LoadData()),
          child: const FeaturePage(),
        ),
      ),
    );
    
    // Act & Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

## Configuration Management

### Environment Configuration
```
lib/
└── config/
    ├── app_config.dart           # Base configuration
    ├── dev_config.dart          # Development settings
    ├── staging_config.dart      # Staging settings
    └── prod_config.dart         # Production settings
```

**Implementation:**
```dart
abstract class AppConfig {
  String get baseUrl;
  String get apiKey;
  bool get enableLogging;
  Duration get cacheTimeout;
}

class DevConfig implements AppConfig {
  @override
  String get baseUrl => 'https://api-dev.example.com';
  
  @override
  String get apiKey => 'dev_api_key';
  
  @override
  bool get enableLogging => true;
  
  @override
  Duration get cacheTimeout => const Duration(minutes: 5);
}

class ProdConfig implements AppConfig {
  @override
  String get baseUrl => 'https://api.example.com';
  
  @override
  String get apiKey => dotenv.env['API_KEY'] ?? '';
  
  @override
  bool get enableLogging => false;
  
  @override
  Duration get cacheTimeout => const Duration(hours: 1);
}
```

## Build Configuration

### Multi-flavor Setup

**Android (`android/app/build.gradle`):**
```gradle
android {
    flavorDimensions "default"
    
    productFlavors {
        dev {
            dimension "default"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "App Dev"
        }
        
        staging {
            dimension "default"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "App Staging"
        }
        
        prod {
            dimension "default"
            resValue "string", "app_name", "App"
        }
    }
}
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>CFBundleName</key>
<string>$(PRODUCT_NAME)</string>
```

### Entry Points
```dart
// main_dev.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.dev');
  ConfigManager.initialize(DevConfig());
  await setupDI();
  runApp(MyApp());
}

// main_prod.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.prod');
  ConfigManager.initialize(ProdConfig());
  await setupDI();
  runApp(MyApp());
}
```

## Performance Optimization

### Image Optimization
```dart
// Optimized image widget
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => const ShimmerLoading(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}
```

### List Optimization
```dart
class OptimizedList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const OptimizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.physics,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (context, index) => itemBuilder(context, items[index]),
    );
  }
}
```

## Security Best Practices

### 1. Secure Storage
```dart
class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  static Future<void> store(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
}
```

### 2. Network Security
```dart
class NetworkSecurity {
  static Dio createSecureDio() {
    final dio = Dio();
    
    // Certificate pinning
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) {
        // Implement certificate validation
        return _validateCertificate(cert, host);
      };
      return client;
    };
    
    return dio;
  }
  
  static bool _validateCertificate(cert, String host) {
    // Certificate validation logic
    return true;
  }
}
```

## Monitoring & Analytics

### Logging
```dart
class Logger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (Config.enableLogging) {
      log(message, error: error, stackTrace: stackTrace, level: Level.DEBUG);
    }
  }
  
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    log(message, error: error, stackTrace: stackTrace, level: Level.SEVERE);
    
    // Send to crash reporting service
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
```

### Analytics
```dart
class AnalyticsService {
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  static Future<void> setUserId(String userId) async {
    await FirebaseAnalytics.instance.setUserId(id: userId);
  }
  
  static Future<void> logScreenView(String screenName) async {
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }
}
```

## Code Generation

### Build Runner Configuration
```yaml
# pubspec.yaml
dev_dependencies:
  build_runner: ^2.4.15
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  freezed: ^2.4.7
```

### Commands
```bash
# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter packages pub run build_runner watch
```

## Best Practices Checklist

### Architecture
- [ ] Follow Clean Architecture principles
- [ ] Implement proper separation of concerns
- [ ] Use dependency injection
- [ ] Apply SOLID principles

### State Management
- [ ] Use consistent state management pattern
- [ ] Implement proper error handling
- [ ] Handle loading states appropriately
- [ ] Dispose resources properly

### Performance
- [ ] Optimize images and assets
- [ ] Use lazy loading for lists
- [ ] Implement proper caching
- [ ] Profile and optimize critical paths

### Security
- [ ] Use secure storage for sensitive data
- [ ] Implement certificate pinning
- [ ] Validate all inputs
- [ ] Never hardcode secrets

### Testing
- [ ] Write unit tests for business logic
- [ ] Create widget tests for UI components
- [ ] Implement integration tests for critical flows
- [ ] Maintain good test coverage

### Code Quality
- [ ] Follow consistent naming conventions
- [ ] Use meaningful variable names
- [ ] Write self-documenting code
- [ ] Implement proper error handling

---

**Note**: Template này cung cấp foundation cho mọi Flutter project. Tùy vào requirements cụ thể, có thể customize và mở rộng theo nhu cầu dự án.