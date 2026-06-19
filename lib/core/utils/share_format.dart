import '../../data/models/enums.dart';
import '../../data/models/flashcard.dart';
import '../../data/models/idea.dart';
import '../../data/models/quiz.dart';
import '../../data/models/quiz_question.dart';
import '../../data/models/quiz_result.dart';
import '../../data/models/summary.dart';

/// Builds plain-text exports of study content for copy-to-clipboard and the
/// Android share sheet (Phase 10A).
///
/// Pure string functions, kept UI-free so they're easy to unit-test. Every
/// export carries a light "via Gurukula AI" attribution line.
class ShareFormat {
  const ShareFormat._();

  static const String _attribution = 'via Gurukula AI';

  /// A formatted summary: short, detailed and key points.
  static String summary(String docTitle, Summary summary) {
    final buffer = StringBuffer()
      ..writeln('SUMMARY — ${_clean(docTitle)}')
      ..writeln('($_attribution)')
      ..writeln()
      ..writeln('Short summary')
      ..writeln(summary.shortSummary.trim())
      ..writeln()
      ..writeln('Detailed summary')
      ..writeln(summary.detailedSummary.trim());

    if (summary.keyPoints.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Key points');
      for (final point in summary.keyPoints) {
        buffer.writeln('• ${point.trim()}');
      }
    }
    return buffer.toString().trimRight();
  }

  /// A numbered list of flashcards with question, answer and difficulty.
  static String flashcards(String docTitle, List<Flashcard> cards) {
    final buffer = StringBuffer()
      ..writeln('FLASHCARDS — ${_clean(docTitle)}  (${cards.length} cards)')
      ..writeln('($_attribution)')
      ..writeln();
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      buffer
        ..writeln('${i + 1}. Q: ${card.question.trim()}')
        ..writeln('   A: ${card.answer.trim()}  [${_difficulty(card.difficulty)}]');
      if (i < cards.length - 1) buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// A quiz result: score, percentage and a per-question review. [isCorrect]
  /// decides correctness (so short-answer grading matches the app's logic).
  static String quizResult(
    String docTitle,
    Quiz quiz,
    QuizResult result, {
    required bool Function(QuizQuestion question, String answer) isCorrect,
  }) {
    final pct =
        result.total == 0 ? 0 : (result.score / result.total * 100).round();
    final buffer = StringBuffer()
      ..writeln('QUIZ RESULT — ${_clean(docTitle)}')
      ..writeln('Score: ${result.score} / ${result.total}  ($pct%)')
      ..writeln('($_attribution)')
      ..writeln();

    for (var i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      final answer = i < result.answers.length ? result.answers[i] : '';
      final correct = isCorrect(question, answer);
      buffer
        ..writeln('${i + 1}. ${question.prompt.trim()}')
        ..writeln('   Your answer: ${answer.trim().isEmpty ? '—' : answer.trim()}');
      buffer.writeln(correct
          ? '   ✓ Correct'
          : '   ✗  (Correct: ${question.correctAnswer.trim()})');
      if (i < quiz.questions.length - 1) buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// A full project idea, including notes/pitch when present.
  static String idea(Idea idea) {
    final buffer = StringBuffer()
      ..writeln('PROJECT IDEA — ${_clean(idea.title)}')
      ..writeln('($_attribution)')
      ..writeln()
      ..writeln('Problem: ${idea.problem.trim()}')
      ..writeln('Target users: ${_joinList(idea.targetUsers)}')
      ..writeln('Features:');
    for (final feature in idea.features) {
      buffer.writeln('• ${feature.trim()}');
    }
    buffer
      ..writeln('Tech stack: ${_joinList(idea.techStack)}')
      ..writeln('Difficulty: ${_difficulty(idea.difficulty)}')
      ..writeln('MVP plan: ${idea.mvpPlan.trim()}');

    final why = idea.whyUnique?.trim() ?? '';
    if (why.isNotEmpty) buffer.writeln("Why it's unique: $why");

    final notes = idea.notes.trim();
    if (notes.isNotEmpty) buffer.writeln('Notes / pitch: $notes');

    return buffer.toString().trimRight();
  }

  /// A rewrite/proofread output with its tone label.
  static String rewrite(String toneLabel, String text) {
    return '${_clean(toneLabel)} — $_attribution\n\n${text.trim()}';
  }

  static String _joinList(List<String> values) {
    final cleaned = values.map((v) => v.trim()).where((v) => v.isNotEmpty);
    return cleaned.isEmpty ? '—' : cleaned.join(', ');
  }

  static String _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Untitled' : trimmed;
  }

  static String _difficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
