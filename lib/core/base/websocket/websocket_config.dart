class WebSocketConfig {
  final String url;
  final Map<String, String> headers;
  final Duration heartbeatInterval;
  final Duration reconnectInterval;
  final int maxReconnectAttempts;
  final Duration connectionTimeout;
  final bool enableHeartbeat;
  final bool enableAutoReconnect;

  const WebSocketConfig({
    required this.url,
    this.headers = const {},
    this.heartbeatInterval = const Duration(seconds: 30),
    this.reconnectInterval = const Duration(seconds: 5),
    this.maxReconnectAttempts = 5,
    this.connectionTimeout = const Duration(seconds: 10),
    this.enableHeartbeat = true,
    this.enableAutoReconnect = true,
  });

  WebSocketConfig copyWith({
    String? url,
    Map<String, String>? headers,
    Duration? heartbeatInterval,
    Duration? reconnectInterval,
    int? maxReconnectAttempts,
    Duration? connectionTimeout,
    bool? enableHeartbeat,
    bool? enableAutoReconnect,
  }) {
    return WebSocketConfig(
      url: url ?? this.url,
      headers: headers ?? this.headers,
      heartbeatInterval: heartbeatInterval ?? this.heartbeatInterval,
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      enableHeartbeat: enableHeartbeat ?? this.enableHeartbeat,
      enableAutoReconnect: enableAutoReconnect ?? this.enableAutoReconnect,
    );
  }
}