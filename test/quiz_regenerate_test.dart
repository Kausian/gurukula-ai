// Tests for v1.19.0 quiz regeneration: regenerating replaces the note's quiz
// (no Library duplicates) while leaving past attempt history intact.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/models/enums.dart';
import 'package:gurukula_ai/data/models/quiz.dart';
import 'package:gurukula_ai/data/models/quiz_result.dart';
import 'package:gurukula_ai/data/models/study_document.dart';
import 'package:gurukula_ai/data/providers.dart';
import 'package:gurukula_ai/features/study/quiz_providers.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

const _richText =
    'A deadlock is a state where processes are blocked because each holds a '
    'resource. Mutual exclusion means resources cannot be shared between '
    'processes. Circular wait describes processes waiting in a cycle. The '
    'Bankers algorithm avoids unsafe allocation states. Detection strategies '
    'recover the system after a deadlock occurs.';

StudyDocument _doc(String id) => StudyDocument(
      id: id,
      userId: 'u1',
      title: 'Deadlocks',
      type: DocumentType.text,
      rawText: _richText,
      cleanedText: _richText,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_quiz_regen');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
    await Future.wait([
      Hive.openBox<StudyDocument>(HiveBoxes.documents),
      Hive.openBox<Quiz>(HiveBoxes.quizzes),
      Hive.openBox<QuizResult>(HiveBoxes.quizResults),
    ]);
  });

  tearDown(() async {
    await Hive.box<StudyDocument>(HiveBoxes.documents).clear();
    await Hive.box<Quiz>(HiveBoxes.quizzes).clear();
    await Hive.box<QuizResult>(HiveBoxes.quizResults).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('regenerate replaces the quiz (no duplicates) and keeps past results',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(quizControllerProvider);

    await container.read(documentRepositoryProvider).save(_doc('doc-1'));

    final firstId = await controller.generateForDocument('doc-1');
    expect(firstId, isNotNull);
    expect(
      container.read(quizRepositoryProvider).getAll().length,
      1,
    );

    // Simulate a past attempt on the first quiz.
    await container.read(quizResultRepositoryProvider).save(
          QuizResult(
            id: 'r1',
            quizId: firstId!,
            documentId: 'doc-1',
            score: 3,
            total: 5,
            answers: const ['a', 'b', 'c', 'd', 'e'],
            createdAt: DateTime.utc(2026, 1, 3),
          ),
        );

    final secondId = await controller.regenerateForDocument('doc-1');
    expect(secondId, isNotNull);
    expect(secondId, isNot(firstId));

    // Exactly one quiz remains for the document (replace, not append).
    final quizzes = container
        .read(quizRepositoryProvider)
        .getAll()
        .where((q) => q.documentId == 'doc-1')
        .toList();
    expect(quizzes.length, 1);
    expect(quizzes.single.id, secondId);

    // Past attempt history is preserved (not deleted by regeneration).
    expect(
      container.read(quizResultRepositoryProvider).getById('r1'),
      isNotNull,
    );
  });
}
