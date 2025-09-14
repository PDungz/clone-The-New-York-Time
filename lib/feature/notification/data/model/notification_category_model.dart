import 'package:news_app/feature/notification/domain/entities/notification_category.dart';

class NotificationCategoryModel extends NotificationCategory {
  const NotificationCategoryModel({
    super.id,
    super.name,
    super.displayName,
    super.description,
    super.isSystem,
    super.isActive,
    super.createdAt,
  });

  // Factory constructor from JSON
  factory NotificationCategoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NotificationCategoryModel();

    return NotificationCategoryModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      displayName: json['displayName']?.toString(),
      description: json['description']?.toString(),
      isSystem: json['isSystem'] is bool ? json['isSystem'] : null,
      isActive: json['isActive'] is bool ? json['isActive'] : null,
      createdAt: json['createdAt']?.toString(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (displayName != null) data['displayName'] = displayName;
    if (description != null) data['description'] = description;
    if (isSystem != null) data['isSystem'] = isSystem;
    if (isActive != null) data['isActive'] = isActive;
    if (createdAt != null) data['createdAt'] = createdAt;

    return data;
  }

  // Factory from Entity
  factory NotificationCategoryModel.fromEntity(NotificationCategory entity) {
    return NotificationCategoryModel(
      id: entity.id,
      name: entity.name,
      displayName: entity.displayName,
      description: entity.description,
      isSystem: entity.isSystem,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  // Convert to Entity
  NotificationCategory toEntity() {
    return NotificationCategory(
      id: id,
      name: name,
      displayName: displayName,
      description: description,
      isSystem: isSystem,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  // Date parsing helper
  DateTime? get createdAtDateTime {
    if (createdAt == null || createdAt!.isEmpty) return null;
    try {
      return DateTime.parse(createdAt!);
    } catch (e) {
      return null;
    }
  }

  // Business logic properties
  bool get isSystemCategory => isSystem == true;
  bool get isUserCategory => isSystem != true;
  bool get isActiveCategory => isActive == true;

  // Copy with method
  NotificationCategoryModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    bool? isSystem,
    bool? isActive,
    String? createdAt,
  }) {
    return NotificationCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationCategoryModel(id: $id, displayName: $displayName, isSystem: $isSystem)';
  }
}
