import 'package:news_app/feature/home/data/model/multimedia_model.dart';
import 'package:news_app/feature/home/domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    super.section,
    super.subsection,
    super.title,
    super.abstract,
    super.url,
    super.uri,
    super.byline,
    super.itemType,
    super.updatedDate,
    super.createdDate,
    super.publishedDate,
    super.desFacet,
    super.orgFacet,
    super.perFacet,
    super.geoFacet,
    List<MultimediaModel>? super.multimedia,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      section: json['section'] as String?,
      subsection: json['subsection'] as String?,
      title: json['title'] as String?,
      abstract: json['abstract'] as String?,
      url: json['url'] as String?,
      uri: json['uri'] as String?,
      byline: json['byline'] as String?,
      itemType: json['item_type'] as String?,
      updatedDate: json['updated_date'] as String?,
      createdDate: json['created_date'] as String?,
      publishedDate: json['published_date'] as String?,
      desFacet: (json['des_facet'] as List<dynamic>?)?.cast<String>(),
      orgFacet: (json['org_facet'] as List<dynamic>?)?.cast<String>(),
      perFacet: (json['per_facet'] as List<dynamic>?)?.cast<String>(),
      geoFacet: (json['geo_facet'] as List<dynamic>?)?.cast<String>(),
      multimedia:
          (json['multimedia'] as List<dynamic>?)
              ?.map((e) => MultimediaModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section': section,
      'subsection': subsection,
      'title': title,
      'abstract': abstract,
      'url': url,
      'uri': uri,
      'byline': byline,
      'item_type': itemType,
      'updated_date': updatedDate,
      'created_date': createdDate,
      'published_date': publishedDate,
      'des_facet': desFacet,
      'org_facet': orgFacet,
      'per_facet': perFacet,
      'geo_facet': geoFacet,
      'multimedia':
          multimedia?.map((e) => (e as MultimediaModel).toJson()).toList(),
    };
  }
}
