import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/api/base_data/base_data_source.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:news_app/feature/notification/data/model/notification_category_model.dart';
import 'package:news_app/feature/notification/data/model/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Lấy danh sách notifications của user với comprehensive filtering
  Future<Either<Failure, BasePageModel<NotificationModel>>> getUserNotifications({
    int page = 0,
    int size = 20,
    String? status,
    String? categoryName,
    String? type,
    String? startDate,
    String? endDate,
  });

  /// Lấy danh sách notifications chưa đọc
  Future<Either<Failure, BasePageModel<NotificationModel>>> getUnreadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  });

  /// Lấy danh sách notifications đã đọc
  Future<Either<Failure, BasePageModel<NotificationModel>>> getReadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  });

  /// Lấy notifications theo category với status cụ thể
  Future<Either<Failure, BasePageModel<NotificationModel>>> getNotificationsByCategory({
    required String categoryName,
    int page = 0,
    int size = 20,
    String? status,
  });

  /// Lấy notifications theo delivery status
  Future<Either<Failure, BasePageModel<NotificationModel>>> getUserNotificationsByStatus({
    required String status,
    int page = 0,
    int size = 20,
  });

  /// Đánh dấu notification đã đọc
  Future<Either<Failure, String>> markNotificationAsRead(String notificationId);

  /// Đánh dấu tất cả notifications đã đọc
  Future<Either<Failure, String>> markAllNotificationsAsRead();

  /// Đếm số lượng notifications theo status
  Future<Either<Failure, int>> getNotificationCount(String status);

  /// Đếm số lượng notifications chưa đọc
  Future<Either<Failure, int>> getUnreadNotificationCount();

  /// Xóa notification
  Future<Either<Failure, String>> deleteNotification(String notificationId);

  /// Lấy danh sách notification categories
  Future<Either<Failure, List<NotificationCategoryModel>>> getNotificationCategories();

  /// Subscribe device vào topic
  Future<Either<Failure, String>> subscribeToTopic({
    required String fcmToken,
    required String topic,
  });

  /// Unsubscribe device khỏi topic
  Future<Either<Failure, String>> unsubscribeFromTopic({
    required String fcmToken,
    required String topic,
  });

  /// Validate FCM token
  Future<Either<Failure, bool>> validateFcmToken(String fcmToken);

  /// Health check cho notification service
  Future<Either<Failure, String>> healthCheck();
}

class NotificationRemoteDataSourceImpl extends BaseDataSource
    with PaginationMixin, FilteringMixin
    implements NotificationRemoteDataSource {
  @override
  String get context => 'NotificationDataSource';

  @override
  Future<Either<Failure, BasePageModel<NotificationModel>>> getUserNotifications({
    int page = 0,
    int size = 20,
    String? status,
    String? categoryName,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    logPagination(page, size, 'getUserNotifications');

    final queryParams = buildPaginationParams(
      page: page,
      size: size,
      additionalParams: buildFilterParams(
        status: status,
        categoryName: categoryName,
        type: type,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    logFilters(queryParams, 'getUserNotifications');

    return getPageData<NotificationModel>(
      AppConfigManagerBase.apiNotificationsUser,
      (json) => NotificationModel.fromJson(json),
      'user notifications',
      queryParams: queryParams,
      operationName: 'getUserNotifications',
    );
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationModel>>> getUnreadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  }) async {
    logPagination(page, size, 'getUnreadNotifications');

    final queryParams = buildPaginationParams(
      page: page,
      size: size,
      additionalParams: categoryName != null ? {'categoryName': categoryName} : null,
    );

    return getPageData<NotificationModel>(
      AppConfigManagerBase.apiNotificationsUserUnread,
      (json) => NotificationModel.fromJson(json),
      'unread notifications',
      queryParams: queryParams,
      operationName: 'getUnreadNotifications',
    );
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationModel>>> getReadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  }) async {
    logPagination(page, size, 'getReadNotifications');

    final queryParams = buildPaginationParams(
      page: page,
      size: size,
      additionalParams: categoryName != null ? {'categoryName': categoryName} : null,
    );

    return getPageData<NotificationModel>(
      AppConfigManagerBase.apiNotificationsUserRead,
      (json) => NotificationModel.fromJson(json),
      'read notifications',
      queryParams: queryParams,
      operationName: 'getReadNotifications',
    );
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationModel>>> getNotificationsByCategory({
    required String categoryName,
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    logPagination(page, size, 'getNotificationsByCategory');

    final queryParams = buildPaginationParams(
      page: page,
      size: size,
      additionalParams: status != null ? {'status': status} : null,
    );

    return getPageData<NotificationModel>(
      AppConfigManagerBase.apiNotificationsUserCategory(categoryName: categoryName),
      (json) => NotificationModel.fromJson(json),
      'notifications by category',
      queryParams: queryParams,
      operationName: 'getNotificationsByCategory',
    );
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationModel>>> getUserNotificationsByStatus({
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    logPagination(page, size, 'getUserNotificationsByStatus');

    final queryParams = buildPaginationParams(page: page, size: size);

    return getPageData<NotificationModel>(
      AppConfigManagerBase.apiNotificationsUserStatus(status: status),
      (json) => NotificationModel.fromJson(json),
      'notifications by status',
      queryParams: queryParams,
      operationName: 'getUserNotificationsByStatus',
    );
  }

  @override
  Future<Either<Failure, String>> markNotificationAsRead(String notificationId) async {
    return postStringData(
      AppConfigManagerBase.apiNotificationsMarkRead(notificationId: notificationId),
      'Notification marked as read successfully',
      operationName: 'markNotificationAsRead',
    );
  }

  @override
  Future<Either<Failure, String>> markAllNotificationsAsRead() async {
    return postStringData(
      AppConfigManagerBase.apiNotificationsUserReadAll,
      'All notifications marked as read successfully',
      operationName: 'markAllNotificationsAsRead',
    );
  }

  @override
  Future<Either<Failure, int>> getNotificationCount(String status) async {
    return getIntData(
      AppConfigManagerBase.apiNotificationsCountStatus(status: status),
      'notification count',
      operationName: 'getNotificationCount',
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async {
    return getIntData(
      AppConfigManagerBase.apiNotificationsCountUnread,
      'unread notification count',
      operationName: 'getUnreadNotificationCount',
    );
  }

  @override
  Future<Either<Failure, String>> deleteNotification(String notificationId) async {
    return deleteStringData(
      AppConfigManagerBase.apiNotificationsDelete(notificationId: notificationId),
      'Notification deleted successfully',
      operationName: 'deleteNotification',
    );
  }

  @override
  Future<Either<Failure, List<NotificationCategoryModel>>> getNotificationCategories() async {
    return getListData<NotificationCategoryModel>(
      AppConfigManagerBase.apiNotificationsCategories,
      (json) => NotificationCategoryModel.fromJson(json),
      'notification categories',
      operationName: 'getNotificationCategories',
    );
  }

  @override
  Future<Either<Failure, String>> subscribeToTopic({
    required String fcmToken,
    required String topic,
  }) async {
    return postStringData(
      AppConfigManagerBase.apiNotificationsTopicSubscribe,
      'Successfully subscribed to topic',
      data: {'fcmToken': fcmToken, 'topic': topic},
      operationName: 'subscribeToTopic',
    );
  }

  @override
  Future<Either<Failure, String>> unsubscribeFromTopic({
    required String fcmToken,
    required String topic,
  }) async {
    return postStringData(
      AppConfigManagerBase.apiNotificationsTopicUnsubscribe,
      'Successfully unsubscribed from topic',
      data: {'fcmToken': fcmToken, 'topic': topic},
      operationName: 'unsubscribeFromTopic',
    );
  }

  @override
  Future<Either<Failure, bool>> validateFcmToken(String fcmToken) async {
    return postBoolData(
      AppConfigManagerBase.apiNotificationsValidateToken,
      'FCM token validation',
      data: {'fcmToken': fcmToken},
      operationName: 'validateFcmToken',
    );
  }

  @override
  Future<Either<Failure, String>> healthCheck() async {
    return getStringData(
      AppConfigManagerBase.apiNotificationsHealth,
      'Notification service is healthy',
      operationName: 'healthCheck',
    );
  }
}
