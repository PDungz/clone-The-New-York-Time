import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:news_app/core/base/websocket/enum/websocket_status.dart';
import 'package:news_app/core/base/websocket/model/websocket_message.dart';
import 'package:news_app/core/base/websocket/websocket_config.dart';
import 'package:packages/core/service/logger_service.dart';

abstract class BaseWebSocketService {
  WebSocket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  // Configuration
  late WebSocketConfig _config;

  // State
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.disconnected;
  int _reconnectAttempts = 0;
  String? _lastError;

  // Streams
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<WebSocketConnectionStatus> _statusController =
      StreamController<WebSocketConnectionStatus>.broadcast();
  final StreamController<String> _rawMessageController = StreamController<String>.broadcast();

  // Getters
  WebSocketConnectionStatus get status => _status;
  String? get lastError => _lastError;
  WebSocketConfig get config => _config;
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  Stream<WebSocketConnectionStatus> get statusStream => _statusController.stream;
  Stream<String> get rawMessageStream => _rawMessageController.stream;
  bool get isConnected => _status == WebSocketConnectionStatus.connected;

  BaseWebSocketService(WebSocketConfig config) {
    _config = config;
  }

  // Abstract methods to be implemented by subclasses
  WebSocketMessage createHeartbeatMessage();
  void onMessageReceived(WebSocketMessage message);
  void onConnected();
  void onDisconnected();
  void onError(String error);

  // Public Methods
  Future<void> connect() async {
    if (_status == WebSocketConnectionStatus.connecting ||
        _status == WebSocketConnectionStatus.connected) {
      return;
    }
    await _connect();
  }

  Future<void> disconnect() async {
    _clearTimers();
    _reconnectAttempts = 0;

    if (_socket != null) {
      await _socket!.close(WebSocketStatus.normalClosure, 'Manual disconnect');
      _socket = null;
    }

    _updateStatus(WebSocketConnectionStatus.disconnected);
  }

  void sendMessage(WebSocketMessage message) {
    if (!isConnected) {
      printE('WebSocket not connected. Cannot send message: ${message.type}');
      return;
    }

    try {
      final jsonString = jsonEncode(message.toJson());
      _socket!.add(jsonString);
      printS('[$runtimeType] WS Sent: $jsonString');
    } catch (e) {
      printE('[$runtimeType] WS Error sending message: $e');
      _handleError('Failed to send message: $e');
    }
  }

  void sendRawMessage(String message) {
    if (!isConnected) {
      printE('WebSocket not connected. Cannot send raw message');
      return;
    }

    try {
      _socket!.add(message);
      printS('[$runtimeType] WS Sent raw: $message');
    } catch (e) {
      printE('[$runtimeType] WS Error sending raw message: $e');
      _handleError('Failed to send raw message: $e');
    }
  }

  void sendJsonMap(Map<String, dynamic> data) {
    if (!isConnected) {
      printE('WebSocket not connected. Cannot send JSON data');
      return;
    }

    try {
      final jsonString = jsonEncode(data);
      _socket!.add(jsonString);
      printS('[$runtimeType] WS Sent JSON: $jsonString');
    } catch (e) {
      printE('[$runtimeType] WS Error sending JSON data: $e');
      _handleError('Failed to send JSON data: $e');
    }
  }

  void updateConfig(WebSocketConfig newConfig) {
    final wasConnected = isConnected;
    _config = newConfig;

    if (wasConnected) {
      // Reconnect with new config
      disconnect().then((_) => connect());
    }
  }

  // Private Methods
  Future<void> _connect() async {
    try {
      _updateStatus(WebSocketConnectionStatus.connecting);
      _lastError = null;

      _socket = await WebSocket.connect(
        _config.url,
        headers: _config.headers,
      ).timeout(_config.connectionTimeout);

      _socket!.listen(
        _onMessage,
        onError: _onSocketError,
        onDone: _onDisconnected,
        cancelOnError: false,
      );

      _updateStatus(WebSocketConnectionStatus.connected);
      _reconnectAttempts = 0;

      if (_config.enableHeartbeat) {
        _startHeartbeat();
      }

      onConnected();
      printS('[$runtimeType] WS WebSocket connected to ${_config.url}');
    } catch (e) {
      printE('[$runtimeType] WS WebSocket connection error: $e');
      _handleError('Connection failed: $e');
      if (_config.enableAutoReconnect) {
        _scheduleReconnect();
      }
    }
  }

  void _onMessage(dynamic data) {
    try {
      printI('[$runtimeType] WS Received: $data');

      // Emit raw message
      _rawMessageController.add(data.toString());

      if (data is String) {
        final message = WebSocketMessage.fromRawJson(data);
        _messageController.add(message);
        onMessageReceived(message);
      }
    } catch (e) {
      printE('[$runtimeType] WS Error processing message: $e');
      final errorMessage = WebSocketMessage(
        type: 'error',
        data: {'error': e.toString(), 'raw': data.toString()},
      );
      _messageController.add(errorMessage);
    }
  }

  void _onSocketError(error) {
    printE('[$runtimeType] WS WebSocket error: $error');
    _handleError('WebSocket error: $error');
  }

  void _onDisconnected() {
    printI('[$runtimeType] WS WebSocket disconnected');
    _clearTimers();
    _socket = null;

    if (_status != WebSocketConnectionStatus.disconnected) {
      _updateStatus(WebSocketConnectionStatus.disconnected);
      onDisconnected();

      if (_config.enableAutoReconnect) {
        _scheduleReconnect();
      }
    }
  }

  void _handleError(String error) {
    _lastError = error;
    _updateStatus(WebSocketConnectionStatus.error);
    onError(error);
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _config.maxReconnectAttempts) {
      printE('[$runtimeType] WS Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    _updateStatus(WebSocketConnectionStatus.reconnecting);

    printI(
      '[$runtimeType] WS Scheduling reconnect attempt $_reconnectAttempts in ${_config.reconnectInterval.inSeconds}s',
    );

    _reconnectTimer = Timer(_config.reconnectInterval, () {
      _connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_config.heartbeatInterval, (timer) {
      if (isConnected) {
        final heartbeatMessage = createHeartbeatMessage();
        sendMessage(heartbeatMessage);
      }
    });
  }

  void _clearTimers() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateStatus(WebSocketConnectionStatus status) {
    if (_status != status) {
      _status = status;
      _statusController.add(status);
    }
  }

  void dispose() {
    _clearTimers();
    _socket?.close();
    _messageController.close();
    _statusController.close();
    _rawMessageController.close();
  }
}
