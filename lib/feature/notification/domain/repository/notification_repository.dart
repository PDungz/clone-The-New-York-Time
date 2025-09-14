import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:news_app/feature/notification/domain/entities/notification.dart';
import 'package:news_app/feature/notification/domain/entities/notification_category.dart';

abstract class NotificationRepository {
  /// Lấy danh sách notifications của user với comprehensive filtering
  /// [page] - Số trang (bắt đầu từ 0)
  /// [size] - Số lượng items per page (default: 20)
  /// [status] - Filter theo trạng thái: 'read', 'unread', 'all'
  /// [categoryName] - Filter theo category Name
  /// [type] - Filter theo loại: 'PUSH', 'IN_APP'
  /// [startDate] - Ngày bắt đầu (ISO format)
  /// [endDate] - Ngày kết thúc (ISO format)
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUserNotifications({
    int page = 0,
    int size = 20,
    String? status,
    String? categoryName,
    String? type,
    String? startDate,
    String? endDate,
  });

  /// Lấy danh sách notifications chưa đọc
  /// [page] - Số trang (bắt đầu từ 0)
  /// [size] - Số lượng items per page (default: 20)
  /// [categoryName] - Filter theo category Name (optional)
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUnreadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  });

  /// Lấy danh sách notifications đã đọc
  /// [page] - Số trang (bắt đầu từ 0)
  /// [size] - Số lượng items per page (default: 20)
  /// [categoryName] - Filter theo category Name (optional)
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getReadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  });

  /// Lấy notifications theo category với status cụ thể
  /// [categoryName] - ID của category
  /// [page] - Số trang (bắt đầu từ 0)
  /// [size] - Số lượng items per page (default: 20)
  /// [status] - Trạng thái: 'read', 'unread', 'all'
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getNotificationsByCategory({
    required String categoryName,
    int page = 0,
    int size = 20,
    String? status,
  });

  /// Lấy notifications theo delivery status
  /// [status] - Delivery status của notification
  /// [page] - Số trang (bắt đầu từ 0)
  /// [size] - Số lượng items per page (default: 20)
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUserNotificationsByStatus({
    required String status,
    int page = 0,
    int size = 20,
  });

  /// Đánh dấu notification đã đọc
  /// [notificationId] - ID của notification cần đánh dấu đã đọc
  Future<Either<Failure, String>> markNotificationAsRead(String notificationId);

  /// Đánh dấu tất cả notifications đã đọc
  Future<Either<Failure, String>> markAllNotificationsAsRead();

  /// Đếm số lượng notifications theo status
  /// [status] - Delivery status cần đếm
  Future<Either<Failure, int>> getNotificationCount(String status);

  /// Đếm số lượng notifications chưa đọc
  Future<Either<Failure, int>> getUnreadNotificationCount();

  /// Xóa notification
  /// [notificationId] - ID của notification cần xóa
  Future<Either<Failure, String>> deleteNotification(String notificationId);

  /// Lấy danh sách notification categories
  Future<Either<Failure, List<NotificationCategory>>> getNotificationCategories();

  /// Subscribe device vào topic
  /// [fcmToken] - FCM token của device
  /// [topic] - Tên topic cần subscribe
  Future<Either<Failure, String>> subscribeToTopic({
    required String fcmToken,
    required String topic,
  });

  /// Unsubscribe device khỏi topic
  /// [fcmToken] - FCM token của device
  /// [topic] - Tên topic cần unsubscribe
  Future<Either<Failure, String>> unsubscribeFromTopic({
    required String fcmToken,
    required String topic,
  });

  /// Validate FCM token
  /// [fcmToken] - FCM token cần validate
  Future<Either<Failure, bool>> validateFcmToken(String fcmToken);

  /// Health check cho notification service
  Future<Either<Failure, String>> healthCheck();
}
