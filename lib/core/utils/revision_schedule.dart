import '../../data/models/enums.dart';

/// Simple fixed-interval spaced practice (Phase 11B).
///
/// After a card is rated, its next review is scheduled a flat number of days
/// out — no ease factors or streak math. "Due" is decided on a calendar-day
/// basis (local time) so afternoon reviews don't come due at an odd hour.
class RevisionSchedule {
  const RevisionSchedule._();

  /// Days until the next review for each rating.
  static int intervalDays(Difficulty rating) {
    switch (rating) {
      case Difficulty.hard:
        return 1;
      case Difficulty.medium:
        return 3;
      case Difficulty.easy:
        return 7;
    }
  }

  /// The next review time given when a card was reviewed and how it was rated.
  static DateTime nextReviewFrom(DateTime reviewedAt, Difficulty rating) =>
      reviewedAt.add(Duration(days: intervalDays(rating)));

  /// Whether a card with [nextReviewAt] needs review on/before [asOf]. A null
  /// date (a new or not-yet-scheduled card) is always due.
  static bool isDue(DateTime? nextReviewAt, {required DateTime asOf}) {
    if (nextReviewAt == null) return true;
    return !_dayOf(nextReviewAt.toLocal()).isAfter(_dayOf(asOf));
  }

  /// Whether a scheduled card is past due (strictly before today). New or
  /// unscheduled cards (null) are not "overdue", just new.
  static bool isOverdue(DateTime? nextReviewAt, {required DateTime asOf}) {
    if (nextReviewAt == null) return false;
    return _dayOf(nextReviewAt.toLocal()).isBefore(_dayOf(asOf));
  }

  /// Whether a card is scheduled for a future day (not yet due).
  static bool isUpcoming(DateTime? nextReviewAt, {required DateTime asOf}) {
    if (nextReviewAt == null) return false;
    return _dayOf(nextReviewAt.toLocal()).isAfter(_dayOf(asOf));
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
