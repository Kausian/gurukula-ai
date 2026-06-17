// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyDocumentAdapter extends TypeAdapter<StudyDocument> {
  @override
  final typeId = 1;

  @override
  StudyDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyDocument(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as DocumentType,
      rawText: fields[4] as String,
      cleanedText: fields[5] as String,
      sourceFileName: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudyDocument obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.rawText)
      ..writeByte(5)
      ..write(obj.cleanedText)
      ..writeByte(6)
      ..write(obj.sourceFileName)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
