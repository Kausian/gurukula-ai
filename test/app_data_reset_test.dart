// Tests for the v1.27.0 local data reset service: "Clear local study data"
// keeps the account/profile, while the full wipe (behind Delete account)
// removes everything local but preserves encryption/seed flags.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/models/activity_event.dart';
import 'package:gurukula_ai/data/models/enums.dart';
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
import 'package:gurukula_ai/services/app_data_reset_service.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

StudyDocument _doc() => StudyDocument(
      id: 'd1',
      userId: 'u1',
      title: 'Note',
      type: DocumentType.text,
      rawText: 'body',
      cleanedText: 'body',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

UserProfile _profile() => UserProfile(
      id: 'p1',
      googleUid: 'uid-1',
      username: 'Student',
      studyLevel: 'University',
      mainSubject: 'CS',
      learningGoal: 'Exams',
      preferredLanguage: 'English',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_reset');
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
    await Hive.box<StudyDocument>(HiveBoxes.documents).clear();
    await Hive.box<UserProfile>(HiveBoxes.profiles).clear();
    await Hive.box<dynamic>(HiveBoxes.settings).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Future<void> seed(ProviderContainer c) async {
    await c.read(documentRepositoryProvider).save(_doc());
    await c.read(profileRepositoryProvider).save(_profile());
    final settings = Hive.box<dynamic>(HiveBoxes.settings);
    await settings.put('favoriteDocIds', ['d1']);
    await settings.put('onboardingCompleted', true);
    await settings.put('privacyLockEnabled', true);
    await settings.put('privacyLockPinHash', 'hash');
    await settings.put('storageEncrypted', true);
    await settings.put('seeded', true);
    await settings.put('themeMode', 'dark');
  }

  test('clearStudyData wipes study content but keeps account/profile', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await seed(container);

    await container.read(appDataResetProvider).clearStudyData();

    final settings = Hive.box<dynamic>(HiveBoxes.settings);
    expect(container.read(documentRepositoryProvider).getAll(), isEmpty);
    expect(container.read(profileRepositoryProvider).current, isNotNull);
    expect(settings.get('favoriteDocIds'), isNull); // favorites cleared
    expect(settings.get('onboardingCompleted'), true); // account state kept
    expect(settings.get('privacyLockEnabled'), true);
  });

  test('wipeAllLocalData removes profile + user flags, keeps encryption/seed',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await seed(container);

    await container.read(appDataResetProvider).wipeAllLocalData();

    final settings = Hive.box<dynamic>(HiveBoxes.settings);
    expect(container.read(documentRepositoryProvider).getAll(), isEmpty);
    expect(container.read(profileRepositoryProvider).current, isNull);
    // User flags removed so the app opens fresh with no Privacy Lock trap.
    expect(settings.get('onboardingCompleted'), isNull);
    expect(settings.get('privacyLockEnabled'), isNull);
    expect(settings.get('privacyLockPinHash'), isNull);
    expect(settings.get('favoriteDocIds'), isNull);
    // Encryption + seed state preserved so storage doesn't corrupt / re-seed.
    expect(settings.get('storageEncrypted'), true);
    expect(settings.get('seeded'), true);
  });
}
