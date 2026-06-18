// Smoke test for the Gurukula AI app shell.
//
// The app reads from Hive and Firebase Auth. We initialize Hive in a temporary
// directory and override the auth state (signed out) so the test never touches
// real Firebase. With no user, the gate routes to the Welcome screen.

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:gurukula_ai/features/auth/auth_providers.dart';
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

  testWidgets('Welcome screen shows brand and primary CTA when signed out',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        ],
        child: const GurukulaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Study smarter, even offline.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
