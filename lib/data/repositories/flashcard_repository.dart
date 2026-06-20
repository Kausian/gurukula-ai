import '../../core/utils/revision_schedule.dart';
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

  /// Cards needing review now (Phase 11B): new/unscheduled and due/overdue
  /// cards, most overdue first. New cards (no schedule) sort last among due.
  List<Flashcard> dueCards({DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    final due = getAll()
        .where((f) => RevisionSchedule.isDue(f.nextReviewAt, asOf: now))
        .toList()
      ..sort((a, b) {
        final an = a.nextReviewAt, bn = b.nextReviewAt;
        if (an == null && bn == null) return 0;
        if (an == null) return 1; // new cards after scheduled-due cards
        if (bn == null) return -1;
        return an.compareTo(bn); // most overdue first
      });
    return due;
  }

  int dueCount({DateTime? asOf}) => dueCards(asOf: asOf).length;

  int overdueCount({DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    return getAll()
        .where((f) => RevisionSchedule.isOverdue(f.nextReviewAt, asOf: now))
        .length;
  }

  int upcomingCount({DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    return getAll()
        .where((f) => RevisionSchedule.isUpcoming(f.nextReviewAt, asOf: now))
        .length;
  }
}
