import 'package:news_app/feature/auth/domain/enum/user_enum.dart';

extension UserRoleExtension on UserRole {
  String get apiValue {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.user:
        return 'USER';
      case UserRole.moderator:
        return 'MODERATOR';
      case UserRole.editor:
        return 'EDITOR';
    }
  }

  static UserRole fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'USER':
        return UserRole.user;
      case 'MODERATOR':
        return UserRole.moderator;
      case 'EDITOR':
        return UserRole.editor;
      default:
        return UserRole.user;
    }
  }
}

extension UserStatusExtension on UserStatus {
  String get apiValue {
    switch (this) {
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.inactive:
        return 'INACTIVE';
      case UserStatus.suspended:
        return 'SUSPENDED';
      case UserStatus.locked:
        return 'LOCKED';
      case UserStatus.banned:
        return 'BANNED';
      case UserStatus.deleted:
        return 'DELETED';
    }
  }

  static UserStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return UserStatus.active;
      case 'INACTIVE':
        return UserStatus.inactive;
      case 'SUSPENDED':
        return UserStatus.suspended;
      case 'LOCKED':
        return UserStatus.locked;
      case 'BANNED':
        return UserStatus.banned;
      case 'DELETED':
        return UserStatus.deleted;
      default:
        return UserStatus.active;
    }
  }
}

extension SubscriptionTypeExtension on SubscriptionType {
  String get apiValue {
    switch (this) {
      case SubscriptionType.free:
        return 'FREE';
      case SubscriptionType.basic:
        return 'BASIC';
      case SubscriptionType.premium:
        return 'PREMIUM';
      case SubscriptionType.enterprise:
        return 'ENTERPRISE';
    }
  }

  static SubscriptionType fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'FREE':
        return SubscriptionType.free;
      case 'BASIC':
        return SubscriptionType.basic;
      case 'PREMIUM':
        return SubscriptionType.premium;
      case 'ENTERPRISE':
        return SubscriptionType.enterprise;
      default:
        return SubscriptionType.free;
    }
  }
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get apiValue {
    switch (this) {
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.inactive:
        return 'INACTIVE';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
      case SubscriptionStatus.suspended:
        return 'SUSPENDED';
    }
  }

  static SubscriptionStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return SubscriptionStatus.active;
      case 'INACTIVE':
        return SubscriptionStatus.inactive;
      case 'EXPIRED':
        return SubscriptionStatus.expired;
      case 'CANCELLED':
        return SubscriptionStatus.cancelled;
      case 'SUSPENDED':
        return SubscriptionStatus.suspended;
      default:
        return SubscriptionStatus.inactive;
    }
  }
}
