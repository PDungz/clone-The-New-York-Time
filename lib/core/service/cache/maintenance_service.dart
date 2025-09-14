import 'dart:async';

import 'package:news_app/core/service/cache/cache_initialization_service.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/feature/home/data/data_source/local/top_stories_local_data_source.dart';

class MaintenanceService {
  static Timer? _maintenanceTimer;
  static const Duration _maintenanceInterval = Duration(hours: 6);

  static void startPeriodicMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = Timer.periodic(_maintenanceInterval, (timer) {
      _performMaintenance();
    });
  }

  static void stopMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = null;
  }

  static Future<void> _performMaintenance() async {
    try {
      print('[Maintenance] Starting periodic maintenance...');

      // Global cache cleanup
      await CacheInitializationService.performMaintenance();

      // Module-specific maintenance
      final localDataSource = getIt<TopStoriesLocalDataSource>();
      if (localDataSource is TopStoriesLocalDataSourceImpl) {
        await localDataSource.performMaintenance();
      }

      print('[Maintenance] Periodic maintenance completed');
    } catch (e) {
      print('[Maintenance] Periodic maintenance failed: $e');
    }
  }

  static Future<void> performManualMaintenance() async {
    await _performMaintenance();
  }
}
