part of 'notification__websocket_bloc.dart';

sealed class NotificationWebSocketEvent extends Equatable {
  const NotificationWebSocketEvent();

  @override
  List<Object?> get props => [];
}

// Connection Events
class NotificationWebSocketConnectEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketConnectEvent();
}

class NotificationWebSocketDisconnectEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketDisconnectEvent();
}

class NotificationWebSocketReconnectEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketReconnectEvent();

  @override
  List<Object?> get props => [];
}

// Subscription Events
class NotificationWebSocketSubscribeEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketSubscribeEvent();

  @override
  List<Object?> get props => [];
}

class NotificationWebSocketUnsubscribeEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketUnsubscribeEvent();
}

// Data Events
class NotificationWebSocketCountUpdatedEvent extends NotificationWebSocketEvent {
  final NotificationCount count;

  const NotificationWebSocketCountUpdatedEvent({required this.count});

  @override
  List<Object?> get props => [count];
}

class NotificationWebSocketConnectionStatusChangedEvent extends NotificationWebSocketEvent {
  final bool isConnected;

  const NotificationWebSocketConnectionStatusChangedEvent({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

// Action Events
class NotificationWebSocketMarkAllAsReadEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketMarkAllAsReadEvent();
}

class NotificationWebSocketMarkSingleAsReadEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketMarkSingleAsReadEvent();
}

class NotificationWebSocketSendMessageEvent extends NotificationWebSocketEvent {
  final String message;

  const NotificationWebSocketSendMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

// 🆕 Animation events
final class NotificationWebSocketAnimationFinishedEvent extends NotificationWebSocketEvent {
  const NotificationWebSocketAnimationFinishedEvent();
}

// 🆕 Delayed update events
final class NotificationWebSocketDelayedUpdateEvent extends NotificationWebSocketEvent {
  final NotificationCount count;

  const NotificationWebSocketDelayedUpdateEvent({required this.count});

  @override
  List<Object?> get props => [count];
}

// Manual trigger events (nếu cần)
final class NotificationWebSocketTriggerAnimationEvent extends NotificationWebSocketEvent {
  final NotificationCount count;

  const NotificationWebSocketTriggerAnimationEvent({required this.count});

  @override
  List<Object?> get props => [count];
}
