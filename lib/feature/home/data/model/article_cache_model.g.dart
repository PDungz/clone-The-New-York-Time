// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleCacheModelAdapter extends TypeAdapter<ArticleCacheModel> {
  @override
  final int typeId = 10;

  @override
  ArticleCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleCacheModel(
      section: fields[0] as String?,
      subsection: fields[1] as String?,
      title: fields[2] as String?,
      abstract: fields[3] as String?,
      url: fields[4] as String?,
      uri: fields[5] as String?,
      byline: fields[6] as String?,
      itemType: fields[7] as String?,
      updatedDate: fields[8] as String?,
      createdDate: fields[9] as String?,
      publishedDate: fields[10] as String?,
      desFacet: (fields[11] as List?)?.cast<String>(),
      orgFacet: (fields[12] as List?)?.cast<String>(),
      perFacet: (fields[13] as List?)?.cast<String>(),
      geoFacet: (fields[14] as List?)?.cast<String>(),
      multimedia: (fields[15] as List?)?.cast<MultimediaCacheModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArticleCacheModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.section)
      ..writeByte(1)
      ..write(obj.subsection)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.abstract)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.uri)
      ..writeByte(6)
      ..write(obj.byline)
      ..writeByte(7)
      ..write(obj.itemType)
      ..writeByte(8)
      ..write(obj.updatedDate)
      ..writeByte(9)
      ..write(obj.createdDate)
      ..writeByte(10)
      ..write(obj.publishedDate)
      ..writeByte(11)
      ..write(obj.desFacet)
      ..writeByte(12)
      ..write(obj.orgFacet)
      ..writeByte(13)
      ..write(obj.perFacet)
      ..writeByte(14)
      ..write(obj.geoFacet)
      ..writeByte(15)
      ..write(obj.multimedia);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MultimediaCacheModelAdapter extends TypeAdapter<MultimediaCacheModel> {
  @override
  final int typeId = 11;

  @override
  MultimediaCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MultimediaCacheModel(
      url: fields[0] as String?,
      format: fields[1] as String?,
      height: fields[2] as num?,
      width: fields[3] as num?,
      type: fields[4] as String?,
      subtype: fields[5] as String?,
      caption: fields[6] as String?,
      copyright: fields[7] as String?,
      localPath: fields[8] as String?,
      cachedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MultimediaCacheModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.format)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.width)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.subtype)
      ..writeByte(6)
      ..write(obj.caption)
      ..writeByte(7)
      ..write(obj.copyright)
      ..writeByte(8)
      ..write(obj.localPath)
      ..writeByte(9)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultimediaCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
