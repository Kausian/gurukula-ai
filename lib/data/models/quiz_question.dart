import 'package:hive_ce/hive.dart';

import 'enums.dart';

part 'quiz_question.g.dart';

/// One question in a [Quiz].
///
/// For multiple choice, [options] holds the choices and [correctAnswer] is the
/// correct option's text. For true/false, [options] is ['True', 'False']. For
/// short answer, [options] is empty and [correctAnswer] is the reference text.
@HiveType(typeId: 12)
class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final QuestionType type;
  @HiveField(2)
  final String prompt;
  @HiveField(3)
  final List<String> options;
  @HiveField(4)
  final String correctAnswer;
  @HiveField(5)
  final String? explanation;
}
