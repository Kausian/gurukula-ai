// Pure unit tests for the Phase 11B spaced-practice scheduler. No Hive or
// widgets — just date math, so day-boundary behaviour is verified directly.

import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/core/utils/revision_schedule.dart';
import 'package:gurukula_ai/data/models/enums.dart';

void main() {
  test('intervals are Hard 1, Medium 3, Easy 7 days', () {
    expect(RevisionSchedule.intervalDays(Difficulty.hard), 1);
    expect(RevisionSchedule.intervalDays(Difficulty.medium), 3);
    expect(RevisionSchedule.intervalDays(Difficulty.easy), 7);
  });

  test('nextReviewFrom adds the right number of days', () {
    final reviewed = DateTime.utc(2026, 6, 20, 14);
    expect(RevisionSchedule.nextReviewFrom(reviewed, Difficulty.hard),
        DateTime.utc(2026, 6, 21, 14));
    expect(RevisionSchedule.nextReviewFrom(reviewed, Difficulty.easy),
        DateTime.utc(2026, 6, 27, 14));
  });

  group('due / overdue / upcoming (calendar-day based)', () {
    final today = DateTime(2026, 6, 20, 10); // local noon-ish

    test('a null schedule (new card) is always due, never overdue/upcoming', () {
      expect(RevisionSchedule.isDue(null, asOf: today), isTrue);
      expect(RevisionSchedule.isOverdue(null, asOf: today), isFalse);
      expect(RevisionSchedule.isUpcoming(null, asOf: today), isFalse);
    });

    test('a card scheduled earlier today is due but not overdue', () {
      final earlierToday = DateTime(2026, 6, 20, 1);
      expect(RevisionSchedule.isDue(earlierToday, asOf: today), isTrue);
      expect(RevisionSchedule.isOverdue(earlierToday, asOf: today), isFalse);
    });

    test('a card scheduled yesterday is due and overdue', () {
      final yesterday = DateTime(2026, 6, 19, 23);
      expect(RevisionSchedule.isDue(yesterday, asOf: today), isTrue);
      expect(RevisionSchedule.isOverdue(yesterday, asOf: today), isTrue);
    });

    test('a card scheduled tomorrow is upcoming, not due', () {
      final tomorrow = DateTime(2026, 6, 21, 0, 1);
      expect(RevisionSchedule.isDue(tomorrow, asOf: today), isFalse);
      expect(RevisionSchedule.isUpcoming(tomorrow, asOf: today), isTrue);
    });
  });
}
