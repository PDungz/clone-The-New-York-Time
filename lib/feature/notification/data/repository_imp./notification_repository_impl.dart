import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:news_app/feature/notification/data/data_source/remote/notification_data_source.dart';
import 'package:news_app/feature/notification/domain/entities/notification.dart';
import 'package:news_app/feature/notification/domain/entities/notification_category.dart';
import 'package:news_app/feature/notification/domain/repository/notification_repository.dart';
import 'package:packages/core/service/logger_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  static const String _context = 'NotificationRepository';

  const NotificationRepositoryImpl({required NotificationRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUserNotifications({
    int page = 0,
    int size = 20,
    String? status,
    String? categoryName,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    try {
      printI('[$_context] Getting user notifications - page: $page, size: $size');

      final result = await _remoteDataSource.getUserNotifications(
        page: page,
        size: size,
        status: status,
        categoryName: categoryName,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get user notifications: ${failure.message}');
          return Left(failure);
        },
        (pageModel) {
          // Convert NotificationModel to Notification entity
          final notifications = pageModel.content.map((model) => model.toEntity()).toList();

          // Create new BasePageModel<Notification> instead of copyWith
          final entityPageModel = BasePageModel<NotificationEntity>(
            content: notifications,
            totalElements: pageModel.totalElements,
            totalPages: pageModel.totalPages,
            size: pageModel.size,
            number: pageModel.number,
            last: pageModel.last,
            first: pageModel.first,
            numberOfElements: pageModel.numberOfElements,
            empty: pageModel.empty,
          );

          printI('[$_context] Successfully got ${notifications.length} user notifications');
          return Right(entityPageModel);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getUserNotifications: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUnreadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  }) async {
    try {
      printI('[$_context] Getting unread notifications - page: $page, size: $size');

      final result = await _remoteDataSource.getUnreadNotifications(
        page: page,
        size: size,
        categoryName: categoryName,
      );

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get unread notifications: ${failure.message}');
          return Left(failure);
        },
        (pageModel) {
          final notifications = pageModel.content.map((model) => model.toEntity()).toList();

          // Sử dụng helper method
          final entityPageModel = _convertToEntityPageModel(pageModel);

          printI('[$_context] Successfully got ${notifications.length} unread notifications');
          return Right(entityPageModel);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getUnreadNotifications: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getReadNotifications({
    int page = 0,
    int size = 20,
    String? categoryName,
  }) async {
    try {
      printI('[$_context] Getting read notifications - page: $page, size: $size');

      final result = await _remoteDataSource.getReadNotifications(
        page: page,
        size: size,
        categoryName: categoryName,
      );

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get read notifications: ${failure.message}');
          return Left(failure);
        },
        (pageModel) {
          final notifications = pageModel.content.map((model) => model.toEntity()).toList();

          // Sử dụng helper method
          final entityPageModel = _convertToEntityPageModel(pageModel);

          printI('[$_context] Successfully got ${notifications.length} read notifications');
          return Right(entityPageModel);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getReadNotifications: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getNotificationsByCategory({
    required String categoryName,
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      printI('[$_context] Getting notifications by category: $categoryName');

      final result = await _remoteDataSource.getNotificationsByCategory(
        categoryName: categoryName,
        page: page,
        size: size,
        status: status,
      );

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get notifications by category: ${failure.message}');
          return Left(failure);
        },
        (pageModel) {
          final notifications = pageModel.content.map((model) => model.toEntity()).toList();

          // Sử dụng helper method
          final entityPageModel = _convertToEntityPageModel(pageModel);

          printI('[$_context] Successfully got ${notifications.length} notifications by category');
          return Right(entityPageModel);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getNotificationsByCategory: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BasePageModel<NotificationEntity>>> getUserNotificationsByStatus({
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      printI('[$_context] Getting notifications by status: $status');

      final result = await _remoteDataSource.getUserNotificationsByStatus(
        status: status,
        page: page,
        size: size,
      );

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get notifications by status: ${failure.message}');
          return Left(failure);
        },
        (pageModel) {
          final notifications = pageModel.content.map((model) => model.toEntity()).toList();

          // Sử dụng helper method
          final entityPageModel = _convertToEntityPageModel(pageModel);

          printI('[$_context] Successfully got ${notifications.length} notifications by status');
          return Right(entityPageModel);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getUserNotificationsByStatus: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> markNotificationAsRead(String notificationId) async {
    try {
      printI('[$_context] Marking notification as read: $notificationId');

      final result = await _remoteDataSource.markNotificationAsRead(notificationId);

      return result.fold(
        (failure) {
          printE('[$_context] Failed to mark notification as read: ${failure.message}');
          return Left(failure);
        },
        (message) {
          printI('[$_context] Successfully marked notification as read');
          return Right(message);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in markNotificationAsRead: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> markAllNotificationsAsRead() async {
    try {
      printI('[$_context] Marking all notifications as read');

      final result = await _remoteDataSource.markAllNotificationsAsRead();

      return result.fold(
        (failure) {
          printE('[$_context] Failed to mark all notifications as read: ${failure.message}');
          return Left(failure);
        },
        (message) {
          printI('[$_context] Successfully marked all notifications as read');
          return Right(message);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in markAllNotificationsAsRead: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getNotificationCount(String status) async {
    try {
      printI('[$_context] Getting notification count for status: $status');

      final result = await _remoteDataSource.getNotificationCount(status);

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get notification count: ${failure.message}');
          return Left(failure);
        },
        (count) {
          printI('[$_context] Successfully got notification count: $count');
          return Right(count);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getNotificationCount: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount() async {
    try {
      printI('[$_context] Getting unread notification count');

      final result = await _remoteDataSource.getUnreadNotificationCount();

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get unread notification count: ${failure.message}');
          return Left(failure);
        },
        (count) {
          printI('[$_context] Successfully got unread notification count: $count');
          return Right(count);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getUnreadNotificationCount: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteNotification(String notificationId) async {
    try {
      printI('[$_context] Deleting notification: $notificationId');

      final result = await _remoteDataSource.deleteNotification(notificationId);

      return result.fold(
        (failure) {
          printE('[$_context] Failed to delete notification: ${failure.message}');
          return Left(failure);
        },
        (message) {
          printI('[$_context] Successfully deleted notification');
          return Right(message);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in deleteNotification: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotificationCategory>>> getNotificationCategories() async {
    try {
      printI('[$_context] Getting notification categories');

      final result = await _remoteDataSource.getNotificationCategories();

      return result.fold(
        (failure) {
          printE('[$_context] Failed to get notification categories: ${failure.message}');
          return Left(failure);
        },
        (categoryModels) {
          // Convert NotificationCategoryModel to NotificationCategory entity
          final categories = categoryModels.map((model) => model.toEntity()).toList();

          printI('[$_context] Successfully got ${categories.length} notification categories');
          return Right(categories);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in getNotificationCategories: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> subscribeToTopic({
    required String fcmToken,
    required String topic,
  }) async {
    try {
      printI('[$_context] Subscribing to topic: $topic');

      final result = await _remoteDataSource.subscribeToTopic(fcmToken: fcmToken, topic: topic);

      return result.fold(
        (failure) {
          printE('[$_context] Failed to subscribe to topic: ${failure.message}');
          return Left(failure);
        },
        (message) {
          printI('[$_context] Successfully subscribed to topic');
          return Right(message);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in subscribeToTopic: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> unsubscribeFromTopic({
    required String fcmToken,
    required String topic,
  }) async {
    try {
      printI('[$_context] Unsubscribing from topic: $topic');

      final result = await _remoteDataSource.unsubscribeFromTopic(fcmToken: fcmToken, topic: topic);

      return result.fold(
        (failure) {
          printE('[$_context] Failed to unsubscribe from topic: ${failure.message}');
          return Left(failure);
        },
        (message) {
          printI('[$_context] Successfully unsubscribed from topic');
          return Right(message);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in unsubscribeFromTopic: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateFcmToken(String fcmToken) async {
    try {
      printI('[$_context] Validating FCM token');

      final result = await _remoteDataSource.validateFcmToken(fcmToken);

      return result.fold(
        (failure) {
          printE('[$_context] Failed to validate FCM token: ${failure.message}');
          return Left(failure);
        },
        (isValid) {
          printI('[$_context] FCM token validation result: $isValid');
          return Right(isValid);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in validateFcmToken: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> healthCheck() async {
    try {
      printI('[$_context] Performing health check');

      final result = await _remoteDataSource.healthCheck();

      return result.fold(
        (failure) {
          printE('[$_context] Health check failed: ${failure.message}');
          return Left(failure);
        },
        (message) {
          printI('[$_context] Health check successful');
          return Right(message);
        },
      );
    } catch (e) {
      printE('[$_context] Unexpected exception in healthCheck: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===============================
  // HELPER METHODS
  // ===============================

  /// Helper method để convert BasePageModel<NotificationModel> sang BasePageModel<Notification>
  BasePageModel<NotificationEntity> _convertToEntityPageModel(BasePageModel<dynamic> pageModel) {
    final notifications =
        pageModel.content.map((model) => (model as dynamic).toEntity() as NotificationEntity).toList();

    return BasePageModel<NotificationEntity>(
      content: notifications,
      totalElements: pageModel.totalElements,
      totalPages: pageModel.totalPages,
      size: pageModel.size,
      number: pageModel.number,
      last: pageModel.last,
      first: pageModel.first,
      numberOfElements: pageModel.numberOfElements,
      empty: pageModel.empty,
    );
  }
}
