import 'package:news_app/feature/home/domain/entities/multimedia.dart';

class MultimediaModel extends Multimedia {
  MultimediaModel({
    super.url,
    super.format,
    super.height,
    super.width,
    super.type,
    super.subtype,
    super.caption,
    super.copyright,
    super.localPath,
    super.cachedAt,
  });

  factory MultimediaModel.fromJson(Map<String, dynamic> json) {
    return MultimediaModel(
      url: json['url'] as String?,
      format: json['format'] as String?,
      height: json['height'] as num?,
      width: json['width'] as num?,
      type: json['type'] as String?,
      subtype: json['subtype'] as String?,
      caption: json['caption'] as String?,
      copyright: json['copyright'] as String?,
      // Cache fields are typically not included in API responses
      localPath: json['localPath'] as String?,
      cachedAt:
          json['cachedAt'] != null
              ? DateTime.parse(json['cachedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'format': format,
      'height': height,
      'width': width,
      'type': type,
      'subtype': subtype,
      'caption': caption,
      'copyright': copyright,
      'localPath': localPath,
      'cachedAt': cachedAt?.toIso8601String(),
    };
  }

  // Create a copy with updated cache information
  @override
  MultimediaModel copyWithCache({String? localPath, DateTime? cachedAt}) {
    return MultimediaModel(
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

  // Factory method to create from entity with cache info
  factory MultimediaModel.fromEntityWithCache(
    Multimedia multimedia, {
    String? localPath,
    DateTime? cachedAt,
  }) {
    return MultimediaModel(
      url: multimedia.url,
      format: multimedia.format,
      height: multimedia.height,
      width: multimedia.width,
      type: multimedia.type,
      subtype: multimedia.subtype,
      caption: multimedia.caption,
      copyright: multimedia.copyright,
      localPath: localPath,
      cachedAt: cachedAt,
    );
  }
}
