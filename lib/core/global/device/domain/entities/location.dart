class Location {
  final String? id;
  final String? deviceId;
  final String? ipAddress;
  final String? country;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? createdAt;

  Location({
    this.id,
    this.deviceId,
    this.ipAddress,
    this.country,
    this.city,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.ipAddress == ipAddress &&
        other.country == country &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceId.hashCode ^
        ipAddress.hashCode ^
        country.hashCode ^
        city.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        createdAt.hashCode;
  }
}
