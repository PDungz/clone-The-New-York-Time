import 'package:flutter/services.dart';

class BaseNativeService {
  final String channelName;
  late final MethodChannel _methodChannel;
  final Map<String, EventChannel> _eventChannels = {};

  BaseNativeService(this.channelName) {
    _methodChannel = MethodChannel(channelName);
  }

  Future<T?> call<T>(String method, [dynamic arguments]) async {
    try {
      return await _methodChannel.invokeMethod<T>(method, arguments);
    } catch (e) {
      print('Native call error: $e');
      return null;
    }
  }

  Stream<T> stream<T>(String eventChannelName) {
    _eventChannels[eventChannelName] ??= EventChannel(eventChannelName);
    return _eventChannels[eventChannelName]!.receiveBroadcastStream().map<T>((event) => event as T);
  }
}
