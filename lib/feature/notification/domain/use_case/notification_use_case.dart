import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:news_app/feature/notification/domain/entities/notification.dart';
import 'package:news_app/feature/notification/domain/entities/notification_category.dart';
import 'package:news_app/feature/notification/domain/repository/notification_repository.dart';

class NotificationUseCase {
  final NotificationRepository _repository;

  NotificationUseCase(this._repository);

  /// Lấy danh sách notifications của user với comprehensive filtering
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUserNotifications({
    int page = 0,
    int size = 20,
    String? status,
    String? categoryName,
    String? type,
    String? startDate,
    String? endDate,
  }) {
    return _repository.getUserNotifications(
      page: page,
      size: size,
      status: status,
      categoryName: categoryName,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Lấy danh sách notifications chưa đọc
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUnreadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  }) {
    return _repository.getUnreadNotifications(page: page, size: size, categoryName: categoryName);
  }

  /// Lấy danh sách notifications đã đọc
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getReadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  }) {
    return _repository.getReadNotifications(page: page, size: size, categoryName: categoryName);
  }

  /// Lấy notifications theo category với status cụ thể
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getNotificationsByCategory({
    required String categoryName,
    int page = 0,
    int size = 20,
    String? status,
  }) {
    return _repository.getNotificationsByCategory(
      categoryName: categoryName,
      page: page,
      size: size,
      status: status,
    );
  }

  /// Lấy notifications theo delivery status
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUserNotificationsByStatus({
    required String status,
    int page = 0,
    int size = 20,
  }) {
    return _repository.getUserNotificationsByStatus(status: status, page: page, size: size);
  }

  /// Đánh dấu notification đã đọc
  Future<Either<Failure, String>> markNotificationAsRead(String notificationId) {
    return _repository.markNotificationAsRead(notificationId);
  }

  /// Đánh dấu tất cả notifications đã đọc
  Future<Either<Failure, String>> markAllNotificationsAsRead() {
    return _repository.markAllNotificationsAsRead();
  }

  /// Đếm số lượng notifications theo status
  Future<Either<Failure, int>> getNotificationCount(String status) {
    return _repository.getNotificationCount(status);
  }

  /// Đếm số lượng notifications chưa đọc
  Future<Either<Failure, int>> getUnreadNotificationCount() {
    return _repository.getUnreadNotificationCount();
  }

  /// Xóa notification
  Future<Either<Failure, String>> deleteNotification(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }

  /// Lấy danh sách notification categories
  Future<Either<Failure, List<NotificationCategory>>> getNotificationCategories() {
    return _repository.getNotificationCategories();
  }

  /// Subscribe device vào topic
  Future<Either<Failure, String>> subscribeToTopic({
    required String fcmToken,
    required String topic,
  }) {
    return _repository.subscribeToTopic(fcmToken: fcmToken, topic: topic);
  }

  /// Unsubscribe device khỏi topic
  Future<Either<Failure, String>> unsubscribeFromTopic({
    required String fcmToken,
    required String topic,
  }) {
    return _repository.unsubscribeFromTopic(fcmToken: fcmToken, topic: topic);
  }

  /// Validate FCM token
  Future<Either<Failure, bool>> validateFcmToken(String fcmToken) {
    return _repository.validateFcmToken(fcmToken);
  }

  /// Health check cho notification service
  Future<Either<Failure, String>> healthCheck() {
    return _repository.healthCheck();
  }
}
