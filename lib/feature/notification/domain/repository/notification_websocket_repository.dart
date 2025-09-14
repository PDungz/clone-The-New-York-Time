import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/feature/notification/domain/entities/notification_count.dart';

abstract class NotificationWebsocketRepository {
  Future<Either<Failure, bool>> connect();

  Future<Either<Failure, bool>> disconnect();

  Future<Either<Failure, bool>> subscribeToNotifications({required String userId});

  Future<Either<Failure, bool>> unsubscribeFromNotifications();

  Stream<Either<Failure, NotificationCount>> get notificationCountStream;

  Future<Either<Failure, bool>> sendNotification(String message);

  // Additional methods for enhanced functionality
  bool get isConnected;
  
  Stream<bool> get connectionStatusStream;
  
  Future<Either<Failure, bool>> markAllAsRead();
  
  Future<Either<Failure, bool>> markSingleAsRead();
  
  NotificationCount getCurrentCount();
  
  void updateWebSocketUrl(String newBaseUrl);
}