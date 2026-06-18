import '../models/quiz.dart';
import 'hive_repository.dart';

/// Stores generated quizzes.
class QuizRepository extends HiveRepository<Quiz> {
  QuizRepository(super.box);

  @override
  String idOf(Quiz item) => item.id;

  /// The most recent quiz for a document, or null if none yet.
  Quiz? forDocument(String documentId) {
    final list = getAll().where((q) => q.documentId == documentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.isEmpty ? null : list.first;
  }
}
