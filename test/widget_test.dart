// Smoke test for the Gurukula AI app shell.
//
// The app reads from Hive, so we initialize it in a temporary directory and
// open the boxes before pumping the widget tree.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/app/app.dart';
import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/models/activity_event.dart';
import 'package:gurukula_ai/data/models/flashcard.dart';
import 'package:gurukula_ai/data/models/idea.dart';
import 'package:gurukula_ai/data/models/rewrite.dart';
import 'package:gurukula_ai/data/models/study_document.dart';
import 'package:gurukula_ai/data/models/summary.dart';
import 'package:gurukula_ai/data/models/user_profile.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_test');
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

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('Welcome screen shows brand and primary CTA', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GurukulaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Gurukula'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
