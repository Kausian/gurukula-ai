import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/activity_event.dart';
import '../../data/models/enums.dart';
import '../../data/models/quiz.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_result.dart';
import '../../data/providers.dart';
import 'study_providers.dart';

/// The most recent quiz for a document (reactive).
final quizForDocumentProvider = Provider.family<Quiz?, String>((ref, docId) {
  ref.watch(dataChangesProvider);
  return ref.watch(quizRepositoryProvider).forDocument(docId);
});

/// A quiz by id (reactive).
final quizByIdProvider = Provider.family<Quiz?, String>((ref, id) {
  ref.watch(dataChangesProvider);
  return ref.watch(quizRepositoryProvider).getById(id);
});

/// The best attempt for a quiz, or null if not taken yet (reactive).
final bestResultForQuizProvider =
    Provider.family<QuizResult?, String>((ref, quizId) {
  ref.watch(dataChangesProvider);
  return ref.watch(quizResultRepositoryProvider).bestForQuiz(quizId);
});

final quizControllerProvider =
    Provider<QuizController>((ref) => QuizController(ref));

/// Generates quizzes from a document and grades/saves attempts. Mock-backed.
class QuizController {
  QuizController(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  String get _userId => _ref.read(currentProfileProvider)?.id ?? 'local';

  /// Generates and saves a quiz for a document. Returns the new quiz id.
  Future<String?> generateForDocument(String documentId, {int count = 5}) async {
    final document = _ref.read(documentRepositoryProvider).getById(documentId);
    if (document == null) return null;

    final drafts = await _ref
        .read(aiServiceProvider)
        .generateQuiz(document.cleanedText, count: count);
    if (drafts.isEmpty) return null;

    final quizId = _uuid.v4();
    final quiz = Quiz(
      id: quizId,
      documentId: documentId,
      title: 'Quiz: ${document.title}',
      questions: [
        for (final d in drafts)
          QuizQuestion(
            id: _uuid.v4(),
            type: d.type,
            prompt: d.prompt,
            options: d.options,
            correctAnswer: d.correctAnswer,
            explanation: d.explanation,
          ),
      ],
      createdAt: DateTime.now().toUtc(),
    );
    await _ref.read(quizRepositoryProvider).save(quiz);
    return quizId;
  }

  /// Grades the answers, saves the result and logs the activity.
  Future<QuizResult> gradeAndSave(Quiz quiz, List<String> answers) async {
    var score = 0;
    for (var i = 0; i < quiz.questions.length; i++) {
      final answer = i < answers.length ? answers[i] : '';
      if (_isCorrect(quiz.questions[i], answer)) score++;
    }
    final total = quiz.questions.length;

    final result = QuizResult(
      id: _uuid.v4(),
      quizId: quiz.id,
      documentId: quiz.documentId,
      score: score,
      total: total,
      answers: answers,
      createdAt: DateTime.now().toUtc(),
    );
    await _ref.read(quizResultRepositoryProvider).save(result);
    await _ref.read(activityRepositoryProvider).save(
          ActivityEvent(
            id: _uuid.v4(),
            userId: _userId,
            type: ActivityType.quizCompleted,
            referenceId: quiz.id,
            title: 'Scored $score/$total on ${quiz.title}',
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return result;
  }

  bool isCorrect(QuizQuestion question, String answer) =>
      _isCorrect(question, answer);

  bool _isCorrect(QuizQuestion question, String answer) {
    final a = answer.trim().toLowerCase();
    final c = question.correctAnswer.trim().toLowerCase();
    if (a.isEmpty) return false;

    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return a == c;
      case QuestionType.shortAnswer:
        // Approximate: keyword / substring overlap with the reference.
        if (c.contains(a) || a.contains(c)) return true;
        final keywords = c.split(' ').where((w) => w.length > 4);
        return keywords.any((k) => a.contains(k));
    }
  }
}
