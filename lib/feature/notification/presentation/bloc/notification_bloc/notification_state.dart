part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class NotificationInitial extends NotificationState {}

/// Loading states
final class NotificationLoading extends NotificationState {}

final class NotificationLoadingMore extends NotificationState {
  final List<NotificationEntity> currentNotifications;

  const NotificationLoadingMore({required this.currentNotifications});

  @override
  List<Object?> get props => [currentNotifications];
}

final class NotificationRefreshing extends NotificationState {
  final List<NotificationEntity> currentNotifications;

  const NotificationRefreshing({required this.currentNotifications});

  @override
  List<Object?> get props => [currentNotifications];
}

/// Success states
final class NotificationLoaded extends NotificationState {
  final BasePageModel<NotificationEntity> notifications;
  final List<NotificationCategory> categories;
  final int unreadCount;
  final bool hasReachedMax;
  final String? currentFilter;
  final String? currentCategoryId;

  const NotificationLoaded({
    required this.notifications,
    this.categories = const [],
    this.unreadCount = 0,
    this.hasReachedMax = false,
    this.currentFilter,
    this.currentCategoryId,
  });

  @override
  List<Object?> get props => [
    notifications,
    categories,
    unreadCount,
    hasReachedMax,
    currentFilter,
    currentCategoryId,
  ];

  /// Copy with method for state updates
  NotificationLoaded copyWith({
    BasePageModel<NotificationEntity>? notifications,
    List<NotificationCategory>? categories,
    int? unreadCount,
    bool? hasReachedMax,
    String? currentFilter,
    String? currentCategoryId,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      categories: categories ?? this.categories,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilter: currentFilter ?? this.currentFilter,
      currentCategoryId: currentCategoryId ?? this.currentCategoryId,
    );
  }

  /// Helper getters
  List<NotificationEntity> get notificationList => notifications.content;
  bool get isEmpty => notifications.empty;
  bool get hasNotifications => notifications.hasContent;
  int get totalNotifications => notifications.totalElements;
  int get currentPage => notifications.number;
  bool get isLastPage => notifications.last;
  bool get isFirstPage => notifications.first;
}

/// Action success states
final class NotificationActionSuccess extends NotificationState {
  final String message;
  final NotificationActionType actionType;

  const NotificationActionSuccess({required this.message, required this.actionType});

  @override
  List<Object?> get props => [message, actionType];
}

/// Categories loaded state
final class NotificationCategoriesLoaded extends NotificationState {
  final List<NotificationCategory> categories;

  const NotificationCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Statistics loaded state
final class NotificationStatisticsLoaded extends NotificationState {
  final Map<String, dynamic> statistics;

  const NotificationStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// Batch operation states
final class NotificationBatchOperationLoading extends NotificationState {
  final String operationType;
  final int totalItems;

  const NotificationBatchOperationLoading({required this.operationType, required this.totalItems});

  @override
  List<Object?> get props => [operationType, totalItems];
}

final class NotificationBatchOperationSuccess extends NotificationState {
  final Map<String, String> results;
  final String operationType;

  const NotificationBatchOperationSuccess({required this.results, required this.operationType});

  @override
  List<Object?> get props => [results, operationType];
}

/// Error states
final class NotificationError extends NotificationState {
  final String message;
  final String? errorCode;
  final NotificationErrorType errorType;

  const NotificationError({
    required this.message,
    this.errorCode,
    this.errorType = NotificationErrorType.general,
  });

  @override
  List<Object?> get props => [message, errorCode, errorType];
}

final class NotificationActionError extends NotificationState {
  final String message;
  final NotificationActionType actionType;
  final String? notificationId;

  const NotificationActionError({
    required this.message,
    required this.actionType,
    this.notificationId,
  });

  @override
  List<Object?> get props => [message, actionType, notificationId];
}

final class NotificationBatchOperationError extends NotificationState {
  final String message;
  final String operationType;
  final Map<String, String>? partialResults;

  const NotificationBatchOperationError({
    required this.message,
    required this.operationType,
    this.partialResults,
  });

  @override
  List<Object?> get props => [message, operationType, partialResults];
}

// ===============================
// ENUMS
// ===============================

enum NotificationActionType {
  markAsRead,
  markAllAsRead,
  delete,
  subscribe,
  unsubscribe,
  refresh,
  filter,
  search,
  clearAll,
}

enum NotificationErrorType { general, network, validation, server, unauthorized, notFound }

// ===============================
// EXTENSIONS
// ===============================

extension NotificationStateX on NotificationState {
  /// Check if state is loading
  bool get isLoading => this is NotificationLoading;

  /// Check if state is loading more
  bool get isLoadingMore => this is NotificationLoadingMore;

  /// Check if state is refreshing
  bool get isRefreshing => this is NotificationRefreshing;

  /// Check if state has error
  bool get hasError =>
      this is NotificationError ||
      this is NotificationActionError ||
      this is NotificationBatchOperationError;

  /// Check if state is loaded
  bool get isLoaded => this is NotificationLoaded;

  /// Get error message if state has error
  String? get errorMessage {
    if (this is NotificationError) {
      return (this as NotificationError).message;
    } else if (this is NotificationActionError) {
      return (this as NotificationActionError).message;
    } else if (this is NotificationBatchOperationError) {
      return (this as NotificationBatchOperationError).message;
    }
    return null;
  }

  /// Get notifications if state is loaded
  List<NotificationEntity>? get notifications {
    if (this is NotificationLoaded) {
      return (this as NotificationLoaded).notificationList;
    } else if (this is NotificationLoadingMore) {
      return (this as NotificationLoadingMore).currentNotifications;
    } else if (this is NotificationRefreshing) {
      return (this as NotificationRefreshing).currentNotifications;
    }
    return null;
  }

  /// Get unread count if available
  int? get unreadCount {
    if (this is NotificationLoaded) {
      return (this as NotificationLoaded).unreadCount;
    }
    return null;
  }
}
