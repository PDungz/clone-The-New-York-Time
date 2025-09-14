import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Khởi tạo service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Khởi tạo timezone
    tz.initializeTimeZones();

    // Cấu hình Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Cấu hình iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Yêu cầu quyền
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('LocalNotificationService initialized successfully');
  }

  // Yêu cầu quyền thông báo
  Future<bool> _requestPermissions() async {
    bool permissionGranted = false;

    try {
      // Xử lý Android
      final androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        permissionGranted = granted ?? false;
        debugPrint('Android notification permission granted: $granted');
      }

      // Xử lý iOS
      final iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        permissionGranted = granted ?? false;
        debugPrint('iOS notification permission granted: $granted');
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      // Nếu có lỗi với permission, vẫn tiếp tục
      permissionGranted = true;
    }

    return permissionGranted;
  }

  // Kiểm tra quyền thông báo
  Future<bool> hasNotificationPermission() async {
    try {
      final androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        return await androidImplementation.areNotificationsEnabled() ?? false;
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return _isInitialized;
    }
  }

  // Xử lý khi người dùng tap vào notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    debugPrint('Notification action: ${response.actionId}');

    // Xử lý navigation hoặc action
    if (response.actionId != null) {
      _handleNotificationAction(response.actionId!, response.payload);
    } else {
      _handleNotificationTap(response.payload);
    }
  }

  // Xử lý tap notification
  void _handleNotificationTap(String? payload) {
    debugPrint('Handle notification tap with payload: $payload');
    // Thêm logic navigation tại đây
  }

  // Xử lý action notification
  void _handleNotificationAction(String actionId, String? payload) {
    debugPrint('Handle notification action: $actionId with payload: $payload');

    switch (actionId) {
      case 'action_accept':
        debugPrint('User accepted');
        break;
      case 'action_decline':
        debugPrint('User declined');
        break;
      default:
        debugPrint('Unknown action: $actionId');
    }
  }

  // Hiển thị notification đơn giản (giống FCM foreground)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    Map<String, dynamic>? data,
    bool silent = false,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel', // Channel ID
      'FCM Notifications', // Channel name
      channelDescription: 'Channel for FCM-like notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: !silent,
      playSound: !silent,
      styleInformation: BigTextStyleInformation(body),
      ticker: 'New notification',
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !silent,
      sound: silent ? null : 'default',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        _generateNotificationId(),
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('Notification shown successfully: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Hiển thị notification với BigText style (cho văn bản dài)
  Future<void> showBigTextNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: 'Tap để xem chi tiết',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Channel for FCM-like notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigTextStyleInformation,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        _generateNotificationId(),
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('Big text notification shown successfully: $title');
    } catch (e) {
      debugPrint('Error showing big text notification: $e');
    }
  }

  // Hiển thị notification với actions
  Future<void> showNotificationWithActions({
    required String title,
    required String body,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final List<AndroidNotificationAction> defaultActions = [
      const AndroidNotificationAction('action_accept', 'Accept', showsUserInterface: true),
      const AndroidNotificationAction('action_decline', 'Decline', showsUserInterface: true),
    ];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Channel for FCM-like notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      actions: actions ?? defaultActions,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'actionCategory',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        _generateNotificationId(),
        title,
        body,
        details,
        payload: payload,
      );
      debugPrint('Action notification shown successfully: $title');
    } catch (e) {
      debugPrint('Error showing action notification: $e');
    }
  }

  // Hiển thị inbox style notification (nhiều dòng)
  Future<void> showInboxStyleNotification({
    required String title,
    required List<String> messages,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      messages,
      contentTitle: title,
      summaryText: '${messages.length} tin nhắn mới',
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Channel for FCM-like notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: inboxStyleInformation,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        _generateNotificationId(),
        title,
        messages.join('\n'),
        details,
        payload: payload,
      );
      debugPrint('Inbox notification shown successfully: $title');
    } catch (e) {
      debugPrint('Error showing inbox notification: $e');
    }
  }

  // Lên lịch notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _generateNotificationId(),
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled notification: $title for ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Tạo notification giống FCM data message
  Future<void> showFCMStyleNotification({required Map<String, dynamic> data}) async {
    final String title = data['title'] ?? 'Notification';
    final String body = data['body'] ?? '';
    final String? clickAction = data['click_action'];

    await showNotification(title: title, body: body, payload: clickAction, data: data);
  }

  // Generate unique notification ID
  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Hủy notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Cancelled notification: $id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  // Hủy tất cả notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Cancelled all notifications');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  // Lấy danh sách pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  // Lấy danh sách active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      final androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.getActiveNotifications() ?? [];
    } catch (e) {
      debugPrint('Error getting active notifications: $e');
      return [];
    }
  }
}

// Extension để dễ sử dụng
extension NotificationHelper on LocalNotificationService {
  // Hiển thị notification từ FCM RemoteMessage
  Future<void> showFromRemoteMessage(dynamic remoteMessage) async {
    try {
      final notification = remoteMessage.notification;
      final data = remoteMessage.data;

      if (notification != null) {
        await showNotification(
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
          payload: data?['click_action'],
          data: data,
        );
      } else if (data != null) {
        await showFCMStyleNotification(data: data);
      }
    } catch (e) {
      debugPrint('Error showing notification from FCM: $e');
    }
  }

  // Hiển thị notification âm thầm (không sound/vibration)
  Future<void> showSilentNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showNotification(title: title, body: body, payload: payload, silent: true);
  }

  // Hiển thị notification với văn bản dài
  Future<void> showLongTextNotification({
    required String title,
    required String longText,
    String? payload,
  }) async {
    if (longText.length > 100) {
      await showBigTextNotification(title: title, body: longText, payload: payload);
    } else {
      await showNotification(title: title, body: longText, payload: payload);
    }
  }
}
