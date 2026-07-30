// Tests for v1.24.0 local (fallback) study generation. Pure functions, so no
// Hive/widgets/device — this is the deterministic engine behind the fallback
// used on unsupported devices and for all flashcards/quizzes.

import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/data/models/enums.dart';
import 'package:gurukula_ai/services/ai_service.dart';
import 'package:gurukula_ai/services/local_generation.dart';

const _notes =
    'A deadlock is a state where processes are blocked because each holds a '
    'resource and waits for another resource. '
    'Mutual exclusion means resources cannot be shared between processes. '
    'Circular wait describes processes waiting in a cycle. '
    'The Bankers algorithm avoids unsafe allocation states in the operating '
    'system. '
    'Deadlock detection strategies recover the operating system after a '
    'deadlock occurs.';

void main() {
  group('summary', () {
    test('produces a structured, non-empty, de-duplicated summary', () {
      final s = LocalGeneration.summarize(_notes);
      expect(s.shortSummary, isNotEmpty);
      expect(s.detailedSummary, isNotEmpty);
      expect(s.keyPoints, isNotEmpty);
      // Key points must not repeat.
      final norm = s.keyPoints.map((p) => p.toLowerCase().trim()).toList();
      expect(norm.toSet().length, norm.length);
    });

    test('detailed length yields a longer detailed summary than short', () {
      final short = LocalGeneration.summarize(_notes, length: SummaryLength.short);
      final detailed =
          LocalGeneration.summarize(_notes, length: SummaryLength.detailed);
      expect(detailed.detailedSummary.length,
          greaterThan(short.detailedSummary.length));
    });

    test('handles empty and single-sentence notes gracefully', () {
      final empty = LocalGeneration.summarize('   ');
      expect(empty.shortSummary, contains('No text'));
      expect(empty.keyPoints, isEmpty);

      final one = LocalGeneration.summarize('Photosynthesis converts light.');
      expect(one.shortSummary, isNotEmpty);
      expect(one.keyPoints, isNotEmpty);
    });
  });

  group('flashcards', () {
    test('creates definition cards and de-duplicates by term', () {
      final cards = LocalGeneration.flashcards(_notes, count: 5);
      expect(cards, isNotEmpty);
      // A definition-based card for "deadlock" (article stripped).
      expect(cards.any((c) => c.question.toLowerCase().contains('deadlock')),
          isTrue);
      // No duplicate questions.
      final qs = cards.map((c) => c.question.toLowerCase()).toList();
      expect(qs.toSet().length, qs.length);
      // Every card has a real answer.
      expect(cards.every((c) => c.answer.trim().isNotEmpty), isTrue);
    });

    test('exam-prep style changes the question wording', () {
      final quick = LocalGeneration.flashcards(_notes,
          style: FlashcardStyle.quickRevision);
      final exam =
          LocalGeneration.flashcards(_notes, style: FlashcardStyle.examPrep);
      expect(quick.first.question, startsWith('What is'));
      expect(exam.any((c) => c.question.startsWith('Define')), isTrue);
    });

    test('empty notes yield no cards', () {
      expect(LocalGeneration.flashcards('   '), isEmpty);
    });
  });

  group('quiz', () {
    test('multiple-choice options are unique and contain the answer', () {
      final qs = LocalGeneration.quiz(_notes, count: 5);
      expect(qs, isNotEmpty);
      for (final q in qs.where((q) => q.type == QuestionType.multipleChoice)) {
        expect(q.options.length, 4);
        // No duplicate options (case-insensitive).
        final lower = q.options.map((o) => o.toLowerCase()).toList();
        expect(lower.toSet().length, lower.length);
        // The correct answer is one of the options.
        expect(q.options, contains(q.correctAnswer));
      }
    });

    test('hard difficulty includes a false true/false statement', () {
      final qs = LocalGeneration.quiz(_notes, difficulty: QuizDifficulty.hard);
      final tf = qs.where((q) => q.type == QuestionType.trueFalse).toList();
      expect(tf, isNotEmpty);
      expect(tf.any((q) => q.correctAnswer == 'False'), isTrue);
    });

    test('weak or empty text produces no questions', () {
      expect(LocalGeneration.quiz(''), isEmpty);
      expect(LocalGeneration.quiz('Ok. No. Yes.'), isEmpty);
    });

    test('difficulty is a plain option (uses Difficulty enum untouched)', () {
      // Sanity: the generator returns real question types.
      final qs = LocalGeneration.quiz(_notes);
      expect(qs.map((q) => q.type).toSet(), isNotEmpty);
      // Difficulty enum still intact for flashcards.
      expect(Difficulty.values.length, 3);
    });
  });
}
