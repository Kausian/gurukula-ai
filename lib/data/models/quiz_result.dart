import 'package:hive_ce/hive.dart';

part 'quiz_result.g.dart';

/// The outcome of one attempt at a [Quiz].
@HiveType(typeId: 13)
class QuizResult {
  QuizResult({
    required this.id,
    required this.quizId,
    required this.documentId,
    required this.score,
    required this.total,
    required this.answers,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String quizId;
  @HiveField(2)
  final String documentId;
  @HiveField(3)
  final int score;
  @HiveField(4)
  final int total;

  /// The student's answer to each question, in order.
  @HiveField(5)
  final List<String> answers;
  @HiveField(6)
  final DateTime createdAt;
}
