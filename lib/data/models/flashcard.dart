import 'package:hive_ce/hive.dart';

import 'enums.dart';

part 'flashcard.g.dart';

/// A question/answer study card generated from a [StudyDocument].
@HiveType(typeId: 3)
class Flashcard {
  Flashcard({
    required this.id,
    required this.documentId,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.isReviewed,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String documentId;
  @HiveField(2)
  final String question;
  @HiveField(3)
  final String answer;
  @HiveField(4)
  final Difficulty difficulty;
  @HiveField(5)
  final bool isReviewed;
  @HiveField(6)
  final DateTime createdAt;
}
