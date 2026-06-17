// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewrite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewriteAdapter extends TypeAdapter<Rewrite> {
  @override
  final typeId = 4;

  @override
  Rewrite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Rewrite(
      id: fields[0] as String,
      documentId: fields[1] as String,
      originalText: fields[2] as String,
      rewrittenText: fields[3] as String,
      tone: fields[4] as RewriteTone,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Rewrite obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.documentId)
      ..writeByte(2)
      ..write(obj.originalText)
      ..writeByte(3)
      ..write(obj.rewrittenText)
      ..writeByte(4)
      ..write(obj.tone)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewriteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
