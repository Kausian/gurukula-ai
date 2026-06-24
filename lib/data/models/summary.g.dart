// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SummaryAdapter extends TypeAdapter<Summary> {
  @override
  final typeId = 2;

  @override
  Summary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Summary(
      id: fields[0] as String,
      documentId: fields[1] as String,
      shortSummary: fields[2] as String,
      detailedSummary: fields[3] as String,
      keyPoints: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
      generatedOnDevice: fields[6] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Summary obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.documentId)
      ..writeByte(2)
      ..write(obj.shortSummary)
      ..writeByte(3)
      ..write(obj.detailedSummary)
      ..writeByte(4)
      ..write(obj.keyPoints)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.generatedOnDevice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
