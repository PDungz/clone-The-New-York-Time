import 'package:news_app/core/global/device/domain/entities/location.dart';

class LocationModel {
  final String? id;
  final String? deviceId;
  final String? ipAddress;
  final String? country;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? createdAt;

  LocationModel({
    this.id,
    this.deviceId,
    this.ipAddress,
    this.country,
    this.city,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      deviceId: json['deviceId'],
      ipAddress: json['ipAddress'],
      country: json['country'],
      city: json['city'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (deviceId != null) 'deviceId': deviceId,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (country != null) 'country': country,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  // Convert to Entity
  Location toEntity() {
    return Location(
      id: id,
      deviceId: deviceId,
      ipAddress: ipAddress,
      country: country,
      city: city,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
    );
  }

  // Convert from Entity
  factory LocationModel.fromEntity(Location entity) {
    return LocationModel(
      id: entity.id,
      deviceId: entity.deviceId,
      ipAddress: entity.ipAddress,
      country: entity.country,
      city: entity.city,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
    );
  }
}
