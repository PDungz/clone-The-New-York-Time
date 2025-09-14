// Configuration class cho category
import 'package:news_app/feature/notification/domain/enum/category_enum.dart';
import 'package:news_app/generated/locales.g.dart';

class CategoryConfig {
  final String displayName;
  final String description;
  final bool isSystem;
  final bool isActive;

  const CategoryConfig({
    required this.displayName,
    required this.description,
    required this.isSystem,
    required this.isActive,
  });
}

extension CategoryEnumExtension on CategoryEnum {
  // Map config cho từng category
  static final Map<CategoryEnum, CategoryConfig> _configMap = {
    CategoryEnum.breaking_news: CategoryConfig(
      displayName: LocaleKeys.notification_breaking_news_displayName.tr,
      description: LocaleKeys.notification_breaking_news_description.tr,
      isSystem: true,
      isActive: true,
    ),
    CategoryEnum.daily_briefing: CategoryConfig(
      displayName: LocaleKeys.notification_daily_briefing_displayName.tr,
      description: LocaleKeys.notification_daily_briefing_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.sports: CategoryConfig(
      displayName: LocaleKeys.notification_sports_displayName.tr,
      description: LocaleKeys.notification_sports_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.business: CategoryConfig(
      displayName: LocaleKeys.notification_business_displayName.tr,
      description: LocaleKeys.notification_business_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.technology: CategoryConfig(
      displayName: LocaleKeys.notification_technology_displayName.tr,
      description: LocaleKeys.notification_technology_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.politics: CategoryConfig(
      displayName: LocaleKeys.notification_politics_displayName.tr,
      description: LocaleKeys.notification_politics_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.world: CategoryConfig(
      displayName: LocaleKeys.notification_world_displayName.tr,
      description: LocaleKeys.notification_world_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.opinion: CategoryConfig(
      displayName: LocaleKeys.notification_opinion_displayName.tr,
      description: LocaleKeys.notification_opinion_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.lifestyle: CategoryConfig(
      displayName: LocaleKeys.notification_lifestyle_displayName.tr,
      description: LocaleKeys.notification_lifestyle_description.tr,
      isSystem: false,
      isActive: true,
    ),
    CategoryEnum.system: CategoryConfig(
      displayName: LocaleKeys.notification_system_displayName.tr,
      description: LocaleKeys.notification_system_description.tr,
      isSystem: true,
      isActive: true,
    ),
  };

  // Getter methods
  CategoryConfig get config => _configMap[this]!;
  String get displayName => _configMap[this]!.displayName;
  String get description => _configMap[this]!.description;
  bool get isSystem => _configMap[this]!.isSystem;
  bool get isActive => _configMap[this]!.isActive;

  // Static helper methods
  static List<CategoryEnum> get activeCategories {
    return CategoryEnum.values.where((category) => category.isActive).toList();
  }

  static List<CategoryEnum> get systemCategories {
    return CategoryEnum.values.where((category) => category.isSystem).toList();
  }

  static List<CategoryEnum> get nonSystemCategories {
    return CategoryEnum.values.where((category) => !category.isSystem).toList();
  }

  // Convert to API response format
  Map<String, dynamic> toApiResponse({String? id}) {
    return {
      'id': id ?? _generateId(),
      'name': name,
      'displayName': displayName,
      'description': description,
      'isSystem': isSystem,
      'isActive': isActive,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Convert all categories to API response list
  static List<Map<String, dynamic>> toApiResponseList({Map<CategoryEnum, String>? categoryIds}) {
    return CategoryEnum.values
        .map((category) => category.toApiResponse(id: categoryIds?[category]))
        .toList();
  }

  // Helper method to generate simple ID (in real app, use uuid package)
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return '${random.substring(0, 8)}-${random.substring(8, 12)}-${random.substring(12, 16)}-${random.substring(16, 20)}-${random.substring(20)}';
  }

  // Create API response with predefined IDs (matching your example)
  static List<Map<String, dynamic>> createDefaultApiResponse() {
    final predefinedIds = {
      CategoryEnum.breaking_news: "58834464-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.daily_briefing: "588345e2-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.sports: "58834660-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.business: "588346a4-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.technology: "588346df-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.politics: "58834719-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.world: "58834750-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.opinion: "58834799-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.lifestyle: "588347e4-69ed-11f0-9123-82837fe26fac",
      CategoryEnum.system: "5883481f-69ed-11f0-9123-82837fe26fac",
    };

    return toApiResponseList(categoryIds: predefinedIds);
  }
}

// Helper class để làm việc với categories
class CategoryHelper {
  // Find category by name
  static CategoryEnum? findByName(String name) {
    try {
      return CategoryEnum.values.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // Find category by display name
  static CategoryEnum? findByDisplayName(String displayName) {
    try {
      return CategoryEnum.values.firstWhere((category) => category.displayName == displayName);
    } catch (e) {
      return null;
    }
  }

  // Get categories filtered by criteria
  static List<CategoryEnum> getCategories({bool? isSystem, bool? isActive}) {
    return CategoryEnum.values.where((category) {
      if (isSystem != null && category.isSystem != isSystem) return false;
      if (isActive != null && category.isActive != isActive) return false;
      return true;
    }).toList();
  }
}
