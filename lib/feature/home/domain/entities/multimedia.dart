// multimedia.dart - Updated entity
class Multimedia {
  final String? url;
  final String? format;
  final num? height;
  final num? width;
  final String? type;
  final String? subtype;
  final String? caption;
  final String? copyright;

  // Add these fields to support cached media
  final String? localPath;
  final DateTime? cachedAt;

  const Multimedia({
    this.url,
    this.format,
    this.height,
    this.width,
    this.type,
    this.subtype,
    this.caption,
    this.copyright,
    this.localPath,
    this.cachedAt,
  });

  // Get the display URL (local path if available, otherwise original URL)
  String? get displayUrl => (localPath?.isNotEmpty == true) ? localPath : url;

  // Check if media is locally cached
  bool get isLocallyCached => localPath?.isNotEmpty == true;

  // Check if cache is expired (older than 7 days)
  bool get isCacheExpired {
    if (cachedAt == null) return true;
    final now = DateTime.now();
    final difference = now.difference(cachedAt!);
    return difference.inDays > 7;
  }

  // Create copy with cached info
  Multimedia copyWithCache({String? localPath, DateTime? cachedAt}) {
    return Multimedia(
      url: url,
      format: format,
      height: height,
      width: width,
      type: type,
      subtype: subtype,
      caption: caption,
      copyright: copyright,
      localPath: localPath ?? this.localPath,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}
