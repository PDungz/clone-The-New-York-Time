import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app/core/common/model/base_page_model.dart';
import 'package:news_app/feature/notification/domain/entities/notification.dart';
import 'package:news_app/feature/notification/domain/entities/notification_category.dart';
import 'package:news_app/feature/notification/domain/use_case/notification_use_case.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationUseCase _notificationUseCase = GetIt.instance<NotificationUseCase>();

  // Current page tracking for infinite scroll
  int _currentPage = 0;
  List<NotificationEntity> _allNotifications = [];
  List<NotificationCategory> _categories = [];
  String? _currentFilter;
  String? _currentCategoryId;

  NotificationBloc() : super(NotificationInitial()) {
    // Query Events
    on<GetUserNotificationsEvent>(_onGetUserNotifications);
    on<GetUnreadNotificationsEvent>(_onGetUnreadNotifications);
    on<GetReadNotificationsEvent>(_onGetReadNotifications);
    on<GetNotificationsByCategoryEvent>(_onGetNotificationsByCategory);
    on<GetNotificationStatisticsEvent>(_onGetNotificationStatistics);

    // Command Events
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<BatchMarkAsReadEvent>(_onBatchMarkAsRead);
    on<BatchDeleteNotificationsEvent>(_onBatchDeleteNotifications);

    // Category Events
    on<GetNotificationCategoriesEvent>(_onGetNotificationCategories);

    // Topic Management Events
    on<SubscribeToTopicEvent>(_onSubscribeToTopic);
    on<UnsubscribeFromTopicEvent>(_onUnsubscribeFromTopic);

    // Utility Events
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
    on<LoadMoreNotificationsEvent>(_onLoadMoreNotifications);
    on<FilterNotificationsEvent>(_onFilterNotifications);
    on<SearchNotificationsEvent>(_onSearchNotifications);
    on<ClearAllNotificationsEvent>(_onClearAllNotifications);
    on<ResetNotificationStateEvent>(_onResetNotificationState);
  }

  // ===============================
  // QUERY EVENT HANDLERS
  // ===============================

  Future<void> _onGetUserNotifications(
    GetUserNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        emit(NotificationRefreshing(currentNotifications: _allNotifications));
        _currentPage = 0;
        _allNotifications.clear();
      } else if (event.page == 0) {
        emit(NotificationLoading());
        _currentPage = 0;
        _allNotifications.clear();
      } else {
        emit(NotificationLoadingMore(currentNotifications: _allNotifications));
      }

      _currentFilter = event.status;
      _currentCategoryId = event.categoryName;

      final result = await _notificationUseCase.getUserNotifications(
        page: event.page,
        size: event.size,
        status: event.status,
        categoryName: event.categoryName,
        type: event.type,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      await result.fold(
        (failure) async {
          emit(
            NotificationError(message: failure.message, errorType: _mapFailureToErrorType(failure)),
          );
        },
        (pageModel) async {
          if (event.page == 0 || event.isRefresh) {
            _allNotifications = List.from(pageModel.content);
          } else {
            _allNotifications.addAll(pageModel.content);
          }

          _currentPage = pageModel.number;

          // Get unread count
          final unreadCountResult = await _notificationUseCase.getUnreadNotificationCount();
          int unreadCount = 0;
          unreadCountResult.fold((failure) => unreadCount = 0, (count) => unreadCount = count);

          final updatedPageModel = BasePageModel<NotificationEntity>(
            content: _allNotifications,
            totalElements: pageModel.totalElements,
            totalPages: pageModel.totalPages,
            size: pageModel.size,
            number: _currentPage,
            last: pageModel.last,
            first: pageModel.first,
            numberOfElements: _allNotifications.length,
            empty: _allNotifications.isEmpty,
          );

          emit(
            NotificationLoaded(
              notifications: updatedPageModel,
              categories: _categories,
              unreadCount: unreadCount,
              hasReachedMax: pageModel.last,
              currentFilter: _currentFilter,
              currentCategoryId: _currentCategoryId,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        NotificationError(
          message: 'An unexpected error occurred: $e',
          errorType: NotificationErrorType.general,
        ),
      );
    }
  }

  Future<void> _onGetUnreadNotifications(
    GetUnreadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        emit(NotificationRefreshing(currentNotifications: _allNotifications));
      } else {
        emit(NotificationLoading());
      }

      final result = await _notificationUseCase.getUnreadNotifications(
        page: event.page,
        size: event.size,
        categoryName: event.categoryName,
      );

      result.fold(
        (failure) {
          emit(
            NotificationError(message: failure.message, errorType: _mapFailureToErrorType(failure)),
          );
        },
        (pageModel) {
          _allNotifications = List.from(pageModel.content);
          emit(
            NotificationLoaded(
              notifications: pageModel,
              categories: _categories,
              unreadCount: pageModel.totalElements,
              hasReachedMax: pageModel.last,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        NotificationError(
          message: 'Failed to load unread notifications: $e',
          errorType: NotificationErrorType.general,
        ),
      );
    }
  }

  Future<void> _onGetReadNotifications(
    GetReadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        emit(NotificationRefreshing(currentNotifications: _allNotifications));
      } else {
        emit(NotificationLoading());
      }

      final result = await _notificationUseCase.getReadNotifications(
        page: event.page,
        size: event.size,
        categoryName: event.categoryName,
      );

      result.fold(
        (failure) {
          emit(
            NotificationError(message: failure.message, errorType: _mapFailureToErrorType(failure)),
          );
        },
        (pageModel) {
          _allNotifications = List.from(pageModel.content);
          emit(
            NotificationLoaded(
              notifications: pageModel,
              categories: _categories,
              unreadCount: 0, // All are read
              hasReachedMax: pageModel.last,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        NotificationError(
          message: 'Failed to load read notifications: $e',
          errorType: NotificationErrorType.general,
        ),
      );
    }
  }

  Future<void> _onGetNotificationsByCategory(
    GetNotificationsByCategoryEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        emit(NotificationRefreshing(currentNotifications: _allNotifications));
      } else {
        emit(NotificationLoading());
      }

      final result = await _notificationUseCase.getNotificationsByCategory(
        categoryName: event.categoryName,
        page: event.page,
        size: event.size,
        status: event.status,
      );

      result.fold(
        (failure) {
          emit(
            NotificationError(message: failure.message, errorType: _mapFailureToErrorType(failure)),
          );
        },
        (pageModel) {
          _allNotifications = List.from(pageModel.content);
          _currentCategoryId = event.categoryName;

          emit(
            NotificationLoaded(
              notifications: pageModel,
              categories: _categories,
              hasReachedMax: pageModel.last,
              currentCategoryId: _currentCategoryId,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        NotificationError(
          message: 'Failed to load notifications by category: $e',
          errorType: NotificationErrorType.general,
        ),
      );
    }
  }

  Future<void> _onGetNotificationStatistics(
    GetNotificationStatisticsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());

      // Get various counts
      final unreadCountResult = await _notificationUseCase.getUnreadNotificationCount();
      final allNotificationsResult = await _notificationUseCase.getUserNotifications(size: 1000);

      await unreadCountResult.fold(
        (failure) async {
          emit(NotificationError(message: failure.message));
        },
        (unreadCount) async {
          await allNotificationsResult.fold(
            (failure) async {
              emit(NotificationError(message: failure.message));
            },
            (pageModel) async {
              final statistics = {
                'totalNotifications': pageModel.totalElements,
                'unreadCount': unreadCount,
                'readCount': pageModel.totalElements - unreadCount,
                'todayCount': pageModel.content.where((n) => n.isToday).length,
                'thisWeekCount': pageModel.content.where((n) => n.isThisWeek).length,
              };

              emit(NotificationStatisticsLoaded(statistics: statistics));
            },
          );
        },
      );
    } catch (e) {
      emit(
        NotificationError(
          message: 'Failed to load statistics: $e',
          errorType: NotificationErrorType.general,
        ),
      );
    }
  }

  // ===============================
  // COMMAND EVENT HANDLERS
  // ===============================

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationUseCase.markNotificationAsRead(event.notificationId);

      result.fold(
        (failure) {
          emit(
            NotificationActionError(
              message: failure.message,
              actionType: NotificationActionType.markAsRead,
              notificationId: event.notificationId,
            ),
          );
        },
        (message) {
          // Update local state
          _updateNotificationInList(event.notificationId, (notification) {
            return notification.copyWith(sentAt: DateTime.now().toIso8601String());
          });

          emit(
            NotificationActionSuccess(
              message: message,
              actionType: NotificationActionType.markAsRead,
            ),
          );

          // Refresh current state
          add(const RefreshNotificationsEvent());
        },
      );
    } catch (e) {
      emit(
        NotificationActionError(
          message: 'Failed to mark notification as read: $e',
          actionType: NotificationActionType.markAsRead,
          notificationId: event.notificationId,
        ),
      );
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationUseCase.markAllNotificationsAsRead();

      result.fold(
        (failure) {
          emit(
            NotificationActionError(
              message: failure.message,
              actionType: NotificationActionType.markAllAsRead,
            ),
          );
        },
        (message) {
          emit(
            NotificationActionSuccess(
              message: message,
              actionType: NotificationActionType.markAllAsRead,
            ),
          );

          // Refresh current state
          add(const RefreshNotificationsEvent());
        },
      );
    } catch (e) {
      emit(
        NotificationActionError(
          message: 'Failed to mark all notifications as read: $e',
          actionType: NotificationActionType.markAllAsRead,
        ),
      );
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationUseCase.deleteNotification(event.notificationId);

      result.fold(
        (failure) {
          emit(
            NotificationActionError(
              message: failure.message,
              actionType: NotificationActionType.delete,
              notificationId: event.notificationId,
            ),
          );
        },
        (message) {
          // Remove from local state
          _removeNotificationFromList(event.notificationId);

          emit(
            NotificationActionSuccess(message: message, actionType: NotificationActionType.delete),
          );

          // Update current state
          _emitUpdatedState();
        },
      );
    } catch (e) {
      emit(
        NotificationActionError(
          message: 'Failed to delete notification: $e',
          actionType: NotificationActionType.delete,
          notificationId: event.notificationId,
        ),
      );
    }
  }

  Future<void> _onBatchMarkAsRead(
    BatchMarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(
        NotificationBatchOperationLoading(
          operationType: 'mark_as_read',
          totalItems: event.notificationIds.length,
        ),
      );

      final results = <String, String>{};

      for (final id in event.notificationIds) {
        final result = await _notificationUseCase.markNotificationAsRead(id);
        result.fold(
          (failure) => results[id] = 'Failed: ${failure.message}',
          (success) => results[id] = 'Success',
        );
      }

      emit(NotificationBatchOperationSuccess(results: results, operationType: 'mark_as_read'));

      // Refresh current state
      add(const RefreshNotificationsEvent());
    } catch (e) {
      emit(
        NotificationBatchOperationError(
          message: 'Batch mark as read failed: $e',
          operationType: 'mark_as_read',
        ),
      );
    }
  }

  Future<void> _onBatchDeleteNotifications(
    BatchDeleteNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(
        NotificationBatchOperationLoading(
          operationType: 'delete',
          totalItems: event.notificationIds.length,
        ),
      );

      final results = <String, String>{};

      for (final id in event.notificationIds) {
        final result = await _notificationUseCase.deleteNotification(id);
        result.fold((failure) => results[id] = 'Failed: ${failure.message}', (success) {
          results[id] = 'Success';
          _removeNotificationFromList(id);
        });
      }

      emit(NotificationBatchOperationSuccess(results: results, operationType: 'delete'));

      // Update current state
      _emitUpdatedState();
    } catch (e) {
      emit(
        NotificationBatchOperationError(
          message: 'Batch delete failed: $e',
          operationType: 'delete',
        ),
      );
    }
  }

  // ===============================
  // CATEGORY EVENT HANDLERS
  // ===============================

  Future<void> _onGetNotificationCategories(
    GetNotificationCategoriesEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationUseCase.getNotificationCategories();

      result.fold(
        (failure) {
          emit(
            NotificationError(message: failure.message, errorType: _mapFailureToErrorType(failure)),
          );
        },
        (categories) {
          _categories = List.from(categories);
          emit(NotificationCategoriesLoaded(categories: categories));
        },
      );
    } catch (e) {
      emit(
        NotificationError(
          message: 'Failed to load categories: $e',
          errorType: NotificationErrorType.general,
        ),
      );
    }
  }

  // ===============================
  // TOPIC MANAGEMENT EVENT HANDLERS
  // ===============================

  Future<void> _onSubscribeToTopic(
    SubscribeToTopicEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationUseCase.subscribeToTopic(
        fcmToken: event.fcmToken,
        topic: event.topic,
      );

      result.fold(
        (failure) {
          emit(
            NotificationActionError(
              message: failure.message,
              actionType: NotificationActionType.subscribe,
            ),
          );
        },
        (message) {
          emit(
            NotificationActionSuccess(
              message: message,
              actionType: NotificationActionType.subscribe,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        NotificationActionError(
          message: 'Failed to subscribe to topic: $e',
          actionType: NotificationActionType.subscribe,
        ),
      );
    }
  }

  Future<void> _onUnsubscribeFromTopic(
    UnsubscribeFromTopicEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final result = await _notificationUseCase.unsubscribeFromTopic(
        fcmToken: event.fcmToken,
        topic: event.topic,
      );

      result.fold(
        (failure) {
          emit(
            NotificationActionError(
              message: failure.message,
              actionType: NotificationActionType.unsubscribe,
            ),
          );
        },
        (message) {
          emit(
            NotificationActionSuccess(
              message: message,
              actionType: NotificationActionType.unsubscribe,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        NotificationActionError(
          message: 'Failed to unsubscribe from topic: $e',
          actionType: NotificationActionType.unsubscribe,
        ),
      );
    }
  }

  // ===============================
  // UTILITY EVENT HANDLERS
  // ===============================

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    add(
      GetUserNotificationsEvent(
        page: 0,
        size: 20,
        status: _currentFilter,
        categoryName: _currentCategoryId,
        isRefresh: true,
      ),
    );
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      if (!currentState.hasReachedMax) {
        add(
          GetUserNotificationsEvent(
            page: _currentPage + 1,
            size: 20,
            status: _currentFilter,
            categoryName: _currentCategoryId,
          ),
        );
      }
    }
  }

  Future<void> _onFilterNotifications(
    FilterNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    _currentFilter = event.status;
    _currentCategoryId = event.categoryName;

    add(
      GetUserNotificationsEvent(
        page: 0,
        size: 20,
        status: event.status,
        categoryName: event.categoryName,
        type: event.type,
      ),
    );
  }

  Future<void> _onSearchNotifications(
    SearchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // For now, implement client-side search
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final filteredNotifications =
            currentState.notificationList.where((notification) {
              final query = event.query.toLowerCase();
              return notification.title?.toLowerCase().contains(query) == true ||
                  notification.body?.toLowerCase().contains(query) == true ||
                  notification.categoryDisplayName?.toLowerCase().contains(query) == true;
            }).toList();

        final filteredPageModel = BasePageModel<NotificationEntity>(
          content: filteredNotifications,
          totalElements: filteredNotifications.length,
          totalPages: 1,
          size: filteredNotifications.length,
          number: 0,
          last: true,
          first: true,
          numberOfElements: filteredNotifications.length,
          empty: filteredNotifications.isEmpty,
        );

        emit(currentState.copyWith(notifications: filteredPageModel));
      }
    } catch (e) {
      emit(
        NotificationError(message: 'Search failed: $e', errorType: NotificationErrorType.general),
      );
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Get all notification IDs
      final allIds =
          _allNotifications.map((n) => n.id).where((id) => id != null).cast<String>().toList();

      if (allIds.isNotEmpty) {
        add(BatchDeleteNotificationsEvent(notificationIds: allIds));
      } else {
        emit(
          const NotificationActionSuccess(
            message: 'No notifications to clear',
            actionType: NotificationActionType.clearAll,
          ),
        );
      }
    } catch (e) {
      emit(
        NotificationActionError(
          message: 'Failed to clear all notifications: $e',
          actionType: NotificationActionType.clearAll,
        ),
      );
    }
  }

  Future<void> _onResetNotificationState(
    ResetNotificationStateEvent event,
    Emitter<NotificationState> emit,
  ) async {
    _currentPage = 0;
    _allNotifications.clear();
    _categories.clear();
    _currentFilter = null;
    _currentCategoryId = null;
    emit(NotificationInitial());
  }

  // ===============================
  // HELPER METHODS
  // ===============================

  /// Map failure types to notification error types
  NotificationErrorType _mapFailureToErrorType(dynamic failure) {
    final message = failure.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return NotificationErrorType.network;
    } else if (message.contains('validation')) {
      return NotificationErrorType.validation;
    } else if (message.contains('unauthorized') || message.contains('401')) {
      return NotificationErrorType.unauthorized;
    } else if (message.contains('not found') || message.contains('404')) {
      return NotificationErrorType.notFound;
    } else if (message.contains('server') || message.contains('500')) {
      return NotificationErrorType.server;
    }

    return NotificationErrorType.general;
  }

  /// Update notification in local list
  void _updateNotificationInList(
    String notificationId,
    NotificationEntity Function(NotificationEntity) updater,
  ) {
    final index = _allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _allNotifications[index] = updater(_allNotifications[index]);
    }
  }

  /// Remove notification from local list
  void _removeNotificationFromList(String notificationId) {
    _allNotifications.removeWhere((n) => n.id == notificationId);
  }

  /// Emit updated state with current notifications
  void _emitUpdatedState() {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final updatedPageModel = BasePageModel<NotificationEntity>(
        content: _allNotifications,
        totalElements: _allNotifications.length,
        totalPages: 1,
        size: _allNotifications.length,
        number: 0,
        last: true,
        first: true,
        numberOfElements: _allNotifications.length,
        empty: _allNotifications.isEmpty,
      );

      // ignore: invalid_use_of_visible_for_testing_member
      emit(currentState.copyWith(notifications: updatedPageModel));
    }
  }

  /// Get notification by ID
  NotificationEntity? getNotificationById(String notificationId) {
    try {
      return _allNotifications.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }

  /// Get unread notifications
  List<NotificationEntity> get unreadNotifications {
    return _allNotifications.where((n) => !n.isRead).toList();
  }

  /// Get read notifications
  List<NotificationEntity> get readNotifications {
    return _allNotifications.where((n) => n.isRead).toList();
  }

  /// Get notifications by category
  List<NotificationEntity> getNotificationsByCategory(String categoryName) {
    return _allNotifications.where((n) => n.categoryName == categoryName).toList();
  }

  /// Get notifications by priority
  List<NotificationEntity> getNotificationsByPriority(String priority) {
    return _allNotifications.where((n) => n.priority == priority).toList();
  }

  /// Check if has unread notifications
  bool get hasUnreadNotifications {
    return _allNotifications.any((n) => !n.isRead);
  }

  /// Get total notification count
  int get totalNotificationCount => _allNotifications.length;

  /// Get current page
  int get currentPage => _currentPage;

  /// Get current filter
  String? get currentFilter => _currentFilter;

  /// Get current category ID
  String? get currentCategoryId => _currentCategoryId;
}
