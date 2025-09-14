// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:news_app/core/global/device/data/model/location_model.dart';
import 'package:news_app/core/global/device/domain/entities/device.dart';

class DeviceModel {
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
  final LocationModel? location;
  final LocationModel? latestLocation;
  final List<LocationModel>? recentLocations;
  final int? locationCount;
  final bool? isBiometric;
  final String? typeBiometric;

  DeviceModel({
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

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      userId: json['userId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      platform: json['platform'],
      platformVersion: json['platformVersion'],
      appVersion: json['appVersion'],
      deviceIdentifier: json['deviceIdentifier'],
      pushToken: json['pushToken'],
      screenResolution: json['screenResolution'],
      timezone: json['timezone'],
      language: json['language'],
      isPushEnabled: json['isPushEnabled'],
      isActive: json['isActive'],
      isPrimary: json['isPrimary'],
      status: json['status'],
      lastActive: json['lastActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      location: json['location'] != null ? LocationModel.fromJson(json['location']) : null,
      latestLocation:
          json['latestLocation'] != null ? LocationModel.fromJson(json['latestLocation']) : null,
      recentLocations:
          json['recentLocations'] != null
              ? (json['recentLocations'] as List)
                  .map((item) => LocationModel.fromJson(item))
                  .toList()
              : null,
      locationCount: json['locationCount'],
      isBiometric: json['isBiometric'],
      typeBiometric: json['typeBiometric'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (deviceName != null) 'deviceName': deviceName,
      if (deviceType != null) 'deviceType': deviceType,
      if (platform != null) 'platform': platform,
      if (platformVersion != null) 'platformVersion': platformVersion,
      if (appVersion != null) 'appVersion': appVersion,
      if (deviceIdentifier != null) 'deviceIdentifier': deviceIdentifier,
      if (pushToken != null) 'pushToken': pushToken,
      if (screenResolution != null) 'screenResolution': screenResolution,
      if (timezone != null) 'timezone': timezone,
      if (language != null) 'language': language,
      if (isPushEnabled != null) 'isPushEnabled': isPushEnabled,
      if (isActive != null) 'isActive': isActive,
      if (isPrimary != null) 'isPrimary': isPrimary,
      if (status != null) 'status': status,
      if (lastActive != null) 'lastActive': lastActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (location != null) 'location': location!.toJson(),
      if (latestLocation != null) 'latestLocation': latestLocation!.toJson(),
      if (recentLocations != null)
        'recentLocations': recentLocations!.map((item) => item.toJson()).toList(),
      if (locationCount != null) 'locationCount': locationCount,
      if (isBiometric != null) 'isBiometric': isBiometric,
      if (typeBiometric != null) 'typeBiometric': typeBiometric,
    };
  }

  // Convert to Entity
  Device toEntity() {
    return Device(
      id: id,
      userId: userId,
      deviceName: deviceName,
      deviceType: deviceType,
      platform: platform,
      platformVersion: platformVersion,
      appVersion: appVersion,
      deviceIdentifier: deviceIdentifier,
      pushToken: pushToken,
      screenResolution: screenResolution,
      timezone: timezone,
      language: language,
      isPushEnabled: isPushEnabled,
      isActive: isActive,
      isPrimary: isPrimary,
      status: status,
      lastActive: lastActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: location?.toEntity(),
      latestLocation: latestLocation?.toEntity(),
      recentLocations: recentLocations?.map((item) => item.toEntity()).toList(),
      locationCount: locationCount,
      isBiometric: isBiometric,
      typeBiometric: typeBiometric,
    );
  }

  // Convert from Entity
  factory DeviceModel.fromEntity(Device entity) {
    return DeviceModel(
      id: entity.id,
      userId: entity.userId,
      deviceName: entity.deviceName,
      deviceType: entity.deviceType,
      platform: entity.platform,
      platformVersion: entity.platformVersion,
      appVersion: entity.appVersion,
      deviceIdentifier: entity.deviceIdentifier,
      pushToken: entity.pushToken,
      screenResolution: entity.screenResolution,
      timezone: entity.timezone,
      language: entity.language,
      isPushEnabled: entity.isPushEnabled,
      isActive: entity.isActive,
      isPrimary: entity.isPrimary,
      status: entity.status,
      lastActive: entity.lastActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      location: entity.location != null ? LocationModel.fromEntity(entity.location!) : null,
      latestLocation:
          entity.latestLocation != null ? LocationModel.fromEntity(entity.latestLocation!) : null,
      recentLocations:
          entity.recentLocations?.map((item) => LocationModel.fromEntity(item)).toList(),
      locationCount: entity.locationCount,
      isBiometric: entity.isBiometric,
      typeBiometric: entity.typeBiometric,
    );
  }

  DeviceModel copyWith({
    String? id,
    String? userId,
    String? deviceName,
    String? deviceType,
    String? platform,
    String? platformVersion,
    String? appVersion,
    String? deviceIdentifier,
    String? pushToken,
    String? screenResolution,
    String? timezone,
    String? language,
    bool? isPushEnabled,
    bool? isActive,
    bool? isPrimary,
    String? status,
    String? lastActive,
    String? createdAt,
    String? updatedAt,
    LocationModel? location,
    LocationModel? latestLocation,
    List<LocationModel>? recentLocations,
    int? locationCount,
    bool? isBiometric,
    String? typeBiometric,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      platform: platform ?? this.platform,
      platformVersion: platformVersion ?? this.platformVersion,
      appVersion: appVersion ?? this.appVersion,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      pushToken: pushToken ?? this.pushToken,
      screenResolution: screenResolution ?? this.screenResolution,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      isPushEnabled: isPushEnabled ?? this.isPushEnabled,
      isActive: isActive ?? this.isActive,
      isPrimary: isPrimary ?? this.isPrimary,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      latestLocation: latestLocation ?? this.latestLocation,
      recentLocations: recentLocations ?? this.recentLocations,
      locationCount: locationCount ?? this.locationCount,
      isBiometric: isBiometric ?? this.isBiometric,
      typeBiometric: typeBiometric ?? this.typeBiometric,
    );
  }
}