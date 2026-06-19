// Tests for the plain-text export formatters (Phase 10A). Pure string output,
// so no Hive, widgets or device needed.

import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/core/utils/share_format.dart';
import 'package:gurukula_ai/data/models/enums.dart';
import 'package:gurukula_ai/data/models/flashcard.dart';
import 'package:gurukula_ai/data/models/idea.dart';
import 'package:gurukula_ai/data/models/quiz.dart';
import 'package:gurukula_ai/data/models/quiz_question.dart';
import 'package:gurukula_ai/data/models/quiz_result.dart';
import 'package:gurukula_ai/data/models/summary.dart';

final _now = DateTime.utc(2026, 1, 1);

void main() {
  test('summary export includes all sections and attribution', () {
    final summary = Summary(
      id: 's1',
      documentId: 'd1',
      shortSummary: 'Plants make food from light.',
      detailedSummary: 'Photosynthesis converts light to chemical energy.',
      keyPoints: const ['Chlorophyll absorbs light', 'Produces oxygen'],
      createdAt: _now,
    );

    final text = ShareFormat.summary('Biology', summary);

    expect(text, contains('SUMMARY — Biology'));
    expect(text, contains('via Gurukula AI'));
    expect(text, contains('Plants make food from light.'));
    expect(text, contains('• Chlorophyll absorbs light'));
  });

  test('flashcards export numbers cards with Q/A and difficulty', () {
    final cards = [
      Flashcard(
        id: 'c1',
        documentId: 'd1',
        question: 'What is H2O?',
        answer: 'Water',
        difficulty: Difficulty.easy,
        isReviewed: false,
        createdAt: _now,
      ),
      Flashcard(
        id: 'c2',
        documentId: 'd1',
        question: 'Symbol for gold?',
        answer: 'Au',
        difficulty: Difficulty.hard,
        isReviewed: false,
        createdAt: _now,
      ),
    ];

    final text = ShareFormat.flashcards('Chemistry', cards);

    expect(text, contains('FLASHCARDS — Chemistry  (2 cards)'));
    expect(text, contains('1. Q: What is H2O?'));
    expect(text, contains('A: Water  [Easy]'));
    expect(text, contains('2. Q: Symbol for gold?'));
    expect(text, contains('[Hard]'));
  });

  test('quiz result export shows score and marks correct/incorrect', () {
    final quiz = Quiz(
      id: 'q1',
      documentId: 'd1',
      title: 'Pop quiz',
      questions: [
        QuizQuestion(
          id: 'q1a',
          type: QuestionType.multipleChoice,
          prompt: 'Capital of France?',
          options: const ['Paris', 'Rome'],
          correctAnswer: 'Paris',
        ),
        QuizQuestion(
          id: 'q1b',
          type: QuestionType.multipleChoice,
          prompt: 'Capital of Italy?',
          options: const ['Paris', 'Rome'],
          correctAnswer: 'Rome',
        ),
      ],
      createdAt: _now,
    );
    final result = QuizResult(
      id: 'r1',
      quizId: 'q1',
      documentId: 'd1',
      score: 1,
      total: 2,
      answers: const ['Paris', 'Paris'],
      createdAt: _now,
    );

    final text = ShareFormat.quizResult(
      'Geography',
      quiz,
      result,
      isCorrect: (question, answer) => question.correctAnswer == answer,
    );

    expect(text, contains('QUIZ RESULT — Geography'));
    expect(text, contains('Score: 1 / 2  (50%)'));
    expect(text, contains('✓ Correct'));
    expect(text, contains('✗  (Correct: Rome)'));
  });

  test('idea export lists fields and includes notes only when present', () {
    final idea = Idea(
      id: 'i1',
      userId: 'u1',
      title: 'Offline Revision Buddy',
      problem: 'Studying without internet is hard.',
      targetUsers: const ['Students'],
      features: const ['Summaries', 'Flashcards'],
      techStack: const ['Flutter', 'Hive'],
      difficulty: Difficulty.medium,
      mvpPlan: 'Build the core study loop.',
      notes: 'My elevator pitch.',
      createdAt: _now,
      updatedAt: _now,
      whyUnique: 'Fully on-device.',
    );

    final text = ShareFormat.idea(idea);

    expect(text, contains('PROJECT IDEA — Offline Revision Buddy'));
    expect(text, contains('Problem: Studying without internet is hard.'));
    expect(text, contains('• Summaries'));
    expect(text, contains('Tech stack: Flutter, Hive'));
    expect(text, contains('Difficulty: Medium'));
    expect(text, contains("Why it's unique: Fully on-device."));
    expect(text, contains('Notes / pitch: My elevator pitch.'));
  });

  test('rewrite export carries the tone label and attribution', () {
    final text = ShareFormat.rewrite('Formal', 'This is the rewritten text.');
    expect(text, contains('Formal — via Gurukula AI'));
    expect(text, contains('This is the rewritten text.'));
  });
}
