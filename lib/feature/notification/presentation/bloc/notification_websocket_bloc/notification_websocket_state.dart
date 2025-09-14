part of 'notification__websocket_bloc.dart';

sealed class NotificationWebSocketState extends Equatable {
  const NotificationWebSocketState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
final class NotificationWebSocketInitial extends NotificationWebSocketState {}

// Connection states
final class NotificationWebSocketConnecting extends NotificationWebSocketState {}

final class NotificationWebSocketConnected extends NotificationWebSocketState {
  final NotificationCount notificationCount;
  final bool isConnected;
  final bool isSubscribed;
  final String? userId;
  
  const NotificationWebSocketConnected({
    required this.notificationCount,
    this.isConnected = true,
    this.isSubscribed = false,
    this.userId,
  });
  
  // Helper getters based on notification count
  bool get hasNewMessage => notificationCount.hasNewMessage ?? false;
  bool get hasNotificationWebSocket => notificationCount.shouldShowBadge;
  int get unreadCount => notificationCount.unreadCount ?? 0;
  String get displayText => notificationCount.displayText;
  bool get shouldAnimate => notificationCount.shouldAnimate;
  
  NotificationWebSocketConnected copyWith({
    NotificationCount? notificationCount,
    bool? isConnected,
    bool? isSubscribed,
    String? userId,
  }) {
    return NotificationWebSocketConnected(
      notificationCount: notificationCount ?? this.notificationCount,
      isConnected: isConnected ?? this.isConnected,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      userId: userId ?? this.userId,
    );
  }
  
  @override
  List<Object?> get props => [notificationCount, isConnected, isSubscribed, userId];
}

final class NotificationWebSocketDisconnected extends NotificationWebSocketState {}

final class NotificationWebSocketError extends NotificationWebSocketState {
  final String message;
  
  const NotificationWebSocketError(this.message);
  
  @override
  List<Object?> get props => [message];
}