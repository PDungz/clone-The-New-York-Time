import 'package:news_app/core/base/websocket/base_websocket_service.dart';
import 'package:news_app/core/base/websocket/enum/websocket_status.dart';

class WebSocketManager {
  static WebSocketManager? _instance;
  static WebSocketManager get instance => _instance ??= WebSocketManager._();

  WebSocketManager._();

  final Map<String, BaseWebSocketService> _services = {};

  void registerService(String name, BaseWebSocketService service) {
    _services[name]?.dispose();
    _services[name] = service;
  }

  BaseWebSocketService? getService(String name) {
    return _services[name];
  }

  T? getServiceAs<T extends BaseWebSocketService>(String name) {
    final service = _services[name];
    if (service is T) {
      return service;
    }
    return null;
  }

  Future<void> connectAll() async {
    for (final service in _services.values) {
      await service.connect();
    }
  }

  Future<void> disconnectAll() async {
    for (final service in _services.values) {
      await service.disconnect();
    }
  }

  Future<void> connect(String name) async {
    await _services[name]?.connect();
  }

  Future<void> disconnect(String name) async {
    await _services[name]?.disconnect();
  }

  void disposeService(String name) {
    _services[name]?.dispose();
    _services.remove(name);
  }

  void disposeAll() {
    for (final service in _services.values) {
      service.dispose();
    }
    _services.clear();
  }

  List<String> get serviceNames => _services.keys.toList();

  Map<String, WebSocketConnectionStatus> get allStatuses => {
    for (final entry in _services.entries) entry.key: entry.value.status,
  };
}
