// feature/notification/data/repository/notification_websocket_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/notification/data/data_source/web_socket/notification_websocket_data_source.dart';
import 'package:news_app/feature/notification/domain/entities/notification_count.dart';
import 'package:news_app/feature/notification/domain/repository/notification_websocket_repository.dart';
import 'package:packages/core/service/logger_service.dart';

class NotificationWebsocketRepositoryImpl implements NotificationWebsocketRepository {
  final NotificationWebsocketDataSource _dataSource;

  NotificationWebsocketRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, bool>> connect() async {
    return await _dataSource.connect();
  }

  @override
  Future<Either<Failure, bool>> disconnect() async {
    return await _dataSource.disconnect();
  }

  @override
  Future<Either<Failure, bool>> subscribeToNotifications({required String userId}) async {
    return await _dataSource.subscribeToNotifications(userId: userId);
  }

  @override
  Future<Either<Failure, bool>> unsubscribeFromNotifications() async {
    return await _dataSource.unsubscribeFromNotifications();
  }

  @override
  Stream<Either<Failure, NotificationCount>> get notificationCountStream {
    // Transform the data source stream to domain entities
    return _dataSource.notificationCountStream.map(
      (either) => either.fold((failure) => Left(failure), (model) {
        printS(
          '[NotificationWebsocketRepositoryImpl] Real-time notification count: ${model.toJson()}',
        );
        return Right(model.toEntity());
      }),
    );
  }

  @override
  Future<Either<Failure, bool>> sendNotification(String message) async {
    return await _dataSource.sendNotification(message);
  }

  @override
  bool get isConnected => _dataSource.isConnected;

  @override
  Stream<bool> get connectionStatusStream => _dataSource.connectionStatusStream;

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    return await _dataSource.markAllAsRead();
  }

  @override
  Future<Either<Failure, bool>> markSingleAsRead() async {
    return await _dataSource.markSingleAsRead();
  }

  @override
  NotificationCount getCurrentCount() {
    return _dataSource.getCurrentCount().toEntity();
  }

  // Additional helper methods
  Map<String, dynamic> getDebugInfo() {
    return _dataSource.getDebugInfo();
  }

  @override
  void updateWebSocketUrl(String newBaseUrl) {
    _dataSource.updateWebSocketUrl(newBaseUrl);
  }

  void dispose() {
    _dataSource.dispose();
  }
}
