// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyGoalAdapter extends TypeAdapter<StudyGoal> {
  @override
  final typeId = 15;

  @override
  StudyGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyGoal(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      subject: fields[3] as String,
      targetDate: fields[4] as DateTime,
      description: fields[5] as String,
      status: fields[6] as StudyGoalStatus,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      documentId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StudyGoal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.targetDate)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.documentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StudyGoalStatusAdapter extends TypeAdapter<StudyGoalStatus> {
  @override
  final typeId = 16;

  @override
  StudyGoalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StudyGoalStatus.notStarted;
      case 1:
        return StudyGoalStatus.inProgress;
      case 2:
        return StudyGoalStatus.ready;
      default:
        return StudyGoalStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, StudyGoalStatus obj) {
    switch (obj) {
      case StudyGoalStatus.notStarted:
        writer.writeByte(0);
      case StudyGoalStatus.inProgress:
        writer.writeByte(1);
      case StudyGoalStatus.ready:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyGoalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
