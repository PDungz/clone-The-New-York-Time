import 'package:news_app/feature/auth/data/model/user_model.dart';

class AuthResponse {
  final bool? success;
  final String? message;
  final UserModel? userModel;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;
  final DateTime? sessionExpiresAt;
  final int? accessTokenExpiresIn;
  final int? refreshTokenExpiresIn;
  final int? statusCode;

  const AuthResponse({
    this.success,
    this.message,
    this.userModel,
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpiresAt,
    this.refreshTokenExpiresAt,
    this.sessionExpiresAt,
    this.accessTokenExpiresIn,
    this.refreshTokenExpiresIn,
    this.statusCode,
  });

  /// Factory constructor from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      userModel: json['data'] != null 
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>) 
          : null,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] != null
          ? DateTime.tryParse(json['accessTokenExpiresAt'] as String)
          : null,
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] != null
          ? DateTime.tryParse(json['refreshTokenExpiresAt'] as String)
          : null,
      sessionExpiresAt: json['sessionExpiresAt'] != null
          ? DateTime.tryParse(json['sessionExpiresAt'] as String)
          : null,
      accessTokenExpiresIn: json['accessTokenExpiresIn'] as int?,
      refreshTokenExpiresIn: json['refreshTokenExpiresIn'] as int?,
      statusCode: json['statusCode'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (success != null) 'success': success,
      if (message != null) 'message': message,
      if (userModel != null) 'data': userModel!.toJson(),
      if (accessToken != null) 'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (accessTokenExpiresAt != null) 'accessTokenExpiresAt': accessTokenExpiresAt!.toIso8601String(),
      if (refreshTokenExpiresAt != null) 'refreshTokenExpiresAt': refreshTokenExpiresAt!.toIso8601String(),
      if (sessionExpiresAt != null) 'sessionExpiresAt': sessionExpiresAt!.toIso8601String(),
      if (accessTokenExpiresIn != null) 'accessTokenExpiresIn': accessTokenExpiresIn,
      if (refreshTokenExpiresIn != null) 'refreshTokenExpiresIn': refreshTokenExpiresIn,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }

  /// Create a copy with updated fields
  AuthResponse copyWith({
    bool? success,
    String? message,
    UserModel? userModel,
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
    DateTime? sessionExpiresAt,
    int? accessTokenExpiresIn,
    int? refreshTokenExpiresIn,
    int? statusCode,
  }) {
    return AuthResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      userModel: userModel ?? this.userModel,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      sessionExpiresAt: sessionExpiresAt ?? this.sessionExpiresAt,
      accessTokenExpiresIn: accessTokenExpiresIn ?? this.accessTokenExpiresIn,
      refreshTokenExpiresIn: refreshTokenExpiresIn ?? this.refreshTokenExpiresIn,
      statusCode: statusCode ?? this.statusCode,
    );
  }

  /// Check if access token is expired
  bool get isAccessTokenExpired {
    if (accessTokenExpiresAt == null) return true;
    return DateTime.now().isAfter(accessTokenExpiresAt!);
  }

  /// Check if refresh token is expired
  bool get isRefreshTokenExpired {
    if (refreshTokenExpiresAt == null) return true;
    return DateTime.now().isAfter(refreshTokenExpiresAt!);
  }

  /// Check if session is expired
  bool get isSessionExpired {
    if (sessionExpiresAt == null) return true;
    return DateTime.now().isAfter(sessionExpiresAt!);
  }

  /// Get remaining time until access token expires (in seconds)
  int get accessTokenRemainingTime {
    if (accessTokenExpiresAt == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(accessTokenExpiresAt!)) return 0;
    return accessTokenExpiresAt!.difference(now).inSeconds;
  }

  /// Get remaining time until refresh token expires (in seconds)
  int get refreshTokenRemainingTime {
    if (refreshTokenExpiresAt == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(refreshTokenExpiresAt!)) return 0;
    return refreshTokenExpiresAt!.difference(now).inSeconds;
  }

  /// Check if response is successful
  bool get isSuccess => (success == true) && (statusCode != null && statusCode! >= 200 && statusCode! < 300);

  /// Check if has valid access token
  bool get hasValidAccessToken => accessToken != null && accessToken!.isNotEmpty && !isAccessTokenExpired;

  /// Check if has valid refresh token
  bool get hasValidRefreshToken => refreshToken != null && refreshToken!.isNotEmpty && !isRefreshTokenExpired;

  @override
  String toString() {
    final email = userModel?.email ?? 'unknown';
    final tokenPreview = accessToken != null && accessToken!.length > 20 
        ? '${accessToken!.substring(0, 20)}...' 
        : accessToken ?? 'null';
    return 'AuthResponse{success: $success, message: $message, userModel: $email, accessToken: $tokenPreview, statusCode: $statusCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponse &&
        other.success == success &&
        other.message == message &&
        other.userModel == userModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.accessTokenExpiresAt == accessTokenExpiresAt &&
        other.refreshTokenExpiresAt == refreshTokenExpiresAt &&
        other.sessionExpiresAt == sessionExpiresAt &&
        other.accessTokenExpiresIn == accessTokenExpiresIn &&
        other.refreshTokenExpiresIn == refreshTokenExpiresIn &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        userModel.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        accessTokenExpiresAt.hashCode ^
        refreshTokenExpiresAt.hashCode ^
        sessionExpiresAt.hashCode ^
        accessTokenExpiresIn.hashCode ^
        refreshTokenExpiresIn.hashCode ^
        statusCode.hashCode;
  }
}