// Tests for Phase 11A Revision Mode: recording a review rating and the Home
// revision stats. Uses real Hive boxes in a temp dir (like the smoke test).

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/models/activity_event.dart';
import 'package:gurukula_ai/data/models/flashcard.dart';
import 'package:gurukula_ai/data/models/idea.dart';
import 'package:gurukula_ai/data/models/rewrite.dart';
import 'package:gurukula_ai/data/models/study_document.dart';
import 'package:gurukula_ai/data/models/summary.dart';
import 'package:gurukula_ai/data/models/user_profile.dart';
import 'package:gurukula_ai/data/models/enums.dart';
import 'package:gurukula_ai/data/providers.dart';
import 'package:gurukula_ai/features/study/study_providers.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

Flashcard _card(String id) => Flashcard(
      id: id,
      documentId: 'doc1',
      question: 'Q $id',
      answer: 'A $id',
      difficulty: Difficulty.medium,
      isReviewed: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_revision');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
    await Future.wait([
      Hive.openBox<UserProfile>(HiveBoxes.profiles),
      Hive.openBox<StudyDocument>(HiveBoxes.documents),
      Hive.openBox<Summary>(HiveBoxes.summaries),
      Hive.openBox<Flashcard>(HiveBoxes.flashcards),
      Hive.openBox<Rewrite>(HiveBoxes.rewrites),
      Hive.openBox<Idea>(HiveBoxes.ideas),
      Hive.openBox<ActivityEvent>(HiveBoxes.activity),
      Hive.openBox<dynamic>(HiveBoxes.settings),
    ]);
  });

  tearDown(() async {
    await Hive.box<Flashcard>(HiveBoxes.flashcards).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('recordReview marks the card reviewed, stores rating and timestamp',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(flashcardRepositoryProvider);
    await repo.save(_card('c1'));

    await container
        .read(studyControllerProvider)
        .recordReview(repo.getById('c1')!, Difficulty.hard);

    final updated = repo.getById('c1')!;
    expect(updated.isReviewed, isTrue);
    expect(updated.difficulty, Difficulty.hard);
    expect(updated.lastReviewedAt, isNotNull);
  });

  test('recordReview schedules nextReviewAt by the rating interval', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(flashcardRepositoryProvider);
    await repo.save(_card('c1'));
    final controller = container.read(studyControllerProvider);

    await controller.recordReview(repo.getById('c1')!, Difficulty.easy);
    final card = repo.getById('c1')!;
    final days =
        card.nextReviewAt!.difference(card.lastReviewedAt!).inDays;
    expect(days, 7); // Easy = +7 days
  });

  test('due/overdue/upcoming counts reflect schedules', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(flashcardRepositoryProvider);

    // new card (no schedule) -> due
    await repo.save(_card('new'));
    // overdue card
    await repo.save(_card('past')
        .copyWith(isReviewed: true, nextReviewAt: DateTime.utc(2020, 1, 1)));
    // upcoming card
    await repo.save(_card('future')
        .copyWith(isReviewed: true, nextReviewAt: DateTime.utc(2999, 1, 1)));

    expect(repo.dueCount(), 2); // new + overdue
    expect(repo.overdueCount(), 1); // only the past one
    expect(repo.upcomingCount(), 1); // only the future one
    // overdue sorts before the new (unscheduled) card.
    expect(repo.dueCards().first.id, 'past');
  });

  test('revision stats count reviewed and hard cards', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(flashcardRepositoryProvider);
    await repo.save(_card('c1'));
    await repo.save(_card('c2'));
    await repo.save(_card('c3')); // left unreviewed

    final controller = container.read(studyControllerProvider);
    await controller.recordReview(repo.getById('c1')!, Difficulty.hard);
    await controller.recordReview(repo.getById('c2')!, Difficulty.easy);

    final stats = container.read(revisionStatsProvider);
    expect(stats.reviewed, 2);
    expect(stats.hard, 1);
    expect(stats.recent.length, 2);
  });

  test('an old flashcard without lastReviewedAt still loads', () async {
    final repo =
        FlashcardRepositoryTestAccess(Hive.box<Flashcard>(HiveBoxes.flashcards));
    await repo.box.put('old', _card('old')); // lastReviewedAt is null
    final loaded = repo.box.get('old')!;
    expect(loaded.lastReviewedAt, isNull);
    expect(loaded.isReviewed, isFalse);
  });
}

/// Minimal box access for the backward-compat load test.
class FlashcardRepositoryTestAccess {
  FlashcardRepositoryTestAccess(this.box);
  final Box<Flashcard> box;
}
