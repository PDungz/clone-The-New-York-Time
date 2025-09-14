// Enums for type safety
import 'package:news_app/feature/notification/domain/entities/notification.dart';

enum NotificationPriority { low, normal, high }

enum NotificationType { inApp, push }

enum DeliveryStatus { pending, sent, failed }

class NotificationModel extends NotificationEntity {
  NotificationModel({
    super.id,
    super.userId,
    super.categoryId,
    super.categoryName,
    super.categoryDisplayName,
    super.categoryDescription,
    super.categoryIsSystem,
    super.categoryIsActive,
    super.title,
    super.body,
    super.imageUrl,
    super.actionUrl,
    super.priority,
    super.notificationType,
    super.scheduledAt,
    super.sentAt,
    super.deliveryStatus,
    super.errorMessage,
    Map<String, dynamic>? metadata,
    super.createdAt,
    super.expiresAt,
  }) : super(metadata: metadata ?? {});

  // Factory constructor from JSON
  factory NotificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return  NotificationModel();

    return NotificationModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      categoryDisplayName: json['categoryDisplayName']?.toString(),
      categoryDescription: json['categoryDescription']?.toString(),
      categoryIsSystem: json['categoryIsSystem'] is bool ? json['categoryIsSystem'] : null,
      categoryIsActive: json['categoryIsActive'] is bool ? json['categoryIsActive'] : null,
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
      priority: json['priority']?.toString(),
      notificationType: json['notificationType']?.toString(),
      scheduledAt: json['scheduledAt']?.toString(),
      sentAt: json['sentAt']?.toString(),
      deliveryStatus: json['deliveryStatus']?.toString(),
      errorMessage: json['errorMessage']?.toString(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: json['createdAt']?.toString(),
      expiresAt: json['expiresAt']?.toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (userId != null) data['userId'] = userId;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (categoryName != null) data['categoryName'] = categoryName;
    if (categoryDisplayName != null) data['categoryDisplayName'] = categoryDisplayName;
    if (categoryDescription != null) data['categoryDescription'] = categoryDescription;
    if (categoryIsSystem != null) data['categoryIsSystem'] = categoryIsSystem;
    if (categoryIsActive != null) data['categoryIsActive'] = categoryIsActive;
    if (title != null) data['title'] = title;
    if (body != null) data['body'] = body;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (actionUrl != null) data['actionUrl'] = actionUrl;
    if (priority != null) data['priority'] = priority;
    if (notificationType != null) data['notificationType'] = notificationType;
    if (scheduledAt != null) data['scheduledAt'] = scheduledAt;
    if (sentAt != null) data['sentAt'] = sentAt;
    if (deliveryStatus != null) data['deliveryStatus'] = deliveryStatus;
    if (errorMessage != null) data['errorMessage'] = errorMessage;
    if (metadata != null) data['metadata'] = metadata;
    if (createdAt != null) data['createdAt'] = createdAt;
    if (expiresAt != null) data['expiresAt'] = expiresAt;

    return data;
  }

  // Factory from Entity (if needed)
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryDisplayName: entity.categoryDisplayName,
      categoryDescription: entity.categoryDescription,
      categoryIsSystem: entity.categoryIsSystem,
      categoryIsActive: entity.categoryIsActive,
      title: entity.title,
      body: entity.body,
      imageUrl: entity.imageUrl,
      actionUrl: entity.actionUrl,
      priority: entity.priority,
      notificationType: entity.notificationType,
      scheduledAt: entity.scheduledAt,
      sentAt: entity.sentAt,
      deliveryStatus: entity.deliveryStatus,
      errorMessage: entity.errorMessage,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
    );
  }

  // Convert to Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryDisplayName: categoryDisplayName,
      categoryDescription: categoryDescription,
      categoryIsSystem: categoryIsSystem,
      categoryIsActive: categoryIsActive,
      title: title,
      body: body,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      priority: priority,
      notificationType: notificationType,
      scheduledAt: scheduledAt,
      sentAt: sentAt,
      deliveryStatus: deliveryStatus,
      errorMessage: errorMessage,
      metadata: metadata,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  // Business logic properties
  bool get isRead => sentAt?.isNotEmpty == true && deliveryStatusEnum == DeliveryStatus.sent;
  bool get isPending => deliveryStatusEnum == DeliveryStatus.pending;
  bool get isFailed => deliveryStatusEnum == DeliveryStatus.failed;
  bool get isSystem => categoryIsSystem == true;
  bool get hasImage => imageUrl?.isNotEmpty == true;
  bool get hasAction => actionUrl?.isNotEmpty == true;
  bool get hasError => errorMessage?.isNotEmpty == true;

  // Date parsing helpers
  DateTime? get createdAtDateTime {
    if (createdAt == null || createdAt!.isEmpty) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  DateTime? get sentAtDateTime {
    if (sentAt == null || sentAt!.isEmpty) return null;
    try {
      return DateTime.parse(sentAt!);
    } catch (e) {
      return null;
    }
  }

  DateTime? get expiresAtDateTime {
    if (expiresAt == null || expiresAt!.isEmpty) return null;
    try {
      return DateTime.parse(expiresAt!);
    } catch (e) {
      return null;
    }
  }

  bool get isExpired {
    final expiry = expiresAtDateTime;
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  bool get isToday {
    final created = createdAtDateTime;
    if (created == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return created.isAfter(today);
  }

  bool get isThisWeek {
    final created = createdAtDateTime;
    if (created == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return created.isAfter(weekStartDate);
  }

  // Safe metadata access
  T? getMetadata<T>(String key) {
    try {
      return metadata?[key] as T?;
    } catch (e) {
      return null;
    }
  }

  String getMetadataString(String key, [String defaultValue = '']) {
    return getMetadata<String>(key) ?? defaultValue;
  }

  int getMetadataInt(String key, [int defaultValue = 0]) {
    final value = getMetadata(key);
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool getMetadataBool(String key, [bool defaultValue = false]) {
    final value = getMetadata(key);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  // Copy with method
  NotificationModel copyWith({
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
    return NotificationModel(
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
    return 'NotificationModel(id: $id, title: $title, status: $deliveryStatus)';
  }
}
