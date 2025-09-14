import 'package:news_app/feature/auth/domain/entities/User.dart';
import 'package:news_app/feature/auth/domain/enum/user_enum.dart';
import 'package:news_app/feature/auth/domain/extension/user_extension.dart';

class UserModel extends User {
  final String? password; // Chỉ dùng cho request
  final String? userId; // Từ response (alias cho id)

  const UserModel({
    super.id,
    super.email,
    super.firstName,
    super.lastName,
    super.gender,
    super.phone,
    super.dateOfBirth,
    super.role,
    super.status,
    super.subscriptionType,
    super.subscriptionStatus,
    super.emailVerified,
    super.createdAt,
    super.updatedAt,
    super.lastLogin,
    super.lastActivity,
    this.password,
    this.userId,
  });

  // Factory constructor from JSON (phù hợp với response format)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['userId'] as String?,
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      role: json['role'] != null 
          ? UserRoleExtension.fromApiValue(json['role'] as String)
          : null,
      status: json['status'] != null 
          ? UserStatusExtension.fromApiValue(json['status'] as String)
          : null,
      subscriptionType: json['subscriptionType'] != null 
          ? SubscriptionTypeExtension.fromApiValue(json['subscriptionType'] as String)
          : null,
      subscriptionStatus: json['subscriptionStatus'] != null 
          ? SubscriptionStatusExtension.fromApiValue(json['subscriptionStatus'] as String)
          : null,
      emailVerified: json['emailVerified'] as bool?,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'] as String)
          : null,
      lastActivity: json['lastActivity'] != null 
          ? DateTime.tryParse(json['lastActivity'] as String)
          : null,
      password: json['password'] as String?,
    );
  }

  // Convert to JSON for REQUEST (format như example request)
  Map<String, dynamic> toJsonRequest() {
    final Map<String, dynamic> data = {};
    
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (gender != null) data['gender'] = gender;
    if (phone != null) data['phone'] = phone;
    if (dateOfBirth != null) {
      // Format: "2003-06-03" cho request
      data['dateOfBirth'] = dateOfBirth!.toIso8601String().split('T')[0];
    }
    if (role != null) data['role'] = role!.apiValue;
    if (status != null) data['status'] = status!.apiValue;
    if (subscriptionType != null) data['subscriptionType'] = subscriptionType!.apiValue;
    if (subscriptionStatus != null) data['subscriptionStatus'] = subscriptionStatus!.apiValue;
    if (emailVerified != null) data['emailVerified'] = emailVerified;
    
    return data;
  }

  // Convert to JSON (bao gồm cả response fields)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (userId != null) data['userId'] = userId;
    if (email != null) data['email'] = email;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (gender != null) data['gender'] = gender;
    if (phone != null) data['phone'] = phone;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (role != null) data['role'] = role!.apiValue;
    if (status != null) data['status'] = status!.apiValue;
    if (subscriptionType != null) data['subscriptionType'] = subscriptionType!.apiValue;
    if (subscriptionStatus != null) data['subscriptionStatus'] = subscriptionStatus!.apiValue;
    if (emailVerified != null) data['emailVerified'] = emailVerified;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (lastLogin != null) data['lastLogin'] = lastLogin!.toIso8601String();
    if (lastActivity != null) data['lastActivity'] = lastActivity!.toIso8601String();
    if (password != null) data['password'] = password;
    
    return data;
  }

  // Convert from Entity to Model
  factory UserModel.fromEntity(User entity, {
    String? password,
    String? passwordHash,
    String? userId,
  }) {
    return UserModel(
      id: entity.id,
      userId: userId,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      gender: entity.gender,
      phone: entity.phone,
      dateOfBirth: entity.dateOfBirth,
      role: entity.role,
      status: entity.status,
      subscriptionType: entity.subscriptionType,
      subscriptionStatus: entity.subscriptionStatus,
      emailVerified: entity.emailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLogin: entity.lastLogin,
      lastActivity: entity.lastActivity,
      password: password,
    );
  }

  // Convert to Entity
  User toEntity() {
    return UserModel(
      id: id ?? userId,
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      phone: phone,
      dateOfBirth: dateOfBirth,
      role: role,
      status: status,
      subscriptionType: subscriptionType,
      subscriptionStatus: subscriptionStatus,
      emailVerified: emailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLogin: lastLogin,
      lastActivity: lastActivity,
      password: password,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? phone,
    DateTime? dateOfBirth,
    UserRole? role,
    UserStatus? status,
    SubscriptionType? subscriptionType,
    SubscriptionStatus? subscriptionStatus,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    DateTime? lastActivity,
    String? password,
    String? passwordHash,
  }) {
    return UserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      status: status ?? this.status,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      lastActivity: lastActivity ?? this.lastActivity,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        password,
        userId,
      ];
}
