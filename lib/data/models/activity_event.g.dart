// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityEventAdapter extends TypeAdapter<ActivityEvent> {
  @override
  final typeId = 6;

  @override
  ActivityEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityEvent(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as ActivityType,
      referenceId: fields[3] as String,
      title: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.referenceId)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
