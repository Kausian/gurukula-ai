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
    this.lastReviewedAt,
    this.nextReviewAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String documentId;
  @HiveField(2)
  final String question;
  @HiveField(3)
  final String answer;

  /// In Revision Mode this holds the student's self-rating (Easy/Medium/Hard).
  /// Before a card is reviewed it is the difficulty from generation.
  @HiveField(4)
  final Difficulty difficulty;
  @HiveField(5)
  final bool isReviewed;
  @HiveField(6)
  final DateTime createdAt;

  /// When the card was last reviewed in Revision Mode (Phase 11A). Nullable so
  /// flashcards saved before this field existed still load (= never reviewed).
  @HiveField(7)
  final DateTime? lastReviewedAt;

  /// When the card is next due for review (Phase 11B spaced practice). Nullable
  /// so cards from before this field existed still load — a null date means the
  /// card is new/unscheduled and therefore due now.
  @HiveField(8)
  final DateTime? nextReviewAt;

  /// Returns a copy with selected fields changed (same id, so it overwrites in
  /// Hive). Used to toggle [isReviewed] and record a revision rating.
  Flashcard copyWith({
    bool? isReviewed,
    Difficulty? difficulty,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return Flashcard(
      id: id,
      documentId: documentId,
      question: question,
      answer: answer,
      difficulty: difficulty ?? this.difficulty,
      isReviewed: isReviewed ?? this.isReviewed,
      createdAt: createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }
}
