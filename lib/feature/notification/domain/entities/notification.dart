// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String? id;
  final String? userId;
  final String? categoryId;
  final String? categoryName;
  final String? categoryDisplayName;
  final String? categoryDescription;
  final bool? categoryIsSystem;
  final bool? categoryIsActive;
  final String? title;
  final String? body;
  final String? imageUrl;
  final String? actionUrl;
  final String? priority;
  final String? notificationType;
  final String? scheduledAt;
  final String? sentAt;
  final String? deliveryStatus;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final String? createdAt;
  final String? expiresAt;

  const NotificationEntity({
    this.id,
    this.userId,
    this.categoryId,
    this.categoryName,
    this.categoryDisplayName,
    this.categoryDescription,
    this.categoryIsSystem,
    this.categoryIsActive,
    this.title,
    this.body,
    this.imageUrl,
    this.actionUrl,
    this.priority,
    this.notificationType,
    this.scheduledAt,
    this.sentAt,
    this.deliveryStatus,
    this.errorMessage,
    this.metadata,
    this.createdAt,
    this.expiresAt,
  });

  // ===============================
  // VALIDATION
  // ===============================

  bool get isValid {
    return id?.isNotEmpty == true &&
        userId?.isNotEmpty == true &&
        categoryId?.isNotEmpty == true &&
        title?.isNotEmpty == true &&
        body?.isNotEmpty == true;
  }

  // ===============================
  // BUSINESS LOGIC GETTERS
  // ===============================

  /// Kiểm tra notification đã được đọc chưa
  bool get isRead => deliveryStatus?.toUpperCase() == 'READ';

  /// Kiểm tra notification chưa được đọc
  bool get isUnread => !isRead;

  /// Kiểm tra notification có lỗi không
  bool get hasError => deliveryStatus?.toUpperCase() == 'FAILED' || errorMessage?.isNotEmpty == true;

  /// Kiểm tra notification đang pending
  bool get isPending => deliveryStatus?.toUpperCase() == 'PENDING';

  /// Kiểm tra notification đã gửi thành công
  bool get isSent => deliveryStatus?.toUpperCase() == 'SENT';

  /// Kiểm tra notification là system notification
  bool get isSystem => categoryIsSystem == true;

  /// Kiểm tra notification có hình ảnh không
  bool get hasImage => imageUrl?.isNotEmpty == true;

  /// Kiểm tra notification có action không
  bool get hasAction => actionUrl?.isNotEmpty == true;

  /// Kiểm tra notification có metadata không
  bool get hasMetadata => metadata?.isNotEmpty == true;

  // ===============================
  // DATE & TIME GETTERS
  // ===============================

  /// Parse createdAt thành DateTime
  DateTime? get createdAtDateTime {
    if (createdAt == null || createdAt!.isEmpty) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  /// Parse sentAt thành DateTime
  DateTime? get sentAtDateTime {
    if (sentAt == null || sentAt!.isEmpty) return null;
    try {
      return DateTime.parse(sentAt!);
    } catch (e) {
      return null;
    }
  }

  /// Parse scheduledAt thành DateTime
  DateTime? get scheduledAtDateTime {
    if (scheduledAt == null || scheduledAt!.isEmpty) return null;
    try {
      return DateTime.parse(scheduledAt!);
    } catch (e) {
      return null;
    }
  }

  /// Parse expiresAt thành DateTime
  DateTime? get expiresAtDateTime {
    if (expiresAt == null || expiresAt!.isEmpty) return null;
    try {
      return DateTime.parse(expiresAt!);
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra notification đã hết hạn chưa
  bool get isExpired {
    final expiry = expiresAtDateTime;
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  /// Kiểm tra notification được tạo hôm nay
  bool get isToday {
    final created = createdAtDateTime;
    if (created == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDay = DateTime(created.year, created.month, created.day);
    return createdDay.isAtSameMomentAs(today);
  }

  /// Kiểm tra notification được tạo trong tuần này
  bool get isThisWeek {
    final created = createdAtDateTime;
    if (created == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return created.isAfter(weekStartDate) || created.isAtSameMomentAs(weekStartDate);
  }

  /// Kiểm tra notification được tạo trong tháng này
  bool get isThisMonth {
    final created = createdAtDateTime;
    if (created == null) return false;
    final now = DateTime.now();
    return created.year == now.year && created.month == now.month;
  }

  /// Lấy thời gian tương đối (ago)
  String get timeAgo {
    final created = createdAtDateTime;
    if (created == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(created);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // ===============================
  // PRIORITY & TYPE GETTERS
  // ===============================

  /// Lấy priority enum
  NotificationPriority get priorityEnum {
    switch (priority?.toUpperCase()) {
      case 'LOW':
        return NotificationPriority.low;
      case 'HIGH':
        return NotificationPriority.high;
      default:
        return NotificationPriority.normal;
    }
  }

  /// Lấy notification type enum
  NotificationTypeEnum get notificationTypeEnum {
    switch (notificationType?.toUpperCase()) {
      case 'PUSH':
        return NotificationTypeEnum.push;
      default:
        return NotificationTypeEnum.inApp;
    }
  }

  /// Lấy delivery status enum
  DeliveryStatus get deliveryStatusEnum {
    switch (deliveryStatus?.toUpperCase()) {
      case 'SENT':
        return DeliveryStatus.sent;
      case 'FAILED':
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.pending;
    }
  }

  /// Kiểm tra priority cao
  bool get isHighPriority => priorityEnum == NotificationPriority.high;

  /// Kiểm tra priority thấp
  bool get isLowPriority => priorityEnum == NotificationPriority.low;

  /// Kiểm tra priority bình thường
  bool get isNormalPriority => priorityEnum == NotificationPriority.normal;

  /// Kiểm tra là push notification
  bool get isPushNotification => notificationTypeEnum == NotificationTypeEnum.push;

  /// Kiểm tra là in-app notification
  bool get isInAppNotification => notificationTypeEnum == NotificationTypeEnum.inApp;

  // ===============================
  // METADATA HELPERS
  // ===============================

  /// Lấy metadata value theo key
  T? getMetadata<T>(String key) {
    try {
      return metadata?[key] as T?;
    } catch (e) {
      return null;
    }
  }

  /// Lấy metadata string với default value
  String getMetadataString(String key, [String defaultValue = '']) {
    return getMetadata<String>(key) ?? defaultValue;
  }

  /// Lấy metadata int với default value
  int getMetadataInt(String key, [int defaultValue = 0]) {
    final value = getMetadata(key);
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Lấy metadata bool với default value
  bool getMetadataBool(String key, [bool defaultValue = false]) {
    final value = getMetadata(key);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  /// Lấy action data từ metadata
  Map<String, dynamic>? get actionData {
    return getMetadata<Map<String, dynamic>>('actionData');
  }

  /// Lấy tracking data từ metadata
  Map<String, dynamic>? get trackingData {
    return getMetadata<Map<String, dynamic>>('trackingData');
  }

  // ===============================
  // DISPLAY HELPERS
  // ===============================

  /// Lấy display title (fallback to body nếu title null)
  String get displayTitle => title?.isNotEmpty == true ? title! : (body ?? 'Notification');

  /// Lấy display body (truncate nếu quá dài)
  String getDisplayBody([int maxLength = 100]) {
    if (body == null || body!.isEmpty) return '';
    if (body!.length <= maxLength) return body!;
    return '${body!.substring(0, maxLength)}...';
  }

  /// Lấy category display name (fallback to category name)
  String get displayCategoryName => 
      categoryDisplayName?.isNotEmpty == true 
          ? categoryDisplayName! 
          : (categoryName ?? 'General');

  /// Lấy priority display string
  String get displayPriority {
    switch (priorityEnum) {
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.low:
        return 'Low';
      default:
        return 'Normal';
    }
  }

  /// Lấy status display string
  String get displayStatus {
    switch (deliveryStatusEnum) {
      case DeliveryStatus.sent:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
      default:
        return 'Pending';
    }
  }

  // ===============================
  // EQUATABLE & COPY WITH
  // ===============================

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryId,
    title,
    body,
    priority,
    notificationType,
    deliveryStatus,
    createdAt,
  ];

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? categoryName,
    String? categoryDisplayName,
    String? categoryDescription,
    bool? categoryIsSystem,
    bool? categoryIsActive,
    String? title,
    String? body,
    String? imageUrl,
    String? actionUrl,
    String? priority,
    String? notificationType,
    String? scheduledAt,
    String? sentAt,
    String? deliveryStatus,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    String? createdAt,
    String? expiresAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryDisplayName: categoryDisplayName ?? this.categoryDisplayName,
      categoryDescription: categoryDescription ?? this.categoryDescription,
      categoryIsSystem: categoryIsSystem ?? this.categoryIsSystem,
      categoryIsActive: categoryIsActive ?? this.categoryIsActive,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      priority: priority ?? this.priority,
      notificationType: notificationType ?? this.notificationType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, status: $deliveryStatus, created: $createdAt)';
  }
}

// ===============================
// ENUMS
// ===============================

enum NotificationPriority { low, normal, high }

enum NotificationTypeEnum { inApp, push }

enum DeliveryStatus { pending, sent, failed }