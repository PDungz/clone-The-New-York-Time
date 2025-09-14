import 'package:hive/hive.dart';
import 'package:news_app/feature/home/data/model/article_model.dart';
import 'package:news_app/feature/home/data/model/multimedia_model.dart';

part 'article_cache_model.g.dart';

@HiveType(typeId: 10)
class ArticleCacheModel {
  @HiveField(0)
  final String? section;
  @HiveField(1)
  final String? subsection;
  @HiveField(2)
  final String? title;
  @HiveField(3)
  final String? abstract;
  @HiveField(4)
  final String? url;
  @HiveField(5)
  final String? uri;
  @HiveField(6)
  final String? byline;
  @HiveField(7)
  final String? itemType;
  @HiveField(8)
  final String? updatedDate;
  @HiveField(9)
  final String? createdDate;
  @HiveField(10)
  final String? publishedDate;
  @HiveField(11)
  final List<String>? desFacet;
  @HiveField(12)
  final List<String>? orgFacet;
  @HiveField(13)
  final List<String>? perFacet;
  @HiveField(14)
  final List<String>? geoFacet;
  @HiveField(15)
  final List<MultimediaCacheModel>? multimedia;

  const ArticleCacheModel({
    this.section,
    this.subsection,
    this.title,
    this.abstract,
    this.url,
    this.uri,
    this.byline,
    this.itemType,
    this.updatedDate,
    this.createdDate,
    this.publishedDate,
    this.desFacet,
    this.orgFacet,
    this.perFacet,
    this.geoFacet,
    this.multimedia,
  });

  factory ArticleCacheModel.fromArticleModel(ArticleModel model) {
    return ArticleCacheModel(
      section: model.section,
      subsection: model.subsection,
      title: model.title,
      abstract: model.abstract,
      url: model.url,
      uri: model.uri,
      byline: model.byline,
      itemType: model.itemType,
      updatedDate: model.updatedDate,
      createdDate: model.createdDate,
      publishedDate: model.publishedDate,
      desFacet: model.desFacet,
      orgFacet: model.orgFacet,
      perFacet: model.perFacet,
      geoFacet: model.geoFacet,
      multimedia:
          model.multimedia
              ?.map(
                (m) => MultimediaCacheModel.fromMultimediaModel(
                  m as MultimediaModel,
                ),
              )
              .toList(),
    );
  }

  ArticleModel toArticleModel() {
    return ArticleModel(
      section: section,
      subsection: subsection,
      title: title,
      abstract: abstract,
      url: url,
      uri: uri,
      byline: byline,
      itemType: itemType,
      updatedDate: updatedDate,
      createdDate: createdDate,
      publishedDate: publishedDate,
      desFacet: desFacet,
      orgFacet: orgFacet,
      perFacet: perFacet,
      geoFacet: geoFacet,
      multimedia: multimedia?.map((m) => m.toMultimediaModel()).toList(),
    );
  }
}

@HiveType(typeId: 11)
class MultimediaCacheModel {
  @HiveField(0)
  final String? url;
  @HiveField(1)
  final String? format;
  @HiveField(2)
  final num? height;
  @HiveField(3)
  final num? width;
  @HiveField(4)
  final String? type;
  @HiveField(5)
  final String? subtype;
  @HiveField(6)
  final String? caption;
  @HiveField(7)
  final String? copyright;
  @HiveField(8)
  final String? localPath;
  @HiveField(9)
  final DateTime? cachedAt;

  const MultimediaCacheModel({
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

  factory MultimediaCacheModel.fromMultimediaModel(MultimediaModel model) {
    return MultimediaCacheModel(
      url: model.url,
      format: model.format,
      height: model.height,
      width: model.width,
      type: model.type,
      subtype: model.subtype,
      caption: model.caption,
      copyright: model.copyright,
      localPath: model.localPath,
      cachedAt: model.cachedAt,
    );
  }

  MultimediaModel toMultimediaModel() {
    return MultimediaModel(
      url: url,
      format: format,
      height: height,
      width: width,
      type: type,
      subtype: subtype,
      caption: caption,
      copyright: copyright,
      localPath: localPath,
      cachedAt: cachedAt,
    );
  }

  MultimediaCacheModel copyWith({String? localPath, DateTime? cachedAt}) {
    return MultimediaCacheModel(
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
