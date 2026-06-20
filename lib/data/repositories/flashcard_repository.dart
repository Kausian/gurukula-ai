import '../models/enums.dart';
import '../models/flashcard.dart';
import 'hive_repository.dart';

/// Stores study flashcards.
class FlashcardRepository extends HiveRepository<Flashcard> {
  FlashcardRepository(super.box);

  @override
  String idOf(Flashcard item) => item.id;

  List<Flashcard> byDocument(String documentId) =>
      getAll().where((f) => f.documentId == documentId).toList();

  int get reviewedCount => getAll().where((f) => f.isReviewed).length;

  /// Reviewed cards the student rated [Difficulty.hard] (Phase 11A revision).
  int get hardReviewedCount =>
      getAll().where((f) => f.isReviewed && f.difficulty == Difficulty.hard).length;

  /// Reviewed cards, most recently reviewed first, limited to [limit].
  List<Flashcard> recentlyReviewed({int limit = 3}) {
    final reviewed = getAll().where((f) => f.lastReviewedAt != null).toList()
      ..sort((a, b) => b.lastReviewedAt!.compareTo(a.lastReviewedAt!));
    return reviewed.take(limit).toList();
  }
}
