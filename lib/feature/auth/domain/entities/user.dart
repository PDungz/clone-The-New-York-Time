import 'package:equatable/equatable.dart';
import 'package:news_app/feature/auth/domain/enum/user_enum.dart';

abstract class User extends Equatable {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? phone;
  final DateTime? dateOfBirth;
  final UserRole? role;
  final UserStatus? status;
  final SubscriptionType? subscriptionType;
  final SubscriptionStatus? subscriptionStatus;
  final bool? emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final DateTime? lastActivity;

  const User({this.id, this.email, this.firstName, this.lastName, this.gender, this.phone, this.dateOfBirth, this.role, this.status, this.subscriptionType, this.subscriptionStatus, this.emailVerified, this.createdAt, this.updatedAt, this.lastLogin, this.lastActivity});

  // Business logic methods (Pure domain logic với null safety)
  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  bool get hasActiveSubscription => subscriptionStatus == SubscriptionStatus.active;

  bool get isAccountNonExpired => status != UserStatus.deleted && status != UserStatus.banned;

  bool get isAccountNonLocked => status != UserStatus.locked && status != UserStatus.suspended;

  bool get isEnabled => status == UserStatus.active;

  bool get canAccessPremiumFeatures => hasActiveSubscription && (subscriptionType == SubscriptionType.premium || subscriptionType == SubscriptionType.enterprise);

  bool get isAdmin => role == UserRole.admin;

  bool get canModerateContent => role == UserRole.admin || role == UserRole.moderator;

  int get daysSinceCreated {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt!).inDays;
  }

  bool get isNewUser => daysSinceCreated <= 7;

  bool get hasValidEmail => email != null && email!.isNotEmpty && email!.contains('@');

  bool get hasCompleteProfile {
    return firstName != null && lastName != null && email != null && hasValidEmail;
  }

  // Equatable implementation
  @override
  List<Object?> get props => [id, email, firstName, lastName, gender, phone, dateOfBirth, role, status, subscriptionType, subscriptionStatus, emailVerified, createdAt, updatedAt, lastLogin, lastActivity];
}
