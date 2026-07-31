// Verifies the v1.26.0 additive UserProfile change: the new optional
// `institution` field round-trips through Hive, and profiles saved without it
// (older records) still load with a null institution.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/models/user_profile.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

UserProfile _profile({String? institution}) => UserProfile(
      id: 'p1',
      googleUid: 'uid-1',
      email: 'student@example.com',
      displayName: 'Test Student',
      username: 'Test Student',
      studyLevel: 'University',
      mainSubject: 'Computer Science',
      learningGoal: 'Exams',
      preferredLanguage: 'English',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      institution: institution,
    );

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_profile');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
    await Hive.openBox<UserProfile>(HiveBoxes.profiles);
  });

  tearDown(() async {
    await Hive.box<UserProfile>(HiveBoxes.profiles).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('institution persists and reads back', () async {
    final box = Hive.box<UserProfile>(HiveBoxes.profiles);
    await box.put('p1', _profile(institution: 'Springfield University'));

    final loaded = box.get('p1');
    expect(loaded, isNotNull);
    expect(loaded!.institution, 'Springfield University');
    expect(loaded.studyLevel, 'University');
    expect(loaded.learningGoal, 'Exams');
  });

  test('a profile without an institution loads with null', () async {
    final box = Hive.box<UserProfile>(HiveBoxes.profiles);
    await box.put('p1', _profile());

    expect(box.get('p1')!.institution, isNull);
  });
}
