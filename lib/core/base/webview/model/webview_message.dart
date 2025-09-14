import 'dart:convert';

enum WebViewMessageType {
  pageInfo,
  formSubmit,
  linkClick,
  imageClick,
  scroll,
  error,
  custom,
}

class WebViewMessage {
  final WebViewMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebViewMessage({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  factory WebViewMessage.fromJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      return WebViewMessage(
        type: WebViewMessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => WebViewMessageType.custom,
        ),
        data: json['data'] ?? {},
        timestamp: DateTime.parse(
          json['timestamp'] ?? DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      return WebViewMessage(
        type: WebViewMessageType.error,
        data: {'error': 'Failed to parse message: $e', 'raw': jsonString},
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
