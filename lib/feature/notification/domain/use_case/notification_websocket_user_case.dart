import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/notification/domain/entities/notification_count.dart';
import 'package:news_app/feature/notification/domain/repository/notification_websocket_repository.dart';

class NotificationWebsocketUseCase {
  final NotificationWebsocketRepository _repository;

  NotificationWebsocketUseCase(this._repository);

  /// Connect to WebSocket
  Future<Either<Failure, bool>> connect() {
    return _repository.connect();
  }

  /// Disconnect from WebSocket
  Future<Either<Failure, bool>> disconnect() {
    return _repository.disconnect();
  }

  /// Subscribe to notifications for a specific user
  Future<Either<Failure, bool>> subscribeToNotifications({required String userId}) {
    return _repository.subscribeToNotifications(userId: userId);
  }

  /// Unsubscribe from notifications
  Future<Either<Failure, bool>> unsubscribeFromNotifications() {
    return _repository.unsubscribeFromNotifications();
  }

  /// Get notification count stream
  Stream<Either<Failure, NotificationCount>> getNotificationCountStream() {
    return _repository.notificationCountStream;
  }

  /// Send a notification message
  Future<Either<Failure, bool>> sendNotification(String message) {
    return _repository.sendNotification(message);
  }

  /// Get connection status
  bool get isConnected => _repository.isConnected;

  /// Get connection status stream
  Stream<bool> get connectionStatusStream => _repository.connectionStatusStream;

  /// Mark all notifications as read
  Future<Either<Failure, bool>> markAllAsRead() {
    return _repository.markAllAsRead();
  }

  /// Mark single notification as read
  Future<Either<Failure, bool>> markSingleAsRead() {
    return _repository.markSingleAsRead();
  }

  /// Get current notification count
  NotificationCount getCurrentCount() {
    return _repository.getCurrentCount();
  }

  /// Update WebSocket URL
  void updateWebSocketUrl(String newBaseUrl) {
    _repository.updateWebSocketUrl(newBaseUrl);
  }

  /// Complete workflow: Connect and subscribe
  Future<Either<Failure, bool>> connectAndSubscribe({required String userId}) async {
    // Connect first
    final connectResult = await connect();

    return connectResult.fold((failure) => Left(failure), (_) async {
      // If connected successfully, subscribe
      return await subscribeToNotifications(userId: userId);
    });
  }

  /// Complete workflow: Unsubscribe and disconnect
  Future<Either<Failure, bool>> unsubscribeAndDisconnect() async {
    // Unsubscribe first
    final unsubscribeResult = await unsubscribeFromNotifications();

    // Always try to disconnect, regardless of unsubscribe result
    final disconnectResult = await disconnect();

    // Return the first error encountered, or success if both succeed
    return unsubscribeResult.fold((failure) => Left(failure), (_) => disconnectResult);
  }
}
