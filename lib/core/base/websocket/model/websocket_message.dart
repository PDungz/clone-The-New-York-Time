import 'dart:convert';

class WebSocketMessage {
  final String? type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final int? serverTime;

  WebSocketMessage({this.type, this.data, DateTime? timestamp, this.serverTime})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (data != null) 'data': data,
      'timestamp': timestamp.toIso8601String(),
      if (serverTime != null) 'serverTime': serverTime,
    };
  }

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      serverTime: json['serverTime'] != null ? int.tryParse(json['serverTime'].toString()) : null,
    );
  }

  factory WebSocketMessage.fromRawJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return WebSocketMessage.fromJson(json);
    } catch (e) {
      // Return raw message if parsing fails
      return WebSocketMessage(type: 'raw', data: {'raw': jsonString, 'error': e.toString()});
    }
  }

  @override
  String toString() {
    return 'WebSocketMessage{type: $type, data: $data, timestamp: $timestamp}';
  }
}
