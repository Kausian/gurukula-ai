import 'package:hive_ce/hive.dart';

part 'enums.g.dart';

/// How a [StudyDocument] entered the app.
@HiveType(typeId: 7)
enum DocumentType {
  @HiveField(0)
  text,
  @HiveField(1)
  pdf,
  @HiveField(2)
  image,
}

/// The style a [Rewrite] was produced in.
@HiveType(typeId: 8)
enum RewriteTone {
  @HiveField(0)
  simple,
  @HiveField(1)
  formal,
  @HiveField(2)
  short,
  @HiveField(3)
  proofread,
}

/// Difficulty level for flashcards and ideas.
@HiveType(typeId: 9)
enum Difficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

/// The kind of action recorded in an [ActivityEvent]. Powers dashboard stats.
@HiveType(typeId: 10)
enum ActivityType {
  @HiveField(0)
  documentUploaded,
  @HiveField(1)
  summaryCreated,
  @HiveField(2)
  flashcardCreated,
  @HiveField(3)
  ideaSaved,
  @HiveField(4)
  rewriteCreated,
  @HiveField(5)
  quizCompleted,
}

/// The kind of a quiz question.
@HiveType(typeId: 14)
enum QuestionType {
  @HiveField(0)
  multipleChoice,
  @HiveField(1)
  trueFalse,
  @HiveField(2)
  shortAnswer,
}
