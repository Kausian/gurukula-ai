import 'package:hive_ce/hive.dart';

import 'quiz_question.dart';

part 'quiz.g.dart';

/// A quiz generated from a [StudyDocument]. Holds its questions inline.
@HiveType(typeId: 11)
class Quiz {
  Quiz({
    required this.id,
    required this.documentId,
    required this.title,
    required this.questions,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String documentId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final List<QuizQuestion> questions;
  @HiveField(4)
  final DateTime createdAt;
}
