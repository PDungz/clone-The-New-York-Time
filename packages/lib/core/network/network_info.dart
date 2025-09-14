// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:packages/core/service/logger_service.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectionStream;
  Future<bool> hasInternetAccess();
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  StreamController<bool>? _connectionStreamController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _lastConnectionStatus = false;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _initializeConnectionStream();
  }

  void _initializeConnectionStream() {
    _connectionStreamController = StreamController<bool>.broadcast();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final hasConnection = await _checkConnection(results);
      if (hasConnection != _lastConnectionStatus) {
        _lastConnectionStatus = hasConnection;
        _connectionStreamController?.add(hasConnection);
        printI('[NetworkInfo] Connection status changed: $hasConnection');
      }
    });
  }

  Future<bool> _checkConnection(List<ConnectivityResult> results) async {
    // Check if any result indicates connectivity
    final hasConnectivity = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasConnectivity) return false;

    // Verify actual internet access
    return await hasInternetAccess();
  }

  @override
  Future<bool> get isConnected async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return await _checkConnection(connectivityResults);
    } catch (e) {
      printE('[NetworkInfo] Error checking connectivity: $e');
      return false;
    }
  }

  @override
  Stream<bool> get connectionStream {
    return _connectionStreamController?.stream ?? Stream.empty();
  }

  @override
  Future<bool> hasInternetAccess() async {
    try {
      // Try to reach multiple reliable endpoints
      final endpoints = [
        'google.com',
        'cloudflare.com',
        '8.8.8.8', // Google DNS
      ];

      for (final endpoint in endpoints) {
        try {
          final result = await InternetAddress.lookup(
            endpoint,
          ).timeout(Duration(seconds: 5));

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            printI('[NetworkInfo] Internet access confirmed via $endpoint');
            return true;
          }
        } catch (e) {
          printW('[NetworkInfo] Failed to reach $endpoint: $e');
          continue;
        }
      }

      printW('[NetworkInfo] No internet access detected');
      return false;
    } catch (e) {
      printE('[NetworkInfo] Error checking internet access: $e');
      return false;
    }
  }

  // Get detailed connectivity information
  Future<ConnectivityInfo> getConnectivityInfo() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInternet = await hasInternetAccess();

      return ConnectivityInfo(
        connectivityResults: results,
        hasInternetAccess: hasInternet,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      printE('[NetworkInfo] Error getting connectivity info: $e');
      return ConnectivityInfo(
        connectivityResults: [ConnectivityResult.none],
        hasInternetAccess: false,
        timestamp: DateTime.now(),
      );
    }
  }

  // Test connection with custom timeout
  Future<bool> testConnection({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      printE('[NetworkInfo] Connection test failed: $e');
      return false;
    }
  }

  // Get connection type
  Future<ConnectionType> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectionType.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        return ConnectionType.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectionType.ethernet;
      } else {
        return ConnectionType.none;
      }
    } catch (e) {
      printE('[NetworkInfo] Error getting connection type: $e');
      return ConnectionType.none;
    }
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStreamController?.close();
  }
}

class ConnectivityInfo {
  final List<ConnectivityResult> connectivityResults;
  final bool hasInternetAccess;
  final DateTime timestamp;

  ConnectivityInfo({
    required this.connectivityResults,
    required this.hasInternetAccess,
    required this.timestamp,
  });

  bool get isConnected => hasInternetAccess;

  bool get hasWifi => connectivityResults.contains(ConnectivityResult.wifi);
  bool get hasMobile => connectivityResults.contains(ConnectivityResult.mobile);
  bool get hasEthernet =>
      connectivityResults.contains(ConnectivityResult.ethernet);

  @override
  String toString() {
    return 'ConnectivityInfo(results: $connectivityResults, hasInternet: $hasInternetAccess, timestamp: $timestamp)';
  }
}

enum ConnectionType { wifi, mobile, ethernet, none }

// Network policy for different connection types
class NetworkPolicy {
  final bool allowCaching;
  final bool allowImageDownload;
  final bool allowVideoDownload;
  final Duration cacheRetention;

  const NetworkPolicy({
    required this.allowCaching,
    required this.allowImageDownload,
    required this.allowVideoDownload,
    required this.cacheRetention,
  });

  static const NetworkPolicy wifi = NetworkPolicy(
    allowCaching: true,
    allowImageDownload: true,
    allowVideoDownload: true,
    cacheRetention: Duration(days: 7),
  );

  static const NetworkPolicy mobile = NetworkPolicy(
    allowCaching: true,
    allowImageDownload: true,
    allowVideoDownload: false,
    cacheRetention: Duration(days: 3),
  );

  static const NetworkPolicy offline = NetworkPolicy(
    allowCaching: false,
    allowImageDownload: false,
    allowVideoDownload: false,
    cacheRetention: Duration.zero,
  );

  static NetworkPolicy fromConnectionType(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return wifi;
      case ConnectionType.mobile:
        return mobile;
      case ConnectionType.none:
        return offline;
    }
  }
}
