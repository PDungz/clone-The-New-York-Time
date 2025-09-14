import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/service/di/injection_container.dart';
import 'package:news_app/core/service/secure/secure_token_manager.dart';
import 'package:news_app/feature/notification/domain/entities/notification_count.dart';
import 'package:news_app/feature/notification/domain/use_case/notification_websocket_user_case.dart';
import 'package:packages/core/service/logger_service.dart';

part 'notification_websocket_event.dart';
part 'notification_websocket_state.dart';

class NotificationWebSocketBloc
    extends Bloc<NotificationWebSocketEvent, NotificationWebSocketState> {
  final NotificationWebsocketUseCase _notificationUseCase = getIt<NotificationWebsocketUseCase>();

  // Stream subscriptions
  StreamSubscription<Either<Failure, NotificationCount>>? _countSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Auto-subscribe flag
  bool _shouldAutoSubscribe = false;

  // Simple delay timer
  Timer? _delayTimer;
  
  // Flag để track đang trong delay mode
  bool _isInDelayMode = false;

  NotificationWebSocketBloc() : super(NotificationWebSocketInitial()) {
    _initializePersistentListening();

    // Register event handlers
    on<NotificationWebSocketConnectEvent>(_onConnect);
    on<NotificationWebSocketDisconnectEvent>(_onDisconnect);
    on<NotificationWebSocketSubscribeEvent>(_onSubscribe);
    on<NotificationWebSocketUnsubscribeEvent>(_onUnsubscribe);
    on<NotificationWebSocketCountUpdatedEvent>(_onCountUpdated);
    on<NotificationWebSocketConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    on<NotificationWebSocketMarkAllAsReadEvent>(_onMarkAllAsRead);
    on<NotificationWebSocketMarkSingleAsReadEvent>(_onMarkSingleAsRead);
    on<NotificationWebSocketSendMessageEvent>(_onSendMessage);
    on<NotificationWebSocketReconnectEvent>(_onReconnect);
    on<NotificationWebSocketDelayedUpdateEvent>(_onDelayedUpdate); // Thêm handler mới
  }

  /// Initialize persistent listening that works throughout app lifecycle
  void _initializePersistentListening() {
    // Listen to notification count updates
    _countSubscription = _notificationUseCase.getNotificationCountStream().listen(
      (result) {
        result.fold(
          (failure) =>
              add(const NotificationWebSocketConnectionStatusChangedEvent(isConnected: false)),
          (count) {
            printS(
              '[NotificationWebSocketBloc] ✅ Count updated: ${count.unreadCount} unread, hasNew: ${count.hasNewMessage}',
            );
            add(NotificationWebSocketCountUpdatedEvent(count: count));
          },
        );
      },
      onError:
          (error) =>
              add(const NotificationWebSocketConnectionStatusChangedEvent(isConnected: false)),
    );

    // Listen to connection status changes
    _connectionSubscription = _notificationUseCase.connectionStatusStream.listen(
      (isConnected) =>
          add(NotificationWebSocketConnectionStatusChangedEvent(isConnected: isConnected)),
      onError:
          (error) =>
              add(const NotificationWebSocketConnectionStatusChangedEvent(isConnected: false)),
    );
  }

  void _onCountUpdated(
    NotificationWebSocketCountUpdatedEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) {
    final hasNewMessage = event.count.hasNewMessage ?? false;
    
    printS('[NotificationWebSocketBloc] 📥 Received: hasNewMessage=$hasNewMessage, count=${event.count.unreadCount}, isInDelayMode=$_isInDelayMode');
    
    if (state is NotificationWebSocketConnected) {
      final currentState = state as NotificationWebSocketConnected;
      
      if (hasNewMessage && !_isInDelayMode) {
        // Message 1: hasNewMessage = true (ngay lập tức)
        printS('[NotificationWebSocketBloc] 🎯 Emitting hasNewMessage=true immediately');
        _isInDelayMode = true; // Bắt đầu delay mode
        
        final newState = currentState.copyWith(
          notificationCount: event.count,
        );
        emit(newState);
        
        // Message 2: hasNewMessage = false (sau 1.5 giây)
        printS('[NotificationWebSocketBloc] ⏱️ Scheduling hasNewMessage=false in 1.5s');
        _scheduleDelayedUpdate(event.count);
        
      } else if (!hasNewMessage && !_isInDelayMode) {
        // Update bình thường khi KHÔNG trong delay mode
        printS('[NotificationWebSocketBloc] 📊 Normal update, no delay');
        final newState = currentState.copyWith(
          notificationCount: event.count,
        );
        emit(newState);
        
      } else if (!hasNewMessage && _isInDelayMode) {
        // BỎ QUA message hasNewMessage=false khi đang trong delay mode
        printS('[NotificationWebSocketBloc] 🚫 Ignoring hasNewMessage=false while in delay mode');
        
      } else if (hasNewMessage && _isInDelayMode) {
        // Có notification mới khác trong khi đang delay -> reset timer
        printS('[NotificationWebSocketBloc] 🔄 New notification while in delay mode, resetting timer');
        _delayTimer?.cancel();
        
        final newState = currentState.copyWith(
          notificationCount: event.count,
        );
        emit(newState);
        
        _scheduleDelayedUpdate(event.count);
      }
    } else {
      // Create connected state if not connected but received data
      printS('[NotificationWebSocketBloc] 🔗 Creating initial connected state');
      emit(
        NotificationWebSocketConnected(
          notificationCount: event.count,
          isConnected: true,
          isSubscribed: true,
        ),
      );
      
      if (hasNewMessage) {
        printS('[NotificationWebSocketBloc] ⏱️ Scheduling hasNewMessage=false in 1.5s (initial)');
        _isInDelayMode = true;
        _scheduleDelayedUpdate(event.count);
      }
    }
  }

  void _scheduleDelayedUpdate(NotificationCount originalCount) {
    // Cancel previous timer
    _delayTimer?.cancel();
    
    // Set timer để ADD EVENT thay vì emit trực tiếp
    _delayTimer = Timer(const Duration(milliseconds: 1500), () {
      final updatedCount = originalCount.copyWith(
        hasNewMessage: false,
        timestamp: DateTime.now(),
      );
      
      // Reset delay mode flag
      _isInDelayMode = false;
      
      // SỬ DỤNG ADD EVENT thay vì emit
      add(NotificationWebSocketDelayedUpdateEvent(count: updatedCount));
    });
  }

  // Event handlers (giữ nguyên tất cả existing methods...)
  Future<void> _onConnect(
    NotificationWebSocketConnectEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    emit(NotificationWebSocketConnecting());

    final result = await _notificationUseCase.connect();

    result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
      printS('[NotificationWebSocketBloc] Connected successfully');
      emit(
        NotificationWebSocketConnected(
          notificationCount: _notificationUseCase.getCurrentCount(),
          isConnected: true,
        ),
      );

      if (_shouldAutoSubscribe) {
        add(const NotificationWebSocketSubscribeEvent());
      }
    });
  }

  Future<void> _onDisconnect(
    NotificationWebSocketDisconnectEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    _delayTimer?.cancel();
    _isInDelayMode = false; // Reset delay mode
    
    final result = await _notificationUseCase.disconnect();

    result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
      printS('[NotificationWebSocketBloc] Disconnected');
      emit(NotificationWebSocketDisconnected());
    });
  }

  Future<void> _onSubscribe(
    NotificationWebSocketSubscribeEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    _shouldAutoSubscribe = true;

    if (state is! NotificationWebSocketConnected) {
      return; // Will auto-subscribe after connection
    }

    try {
      final secureStore = await SecureTokenManager.getInstance();
      final userData = await secureStore.getUserData();
      final userId = userData?.userId ?? '';

      if (userId.isEmpty) {
        emit(const NotificationWebSocketError('User ID not found'));
        return;
      }

      final result = await _notificationUseCase.subscribeToNotifications(userId: userId);

      result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
        printS('[NotificationWebSocketBloc] Subscribed for user: $userId');
        emit(
          (state as NotificationWebSocketConnected).copyWith(isSubscribed: true, userId: userId),
        );
      });
    } catch (e) {
      emit(NotificationWebSocketError('Subscribe failed: $e'));
    }
  }

  Future<void> _onUnsubscribe(
    NotificationWebSocketUnsubscribeEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    _shouldAutoSubscribe = false;
    _delayTimer?.cancel();

    final result = await _notificationUseCase.unsubscribeFromNotifications();

    result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
      printS('[NotificationWebSocketBloc] Unsubscribed');
      if (state is NotificationWebSocketConnected) {
        emit((state as NotificationWebSocketConnected).copyWith(isSubscribed: false, userId: null));
      }
    });
  }

  void _onConnectionStatusChanged(
    NotificationWebSocketConnectionStatusChangedEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) {
    if (state is NotificationWebSocketConnected) {
      emit((state as NotificationWebSocketConnected).copyWith(isConnected: event.isConnected));

      // Auto-reconnect if connection lost
      if (!event.isConnected && _shouldAutoSubscribe) {
        _delayTimer?.cancel();
        Future.delayed(const Duration(seconds: 3), () {
          if (!_notificationUseCase.isConnected) {
            add(const NotificationWebSocketReconnectEvent());
          }
        });
      }
    } else if (!event.isConnected) {
      _delayTimer?.cancel();
      emit(NotificationWebSocketDisconnected());
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationWebSocketMarkAllAsReadEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    final result = await _notificationUseCase.markAllAsRead();

    result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
      printS('[NotificationWebSocketBloc] Marked all as read');
      final updatedCount = _notificationUseCase.getCurrentCount();
      if (state is NotificationWebSocketConnected) {
        emit((state as NotificationWebSocketConnected).copyWith(notificationCount: updatedCount));
      }
    });
  }

  Future<void> _onMarkSingleAsRead(
    NotificationWebSocketMarkSingleAsReadEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    final result = await _notificationUseCase.markSingleAsRead();

    result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
      final updatedCount = _notificationUseCase.getCurrentCount();
      if (state is NotificationWebSocketConnected) {
        emit((state as NotificationWebSocketConnected).copyWith(notificationCount: updatedCount));
      }
    });
  }

  Future<void> _onSendMessage(
    NotificationWebSocketSendMessageEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    final result = await _notificationUseCase.sendNotification(event.message);

    result.fold(
      (failure) => emit(NotificationWebSocketError(failure.message)),
      (_) => printS('[NotificationWebSocketBloc] Message sent successfully'),
    );
  }

  Future<void> _onReconnect(
    NotificationWebSocketReconnectEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) async {
    emit(NotificationWebSocketConnecting());
    _delayTimer?.cancel();

    try {
      final secureStore = await SecureTokenManager.getInstance();
      final userData = await secureStore.getUserData();
      final userId = userData?.userId ?? '';

      if (userId.isEmpty) {
        emit(const NotificationWebSocketError('User ID not found for reconnect'));
        return;
      }

      final result = await _notificationUseCase.connectAndSubscribe(userId: userId);

      result.fold((failure) => emit(NotificationWebSocketError(failure.message)), (_) {
        printS('[NotificationWebSocketBloc] Reconnected successfully');
        emit(
          NotificationWebSocketConnected(
            notificationCount: _notificationUseCase.getCurrentCount(),
            isSubscribed: true,
            userId: userId,
          ),
        );
      });
    } catch (e) {
      emit(NotificationWebSocketError('Reconnect failed: $e'));
    }
  }

  void _onDelayedUpdate(
    NotificationWebSocketDelayedUpdateEvent event,
    Emitter<NotificationWebSocketState> emit,
  ) {
    printS('[NotificationWebSocketBloc] ⏰ Processing delayed update: hasNewMessage set to false');
    
    if (state is NotificationWebSocketConnected) {
      final currentState = state as NotificationWebSocketConnected;
      final newState = currentState.copyWith(
        notificationCount: event.count,
      );
      emit(newState);
    }
  }

  // Helper methods
  bool get isConnected => _notificationUseCase.isConnected;
  NotificationCount get currentCount => _notificationUseCase.getCurrentCount();
  bool get shouldAutoSubscribe => _shouldAutoSubscribe;

  @override
  Future<void> close() {
    _delayTimer?.cancel();
    _countSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}