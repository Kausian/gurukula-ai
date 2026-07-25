// Tests for the v1.20.0 Study Planner: the days-remaining helper plus the
// goal repository/controller/providers (create, order, update, delete,
// persistence). Uses real Hive boxes in a temp dir, like the other tests.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/core/utils/study_goal_format.dart';
import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/models/activity_event.dart';
import 'package:gurukula_ai/data/models/flashcard.dart';
import 'package:gurukula_ai/data/models/idea.dart';
import 'package:gurukula_ai/data/models/quiz.dart';
import 'package:gurukula_ai/data/models/quiz_result.dart';
import 'package:gurukula_ai/data/models/rewrite.dart';
import 'package:gurukula_ai/data/models/study_document.dart';
import 'package:gurukula_ai/data/models/study_goal.dart';
import 'package:gurukula_ai/data/models/summary.dart';
import 'package:gurukula_ai/data/models/user_profile.dart';
import 'package:gurukula_ai/data/providers.dart';
import 'package:gurukula_ai/features/planner/study_planner_providers.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

void main() {
  group('StudyGoalTime.daysUntil (calendar-day based)', () {
    final now = DateTime(2026, 7, 25, 15, 30);

    test('today is 0, ignoring time of day', () {
      expect(StudyGoalTime.daysUntil(DateTime(2026, 7, 25), now: now), 0);
      expect(StudyGoalTime.remainingLabel(DateTime(2026, 7, 25), now: now),
          'Today');
    });

    test('future and past days', () {
      expect(StudyGoalTime.daysUntil(DateTime(2026, 7, 30), now: now), 5);
      expect(StudyGoalTime.remainingLabel(DateTime(2026, 7, 26), now: now),
          'Tomorrow');
      expect(StudyGoalTime.daysUntil(DateTime(2026, 7, 20), now: now), -5);
      expect(StudyGoalTime.isOverdue(DateTime(2026, 7, 24), now: now), isTrue);
      expect(StudyGoalTime.isOverdue(DateTime(2026, 7, 25), now: now), isFalse);
    });
  });

  group('Study Planner storage', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('gurukula_planner');
      Hive.init(tempDir.path);
      Hive.registerAdapters();
      await Future.wait([
        Hive.openBox<UserProfile>(HiveBoxes.profiles),
        Hive.openBox<StudyDocument>(HiveBoxes.documents),
        Hive.openBox<Summary>(HiveBoxes.summaries),
        Hive.openBox<Flashcard>(HiveBoxes.flashcards),
        Hive.openBox<Rewrite>(HiveBoxes.rewrites),
        Hive.openBox<Idea>(HiveBoxes.ideas),
        Hive.openBox<Quiz>(HiveBoxes.quizzes),
        Hive.openBox<QuizResult>(HiveBoxes.quizResults),
        Hive.openBox<ActivityEvent>(HiveBoxes.activity),
        Hive.openBox<StudyGoal>(HiveBoxes.studyGoals),
        Hive.openBox<dynamic>(HiveBoxes.settings),
      ]);
    });

    tearDown(() async {
      await Hive.box<StudyGoal>(HiveBoxes.studyGoals).clear();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('create persists a goal that can be read back', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(studyPlannerControllerProvider);

      final id = await controller.create(
        title: 'Final exam',
        subject: 'Operating Systems',
        targetDate: DateTime(2026, 12, 1),
        description: 'Cover deadlocks and scheduling.',
        status: StudyGoalStatus.inProgress,
      );

      final goal = container.read(studyGoalRepositoryProvider).getById(id);
      expect(goal, isNotNull);
      expect(goal!.title, 'Final exam');
      expect(goal.subject, 'Operating Systems');
      expect(goal.status, StudyGoalStatus.inProgress);
      expect(goal.description, 'Cover deadlocks and scheduling.');
    });

    test('goals list is ordered by target date, soonest first', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(studyPlannerControllerProvider);

      await controller.create(
          title: 'Later', subject: '', targetDate: DateTime(2026, 12, 1));
      await controller.create(
          title: 'Sooner', subject: '', targetDate: DateTime(2026, 8, 1));
      await controller.create(
          title: 'Middle', subject: '', targetDate: DateTime(2026, 10, 1));

      final titles =
          container.read(studyGoalsProvider).map((g) => g.title).toList();
      expect(titles, ['Sooner', 'Middle', 'Later']);
    });

    test('update changes fields; delete removes the goal', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(studyPlannerControllerProvider);

      final id = await controller.create(
          title: 'Draft', subject: 'Maths', targetDate: DateTime(2026, 9, 9));

      final ok = await controller.update(
        id,
        title: 'Real title',
        subject: 'Calculus',
        targetDate: DateTime(2026, 9, 10),
        description: 'Integrals',
        status: StudyGoalStatus.ready,
      );
      expect(ok, isTrue);

      final updated = container.read(studyGoalRepositoryProvider).getById(id)!;
      expect(updated.title, 'Real title');
      expect(updated.subject, 'Calculus');
      expect(updated.status, StudyGoalStatus.ready);
      expect(updated.targetDate, DateTime(2026, 9, 10));

      await controller.delete(id);
      expect(container.read(studyGoalRepositoryProvider).getById(id), isNull);
    });

    test('nextStudyGoalProvider returns the soonest goal that is not past',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(studyPlannerControllerProvider);
      final today = DateTime.now();

      await controller.create(
          title: 'Past',
          subject: '',
          targetDate: today.subtract(const Duration(days: 10)));
      await controller.create(
          title: 'Upcoming',
          subject: '',
          targetDate: today.add(const Duration(days: 3)));
      await controller.create(
          title: 'Far',
          subject: '',
          targetDate: today.add(const Duration(days: 30)));

      expect(container.read(nextStudyGoalProvider)!.title, 'Upcoming');
    });
  });
}
