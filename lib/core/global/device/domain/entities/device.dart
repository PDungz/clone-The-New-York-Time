import 'package:news_app/core/global/device/domain/entities/location.dart';

class Device {
  final String? id;
  final String? userId;
  final String? deviceName;
  final String? deviceType;
  final String? platform;
  final String? platformVersion;
  final String? appVersion;
  final String? deviceIdentifier;
  final String? pushToken;
  final String? screenResolution;
  final String? timezone;
  final String? language;
  final bool? isPushEnabled;
  final bool? isActive;
  final bool? isPrimary;
  final String? status;
  final String? lastActive;
  final String? createdAt;
  final String? updatedAt;
  final Location? location;
  final Location? latestLocation;
  final List<Location>? recentLocations;
  final int? locationCount;
  final bool? isBiometric;
  final String? typeBiometric;

  Device({
    this.id,
    this.userId,
    this.deviceName,
    this.deviceType,
    this.platform,
    this.platformVersion,
    this.appVersion,
    this.deviceIdentifier,
    this.pushToken,
    this.screenResolution,
    this.timezone,
    this.language,
    this.isPushEnabled,
    this.isActive,
    this.isPrimary,
    this.status,
    this.lastActive,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.latestLocation,
    this.recentLocations,
    this.locationCount,
    this.isBiometric,
    this.typeBiometric,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device &&
        other.id == id &&
        other.userId == userId &&
        other.deviceName == deviceName &&
        other.deviceType == deviceType &&
        other.platform == platform &&
        other.platformVersion == platformVersion &&
        other.appVersion == appVersion &&
        other.deviceIdentifier == deviceIdentifier &&
        other.pushToken == pushToken &&
        other.screenResolution == screenResolution &&
        other.timezone == timezone &&
        other.language == language &&
        other.isPushEnabled == isPushEnabled &&
        other.isActive == isActive &&
        other.isPrimary == isPrimary &&
        other.status == status &&
        other.lastActive == lastActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.location == location &&
        other.latestLocation == latestLocation &&
        other.recentLocations == recentLocations &&
        other.locationCount == locationCount &&
        other.isBiometric == isBiometric &&
        other.typeBiometric == typeBiometric;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        deviceName.hashCode ^
        deviceType.hashCode ^
        platform.hashCode ^
        platformVersion.hashCode ^
        appVersion.hashCode ^
        deviceIdentifier.hashCode ^
        pushToken.hashCode ^
        screenResolution.hashCode ^
        timezone.hashCode ^
        language.hashCode ^
        isPushEnabled.hashCode ^
        isActive.hashCode ^
        isPrimary.hashCode ^
        status.hashCode ^
        lastActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        location.hashCode ^
        latestLocation.hashCode ^
        recentLocations.hashCode ^
        locationCount.hashCode ^
        isBiometric.hashCode ^
        typeBiometric.hashCode;
  }
}
