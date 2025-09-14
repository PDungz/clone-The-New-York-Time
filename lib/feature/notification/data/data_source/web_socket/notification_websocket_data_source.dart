// feature/notification/data/data_source/web_socket/notification_websocket_data_source.dart
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:news_app/core/base/config/app_config_manager_base.dart';
import 'package:news_app/core/base/error/failures.dart';
import 'package:news_app/core/base/websocket/base_websocket_service.dart';
import 'package:news_app/core/base/websocket/enum/websocket_status.dart';
import 'package:news_app/core/base/websocket/model/websocket_message.dart';
import 'package:news_app/core/base/websocket/websocket_config.dart';
import 'package:news_app/feature/notification/data/model/notification_count_model.dart';
import 'package:packages/core/service/logger_service.dart';

abstract class NotificationWebsocketDataSource {
  Future<Either<Failure, bool>> connect();
  Future<Either<Failure, bool>> disconnect();
  Future<Either<Failure, bool>> subscribeToNotifications({required String userId});
  Future<Either<Failure, bool>> unsubscribeFromNotifications();
  Stream<Either<Failure, NotificationCountModel>> get notificationCountStream;
  Future<Either<Failure, bool>> sendNotification(String message);
  bool get isConnected;
  Stream<bool> get connectionStatusStream;
  Future<Either<Failure, bool>> markAllAsRead();
  Future<Either<Failure, bool>> markSingleAsRead();
  NotificationCountModel getCurrentCount();
  Map<String, dynamic> getDebugInfo();
  void updateWebSocketUrl(String newBaseUrl);
  void dispose();
}

class NotificationWebsocketDataSourceImpl extends BaseWebSocketService
    implements NotificationWebsocketDataSource {
  // Stream controllers
  final StreamController<Either<Failure, NotificationCountModel>> _notificationController =
      StreamController<Either<Failure, NotificationCountModel>>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  // Current state
  String? _currentUserId;
  NotificationCountModel _currentCount = NotificationCountModel(
    hasNewMessage: false,
    unreadCount: 0,
    timestamp: DateTime.now(),
  );

  NotificationWebsocketDataSourceImpl()
    : super(
        WebSocketConfig(
          url: AppConfigManagerBase.wsBaseUrl + AppConfigManagerBase.wsNotificationUnread,
          enableHeartbeat: true,
          heartbeatInterval: const Duration(seconds: 30),
          enableAutoReconnect: true,
          maxReconnectAttempts: 5,
          reconnectInterval: const Duration(seconds: 5),
          connectionTimeout: const Duration(seconds: 10),
        ),
      );

  @override
  Stream<Either<Failure, NotificationCountModel>> get notificationCountStream =>
      _notificationController.stream;

  @override
  Stream<bool> get connectionStatusStream => _connectionController.stream;

  @override
  bool get isConnected => status == WebSocketConnectionStatus.connected;

  @override
  Future<Either<Failure, bool>> connect() async {
    try {
      printI('[NotificationWebSocket] Connecting...');
      await super.connect();
      printS('[NotificationWebSocket] Connected successfully');
      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Connection failed: $e');
      return Left(ServerFailure('Failed to connect to WebSocket: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> disconnect() async {
    try {
      await super.disconnect();
      _currentUserId = null;
      printI('[NotificationWebSocket] Disconnected');
      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Disconnect error: $e');
      return Left(ServerFailure('Failed to disconnect from WebSocket: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> subscribeToNotifications({required String userId}) async {
    try {
      if (!isConnected) {
        return const Left(ServerFailure('WebSocket not connected'));
      }

      _currentUserId = userId;

      final subscribeMessage = {
        "action": "SUBSCRIBE",
        "userId": userId,
        "timestamp": DateTime.now().toIso8601String(),
      };

      sendJsonMap(subscribeMessage);
      printS('[NotificationWebSocket] Subscribed for user: $userId');
      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Subscribe failed: $e');
      return Left(ServerFailure('Failed to subscribe to notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> unsubscribeFromNotifications() async {
    try {
      if (!isConnected || _currentUserId == null) {
        return const Right(true);
      }

      final unsubscribeMessage = {
        "action": "UNSUBSCRIBE",
        "userId": _currentUserId!,
        "timestamp": DateTime.now().toIso8601String(),
      };

      sendJsonMap(unsubscribeMessage);
      _currentUserId = null;
      printI('[NotificationWebSocket] Unsubscribed');
      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Unsubscribe failed: $e');
      return Left(ServerFailure('Failed to unsubscribe from notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendNotification(String message) async {
    try {
      if (!isConnected) {
        return const Left(ServerFailure('WebSocket not connected'));
      }

      final notificationMessage = {
        "action": "SEND_NOTIFICATION",
        "message": message,
        "userId": _currentUserId,
        "timestamp": DateTime.now().toIso8601String(),
      };

      sendJsonMap(notificationMessage);
      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Send notification failed: $e');
      return Left(ServerFailure('Failed to send notification: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      if (!isConnected || _currentUserId == null) {
        _updateLocalCount(hasNewMessage: false, unreadCount: 0);
        return const Right(true);
      }

      final markReadMessage = {
        "action": "MARK_ALL_READ",
        "userId": _currentUserId!,
        "timestamp": DateTime.now().toIso8601String(),
      };

      sendJsonMap(markReadMessage);
      _updateLocalCount(hasNewMessage: false, unreadCount: 0);

      printI('[NotificationWebSocket] Marked all as read');
      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Mark all as read failed: $e');
      return Left(ServerFailure('Failed to mark all as read: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> markSingleAsRead() async {
    try {
      if (!isConnected || _currentUserId == null) {
        final newCount =
            (_currentCount.unreadCount ?? 0) > 0 ? (_currentCount.unreadCount! - 1) : 0;
        _updateLocalCount(unreadCount: newCount);
        return const Right(true);
      }

      final markReadMessage = {
        "action": "MARK_SINGLE_READ",
        "userId": _currentUserId!,
        "timestamp": DateTime.now().toIso8601String(),
      };

      sendJsonMap(markReadMessage);
      final newCount = (_currentCount.unreadCount ?? 0) > 0 ? (_currentCount.unreadCount! - 1) : 0;
      _updateLocalCount(unreadCount: newCount);

      return const Right(true);
    } catch (e) {
      printE('[NotificationWebSocket] Mark single as read failed: $e');
      return Left(ServerFailure('Failed to mark single as read: $e'));
    }
  }

  @override
  NotificationCountModel getCurrentCount() => _currentCount;

  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'isConnected': isConnected,
      'status': status.toString(),
      'currentUserId': _currentUserId,
      'currentCount': _currentCount.toJson(),
      'hasStreamListeners': _notificationController.hasListener,
      'hasConnectionListeners': _connectionController.hasListener,
    };
  }

  /// Override BaseWebSocketService methods
  @override
  WebSocketMessage createHeartbeatMessage() {
    return WebSocketMessage(
      type: 'PING',
      data: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': _currentUserId,
        'service': 'notification_websocket',
      },
    );
  }

  @override
  void onConnected() {
    printI('[NotificationWebSocket] Connection established');
    _connectionController.add(true);

    if (_currentUserId != null) {
      subscribeToNotifications(userId: _currentUserId!);
    }
  }

  @override
  void onDisconnected() {
    printW('[NotificationWebSocket] Connection lost');
    _connectionController.add(false);
  }

  @override
  void onError(String error) {
    printE('[NotificationWebSocket] Error: $error');
    _connectionController.add(false);
    _notificationController.add(Left(ServerFailure(error)));
  }

  @override
  void onMessageReceived(WebSocketMessage message) {
    try {
      switch (message.type) {
        case 'NEW_MESSAGE_FLAG':
          if (message.data != null) {
            _handleNotificationCountMessage(message.data!);
          }
          break;
        case 'RESPONSE':
          if (message.data != null && message.data!['data'] != null) {
            _handleNotificationCountMessage(message.data!);
          }
          break;
        case 'raw':
          if (message.data != null) {
            _handleRawMessage(message.data!);
          }
          break;
        case 'PONG':
          // Heartbeat acknowledged - no action needed
          break;
        case 'ERROR':
          _handleErrorMessage(message);
          break;
        default:
          printW('[NotificationWebSocket] Unhandled message type: ${message.type}');
      }
    } catch (e) {
      printE('[NotificationWebSocket] Message processing error: $e');
      _notificationController.add(Left(ServerFailure('Message processing failed: $e')));
    }
  }

  void _handleRawMessage(Map<String, dynamic> messageData) {
    try {
      // Extract actual data from wrapped format
      Map<String, dynamic>? actualData;

      if (messageData.containsKey('raw') && messageData['raw'] is Map<String, dynamic>) {
        actualData = messageData['raw'] as Map<String, dynamic>;
      } else {
        actualData = messageData;
      }

      // Process NEW_MESSAGE_FLAG messages
      if (actualData['type'] == 'NEW_MESSAGE_FLAG') {
        final data = actualData['data'];
        if (data is Map<String, dynamic>) {
          // Enrich notification data with metadata
          final enrichedData = Map<String, dynamic>.from(data);
          if (actualData.containsKey('timestamp')) {
            enrichedData['timestamp'] = actualData['timestamp'];
          }
          if (actualData.containsKey('serverTime')) {
            enrichedData['serverTime'] = actualData['serverTime'];
          }

          _handleNotificationCountMessage(enrichedData);
        }
      }
    } catch (e) {
      printE('[NotificationWebSocket] Raw message error: $e');
      _notificationController.add(Left(ServerFailure('Failed to handle raw message: $e')));
    }
  }

  void _handleNotificationCountMessage(Map<String, dynamic> messageData) {
    try {
      final model = NotificationCountModel.fromWebSocketMessage(messageData);
      _currentCount = model;
      _notificationController.add(Right(model));

      printI(
        '[NotificationWebSocket] ✅ Count updated: ${model.unreadCount} unread, hasNew: ${model.hasNewMessage}',
      );
    } catch (e) {
      printE('[NotificationWebSocket] Parse error: $e');
      _notificationController.add(Left(ServerFailure('Failed to parse notification count: $e')));
    }
  }

  void _handleErrorMessage(WebSocketMessage message) {
    final errorMsg = message.data?['message'] as String? ?? 'Unknown server error';
    printE('[NotificationWebSocket] Server error: $errorMsg');
    _notificationController.add(Left(ServerFailure(errorMsg)));
  }

  void _updateLocalCount({bool? hasNewMessage, int? unreadCount}) {
    _currentCount = _currentCount.copyWith(
      hasNewMessage: hasNewMessage,
      unreadCount: unreadCount,
      timestamp: DateTime.now(),
    );
    _notificationController.add(Right(_currentCount));
  }

  @override
  void updateWebSocketUrl(String newBaseUrl) {
    printI('[NotificationWebSocket] Updating WebSocket URL to: $newBaseUrl');
    final newConfig = WebSocketConfig(
      url: newBaseUrl + AppConfigManagerBase.wsNotificationUnread,
      enableHeartbeat: config.enableHeartbeat,
      heartbeatInterval: config.heartbeatInterval,
      enableAutoReconnect: config.enableAutoReconnect,
      maxReconnectAttempts: config.maxReconnectAttempts,
      reconnectInterval: config.reconnectInterval,
      connectionTimeout: config.connectionTimeout,
      headers: config.headers,
    );
    updateConfig(newConfig);
  }

  @override
  void dispose() {
    printI('[NotificationWebSocket] Disposing...');
    _notificationController.close();
    _connectionController.close();
    super.dispose();
  }
}
