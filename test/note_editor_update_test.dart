// Diagnostic test for the v1.16.0 note editor save path.
// Verifies that editing a note's title AND body both persist to Hive, and that
// generation reads the updated body.

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
import 'package:gurukula_ai/data/providers.dart';
import 'package:gurukula_ai/features/study/study_providers.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_note_edit');
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
    await Hive.box<StudyDocument>(HiveBoxes.documents).clear();
    await Hive.box<Summary>(HiveBoxes.summaries).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('updateDocumentContent persists both new title and new body', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final id = await container
        .read(studyControllerProvider)
        .createDocumentFromText(
          title: 'Old title',
          text: 'Old body content.',
        );

    final ok =
        await container.read(studyControllerProvider).updateDocumentContent(
              documentId: id,
              title: 'New title',
              body: 'THIS IS THE UPDATED BODY TEST.',
            );
    expect(ok, isTrue);

    final doc = container.read(documentRepositoryProvider).getById(id);
    expect(doc!.title, 'New title');
    expect(doc.cleanedText, contains('THIS IS THE UPDATED BODY TEST.'));
    expect(doc.rawText, contains('THIS IS THE UPDATED BODY TEST.'));
  });

  test('regenerateSummary rebuilds the summary from the updated body in place',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(studyControllerProvider);

    final id = await controller.createDocumentFromText(
      title: 'Note',
      text: 'Old body content.',
    );
    final originalSummaryId =
        container.read(summaryRepositoryProvider).byDocument(id).single.id;

    await controller.updateDocumentContent(
      documentId: id,
      title: 'Note',
      body: 'THIS IS THE UPDATED BODY TEST.',
    );
    final ok = await controller.regenerateSummary(id);
    expect(ok, isTrue);

    final summaries = container.read(summaryRepositoryProvider).byDocument(id);
    // Overwritten in place — no duplicate summary in the Library.
    expect(summaries.length, 1);
    expect(summaries.single.id, originalSummaryId);
    // The regenerated summary reflects the updated note body.
    final blob =
        '${summaries.single.shortSummary} ${summaries.single.detailedSummary} '
        '${summaries.single.keyPoints.join(' ')}';
    expect(blob, contains('THIS IS THE UPDATED BODY TEST.'));
  });
}
