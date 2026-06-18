// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final typeId = 7;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.text;
      case 1:
        return DocumentType.pdf;
      case 2:
        return DocumentType.image;
      default:
        return DocumentType.text;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.text:
        writer.writeByte(0);
      case DocumentType.pdf:
        writer.writeByte(1);
      case DocumentType.image:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewriteToneAdapter extends TypeAdapter<RewriteTone> {
  @override
  final typeId = 8;

  @override
  RewriteTone read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewriteTone.simple;
      case 1:
        return RewriteTone.formal;
      case 2:
        return RewriteTone.short;
      case 3:
        return RewriteTone.proofread;
      default:
        return RewriteTone.simple;
    }
  }

  @override
  void write(BinaryWriter writer, RewriteTone obj) {
    switch (obj) {
      case RewriteTone.simple:
        writer.writeByte(0);
      case RewriteTone.formal:
        writer.writeByte(1);
      case RewriteTone.short:
        writer.writeByte(2);
      case RewriteTone.proofread:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewriteToneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final typeId = 9;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.easy;
      case 1:
        return Difficulty.medium;
      case 2:
        return Difficulty.hard;
      default:
        return Difficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.easy:
        writer.writeByte(0);
      case Difficulty.medium:
        writer.writeByte(1);
      case Difficulty.hard:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityTypeAdapter extends TypeAdapter<ActivityType> {
  @override
  final typeId = 10;

  @override
  ActivityType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityType.documentUploaded;
      case 1:
        return ActivityType.summaryCreated;
      case 2:
        return ActivityType.flashcardCreated;
      case 3:
        return ActivityType.ideaSaved;
      case 4:
        return ActivityType.rewriteCreated;
      case 5:
        return ActivityType.quizCompleted;
      default:
        return ActivityType.documentUploaded;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityType obj) {
    switch (obj) {
      case ActivityType.documentUploaded:
        writer.writeByte(0);
      case ActivityType.summaryCreated:
        writer.writeByte(1);
      case ActivityType.flashcardCreated:
        writer.writeByte(2);
      case ActivityType.ideaSaved:
        writer.writeByte(3);
      case ActivityType.rewriteCreated:
        writer.writeByte(4);
      case ActivityType.quizCompleted:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final typeId = 14;

  @override
  QuestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestionType.multipleChoice;
      case 1:
        return QuestionType.trueFalse;
      case 2:
        return QuestionType.shortAnswer;
      default:
        return QuestionType.multipleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.multipleChoice:
        writer.writeByte(0);
      case QuestionType.trueFalse:
        writer.writeByte(1);
      case QuestionType.shortAnswer:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
