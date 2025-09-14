import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Import local notification service
import 'local_notification_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final LocalNotificationService _localNotificationService = LocalNotificationService();
  
  static String? _fcmToken;
  static String? _apnsToken;

  /// Khởi tạo FCM nhanh - chỉ setup listeners và xin quyền
  static Future<void> initialize() async {
    try {
      // Khởi tạo local notification service trước
      await _localNotificationService.initialize();
      
      // Xin quyền nhận notification (iOS) - không chờ
      _messaging
          .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
          )
          .then((settings) {
            debugPrint('User granted permission: ${settings.authorizationStatus}');
          });

      // Setup listeners ngay lập tức
      _setupListeners();

      // Chạy các tác vụ tốn thời gian ở background
      _initializeTokensInBackground();

      debugPrint('Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('FirebaseMessagingService initialization error: $e');
    }
  }

  /// Setup các listeners cho notification
  static void _setupListeners() {
    // Lắng nghe khi app đang foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a message in foreground: ${message.messageId}');
      // Hiển thị notification using local notification service
      _handleForegroundMessage(message);
    });

    // Lắng nghe khi app được mở từ background bởi notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from notification: ${message.messageId}');
      _handleNotificationTap(message);
    });
  }

  /// Khởi tạo tokens ở background để không block UI
  static void _initializeTokensInBackground() {
    Future.microtask(() async {
      await _getFCMToken();
      if (Platform.isIOS) {
        await _getAPNSToken();
      }
    });
  }

  /// Lấy FCM token
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
      // TODO: Gửi token lên server nếu cần
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Lấy APNS token cho iOS với retry logic
  static Future<void> _getAPNSToken() async {
    try {
      _apnsToken = await _messaging.getAPNSToken();

      if (_apnsToken == null) {
        debugPrint('APNS token is null, retrying in background...');
        _retryGetAPNSToken();
      } else {
        debugPrint('APNS Token: $_apnsToken');
      }
    } catch (e) {
      debugPrint('Error getting APNS token: $e');
    }
  }

  /// Retry logic cho APNS token
  static void _retryGetAPNSToken() {
    int retryCount = 0;
    const maxRetries = 10;
    const retryDelay = Duration(milliseconds: 500);

    void retry() {
      if (retryCount >= maxRetries) {
        debugPrint('Max retries reached for APNS token');
        return;
      }

      Future.delayed(retryDelay, () async {
        try {
          _apnsToken = await _messaging.getAPNSToken();
          if (_apnsToken != null) {
            debugPrint('APNS Token received after $retryCount retries: $_apnsToken');
            return;
          }
        } catch (e) {
          debugPrint('Retry $retryCount failed: $e');
        }

        retryCount++;
        retry();
      });
    }

    retry();
  }

  /// Xử lý khi app bị kill và mở từ notification
  static Future<void> handleTerminatedState() async {
    try {
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from terminated by notification: ${initialMessage.messageId}');
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Error handling terminated state: $e');
    }
  }

  /// Xử lý notification khi app ở foreground - SỬ DỤNG LOCAL NOTIFICATION
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message - Title: ${message.notification?.title}');
    debugPrint('Foreground message - Body: ${message.notification?.body}');
    debugPrint('Foreground message - Data: ${message.data}');

    // Sử dụng local notification service để hiển thị notification
    _localNotificationService.showFromRemoteMessage(message);
  }

  /// Xử lý khi user tap vào notification
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped - Title: ${message.notification?.title}');
    debugPrint('Notification tapped - Data: ${message.data}');

    // Xử lý điều hướng dựa trên payload
    _handleNotificationNavigation(message);
  }

  /// Xử lý điều hướng từ notification
  static void _handleNotificationNavigation(RemoteMessage message) {
    try {
      // Kiểm tra click_action trong data
      if (message.data.containsKey('click_action')) {
        String clickAction = message.data['click_action'];
        debugPrint('Navigating to: $clickAction');

        // TODO: Implement navigation logic
        // NavigatorService.navigateTo(clickAction);
      }

      // Kiểm tra screen trong data
      if (message.data.containsKey('screen')) {
        String screen = message.data['screen'];
        debugPrint('Navigating to screen: $screen');

        // TODO: Implement screen navigation
        // NavigatorService.navigateToScreen(screen);
      }

      // Kiểm tra route trong data
      if (message.data.containsKey('route')) {
        String route = message.data['route'];
        debugPrint('Navigating to route: $route');

        // TODO: Implement route navigation
        // NavigatorService.pushNamed(route);
      }
    } catch (e) {
      debugPrint('Error handling notification navigation: $e');
    }
  }

  /// Getter cho FCM token
  static String? get fcmToken => _fcmToken;

  /// Getter cho APNS token
  static String? get apnsToken => _apnsToken;

  /// Refresh token nếu cần
  static Future<void> refreshToken() async {
    await _getFCMToken();
    if (Platform.isIOS) {
      await _getAPNSToken();
    }
  }

  /// Gửi token lên server (implement theo backend của bạn)
  // ignore: unused_element
  static Future<void> _sendTokenToServer(String? token) async {
    if (token == null) return;

    try {
      debugPrint('Sending token to server: $token');
      // TODO: Implement API call để gửi token lên server
      // await ApiService.sendFCMToken(token);
    } catch (e) {
      debugPrint('Error sending token to server: $e');
    }
  }

  /// Phương thức utility để kiểm tra quyền notification
  static Future<bool> hasNotificationPermission() async {
    return await _localNotificationService.hasNotificationPermission();
  }

  /// Phương thức để hiển thị notification test
  static Future<void> showTestNotification() async {
    await _localNotificationService.showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Firebase Messaging Service',
      payload: 'test_payload',
    );
  }

  /// Phương thức để hủy tất cả notifications
  static Future<void> clearAllNotifications() async {
    await _localNotificationService.cancelAllNotifications();
  }

  /// Phương thức để lấy danh sách active notifications
  static Future<List<dynamic>> getActiveNotifications() async {
    return await _localNotificationService.getActiveNotifications();
  }
}
