// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:news_app/feature/home/domain/entities/multimedia.dart';

class Article extends Equatable {
  final String? section;
  final String? subsection;
  final String? title;
  final String? abstract;
  final String? url;
  final String? uri;
  final String? byline;
  final String? itemType;
  final String? updatedDate;
  final String? createdDate;
  final String? publishedDate;
  final List<String>? desFacet;
  final List<String>? orgFacet;
  final List<String>? perFacet;
  final List<String>? geoFacet;
  final List<Multimedia>? multimedia;

  const Article({
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

  Article copyWith({
    String? section,
    String? subsection,
    String? title,
    String? abstract,
    String? url,
    String? uri,
    String? byline,
    String? itemType,
    String? updatedDate,
    String? createdDate,
    String? publishedDate,
    List<String>? desFacet,
    List<String>? orgFacet,
    List<String>? perFacet,
    List<String>? geoFacet,
    List<Multimedia>? multimedia,
  }) {
    return Article(
      section: section ?? this.section,
      subsection: subsection ?? this.subsection,
      title: title ?? this.title,
      abstract: abstract ?? this.abstract,
      url: url ?? this.url,
      uri: uri ?? this.uri,
      byline: byline ?? this.byline,
      itemType: itemType ?? this.itemType,
      updatedDate: updatedDate ?? this.updatedDate,
      createdDate: createdDate ?? this.createdDate,
      publishedDate: publishedDate ?? this.publishedDate,
      desFacet: desFacet ?? this.desFacet,
      orgFacet: orgFacet ?? this.orgFacet,
      perFacet: perFacet ?? this.perFacet,
      geoFacet: geoFacet ?? this.geoFacet,
      multimedia: multimedia ?? this.multimedia,
    );
  }

  @override
  List<Object?> get props => [
    section,
    subsection,
    title,
    abstract,
    url,
    uri,
    byline,
    itemType,
    updatedDate,
    createdDate,
    publishedDate,
    desFacet,
    orgFacet,
    perFacet,
    geoFacet,
    multimedia,
  ];
}
