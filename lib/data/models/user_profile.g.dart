// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      googleUid: fields[1] as String?,
      email: fields[2] as String?,
      displayName: fields[3] as String?,
      username: fields[4] as String,
      photoUrl: fields[5] as String?,
      studyLevel: fields[6] as String,
      mainSubject: fields[7] as String,
      learningGoal: fields[8] as String,
      preferredLanguage: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.googleUid)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.displayName)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.photoUrl)
      ..writeByte(6)
      ..write(obj.studyLevel)
      ..writeByte(7)
      ..write(obj.mainSubject)
      ..writeByte(8)
      ..write(obj.learningGoal)
      ..writeByte(9)
      ..write(obj.preferredLanguage)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
