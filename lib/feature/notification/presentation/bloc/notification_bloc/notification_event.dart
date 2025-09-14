part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

// ===============================
// QUERY EVENTS
// ===============================

/// Lấy danh sách notifications với filtering
final class GetUserNotificationsEvent extends NotificationEvent {
  final int page;
  final int size;
  final String? status;
  final String? categoryName;
  final String? type;
  final String? startDate;
  final String? endDate;
  final bool isRefresh;

  const GetUserNotificationsEvent({
    this.page = 0,
    this.size = 20,
    this.status,
    this.categoryName,
    this.type,
    this.startDate,
    this.endDate,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, size, status, categoryName, type, startDate, endDate, isRefresh];
}

/// Lấy notifications chưa đọc
final class GetUnreadNotificationsEvent extends NotificationEvent {
  final int page;
  final int size;
  final String? categoryName;
  final bool isRefresh;

  const GetUnreadNotificationsEvent({
    this.page = 0,
    this.size = 20,
    this.categoryName,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, size, categoryName, isRefresh];
}

/// Lấy notifications đã đọc
final class GetReadNotificationsEvent extends NotificationEvent {
  final int page;
  final int size;
  final String? categoryName;
  final bool isRefresh;

  const GetReadNotificationsEvent({
    this.page = 0,
    this.size = 20,
    this.categoryName,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, size, categoryName, isRefresh];
}

/// Lấy notifications theo category
final class GetNotificationsByCategoryEvent extends NotificationEvent {
  final String categoryName;
  final int page;
  final int size;
  final String? status;
  final bool isRefresh;

  const GetNotificationsByCategoryEvent({
    required this.categoryName,
    this.page = 0,
    this.size = 20,
    this.status,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [categoryName, page, size, status, isRefresh];
}

/// Lấy thống kê notifications
final class GetNotificationStatisticsEvent extends NotificationEvent {
  const GetNotificationStatisticsEvent();
}

// ===============================
// COMMAND EVENTS
// ===============================

/// Đánh dấu notification đã đọc
final class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Đánh dấu tất cả notifications đã đọc
final class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}

/// Xóa notification
final class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Batch mark notifications as read
final class BatchMarkAsReadEvent extends NotificationEvent {
  final List<String> notificationIds;

  const BatchMarkAsReadEvent({required this.notificationIds});

  @override
  List<Object?> get props => [notificationIds];
}

/// Batch delete notifications
final class BatchDeleteNotificationsEvent extends NotificationEvent {
  final List<String> notificationIds;

  const BatchDeleteNotificationsEvent({required this.notificationIds});

  @override
  List<Object?> get props => [notificationIds];
}

// ===============================
// CATEGORY EVENTS
// ===============================

/// Lấy danh sách categories
final class GetNotificationCategoriesEvent extends NotificationEvent {
  const GetNotificationCategoriesEvent();
}

// ===============================
// TOPIC MANAGEMENT EVENTS
// ===============================

/// Subscribe vào topic
final class SubscribeToTopicEvent extends NotificationEvent {
  final String fcmToken;
  final String topic;

  const SubscribeToTopicEvent({required this.fcmToken, required this.topic});

  @override
  List<Object?> get props => [fcmToken, topic];
}

/// Unsubscribe khỏi topic
final class UnsubscribeFromTopicEvent extends NotificationEvent {
  final String fcmToken;
  final String topic;

  const UnsubscribeFromTopicEvent({required this.fcmToken, required this.topic});

  @override
  List<Object?> get props => [fcmToken, topic];
}

// ===============================
// UTILITY EVENTS
// ===============================

/// Refresh notifications
final class RefreshNotificationsEvent extends NotificationEvent {
  const RefreshNotificationsEvent();
}

/// Load more notifications (pagination)
final class LoadMoreNotificationsEvent extends NotificationEvent {
  const LoadMoreNotificationsEvent();
}

/// Filter notifications
final class FilterNotificationsEvent extends NotificationEvent {
  final String? status;
  final String? categoryName;
  final String? type;

  const FilterNotificationsEvent({this.status, this.categoryName, this.type});

  @override
  List<Object?> get props => [status, categoryName, type];
}

/// Search notifications
final class SearchNotificationsEvent extends NotificationEvent {
  final String query;

  const SearchNotificationsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear all notifications
final class ClearAllNotificationsEvent extends NotificationEvent {
  const ClearAllNotificationsEvent();
}

/// Reset notification state
final class ResetNotificationStateEvent extends NotificationEvent {
  const ResetNotificationStateEvent();
}
