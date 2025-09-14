import 'package:news_app/feature/notification/domain/entities/notification_count.dart';

class NotificationCountModel extends NotificationCount {
  const NotificationCountModel({
    super.hasNewMessage,
    super.unreadCount,
    super.timestamp,
    super.serverTime,
  });

  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    return NotificationCountModel(
      hasNewMessage: json['hasNewMessage'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int? ?? 0,
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
      serverTime: json['serverTime'] as int?,
    );
  }

  /// Factory constructor from WebSocket message with data wrapper
  factory NotificationCountModel.fromWebSocketMessage(Map<String, dynamic> message) {
    final data = message['data'] as Map<String, dynamic>? ?? message;

    return NotificationCountModel(
      hasNewMessage: data['hasNewMessage'] as bool? ?? false,
      unreadCount: data['unreadCount'] as int? ?? 0,
      timestamp:
          message['timestamp'] != null
              ? DateTime.parse(message['timestamp'] as String)
              : (data['timestamp'] != null
                  ? DateTime.parse(data['timestamp'] as String)
                  : DateTime.now()),
      serverTime: data['serverTime'] as int? ?? message['serverTime'] as int?,
    );
  }

  /// Factory constructor from domain entity
  factory NotificationCountModel.fromEntity(NotificationCount entity) {
    return NotificationCountModel(
      hasNewMessage: entity.hasNewMessage,
      unreadCount: entity.unreadCount,
      timestamp: entity.timestamp,
      serverTime: entity.serverTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasNewMessage': hasNewMessage,
      'unreadCount': unreadCount,
      'timestamp': timestamp?.toIso8601String(),
      'serverTime': serverTime,
    };
  }

  /// Convert to domain entity
  NotificationCount toEntity() {
    return NotificationCount(
      hasNewMessage: hasNewMessage,
      unreadCount: unreadCount,
      timestamp: timestamp,
      serverTime: serverTime,
    );
  }

  @override
  NotificationCountModel copyWith({
    bool? hasNewMessage,
    int? unreadCount,
    DateTime? timestamp,
    int? serverTime,
  }) {
    return NotificationCountModel(
      hasNewMessage: hasNewMessage ?? this.hasNewMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      timestamp: timestamp ?? this.timestamp,
      serverTime: serverTime ?? this.serverTime,
    );
  }
}
