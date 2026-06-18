import '../models/quiz_result.dart';
import 'hive_repository.dart';

/// Stores quiz attempt results.
class QuizResultRepository extends HiveRepository<QuizResult> {
  QuizResultRepository(super.box);

  @override
  String idOf(QuizResult item) => item.id;

  List<QuizResult> forQuiz(String quizId) =>
      getAll().where((r) => r.quizId == quizId).toList();

  /// The best (highest ratio) attempt for a quiz, or null if none yet.
  QuizResult? bestForQuiz(String quizId) {
    final list = forQuiz(quizId);
    if (list.isEmpty) return null;
    list.sort((a, b) =>
        (b.score / b.total).compareTo(a.score / a.total));
    return list.first;
  }
}
