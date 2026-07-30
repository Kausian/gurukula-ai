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

  /// The source note itself (v1.23.0), for clean export/sharing.
  static String note(String title, String body, {DateTime? updatedAt}) {
    final buffer = StringBuffer()
      ..writeln('NOTE — ${_clean(title)}')
      ..writeln('($_attribution)');
    if (updatedAt != null) {
      buffer.writeln('Updated: ${_formatDate(updatedAt)}');
    }
    buffer.writeln();
    final trimmed = body.trim();
    buffer.write(trimmed.isEmpty ? 'This note is empty.' : trimmed);
    return buffer.toString().trimRight();
  }

  /// The quiz content — questions with their answers (v1.23.0). This is the
  /// quiz itself, distinct from [quizResult] which reports a taken attempt.
  static String quiz(String docTitle, Quiz quiz) {
    final buffer = StringBuffer()
      ..writeln(
          'QUIZ — ${_clean(docTitle)}  (${quiz.questions.length} questions)')
      ..writeln('($_attribution)')
      ..writeln();
    for (var i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      buffer.writeln('${i + 1}. ${q.prompt.trim()}');
      final options = q.options.map((o) => o.trim()).where((o) => o.isNotEmpty);
      if (options.isNotEmpty) {
        buffer.writeln('   Options: ${options.join(' / ')}');
      }
      buffer.writeln('   Answer: ${q.correctAnswer.trim()}');
      if (i < quiz.questions.length - 1) buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// A full "study pack" combining the note, summary, flashcards and quiz into
  /// one professionally structured export (v1.23.0). Missing sections are shown
  /// as a short placeholder rather than omitted, so the layout stays consistent.
  static String studyPack({
    required String title,
    required String note,
    Summary? summary,
    required List<Flashcard> flashcards,
    Quiz? quiz,
    DateTime? exportedAt,
  }) {
    final when = exportedAt ?? DateTime.now();
    final buffer = StringBuffer()
      ..writeln('Gurukula AI Study Export')
      ..writeln('Title: ${_clean(title)}')
      ..writeln('Exported: ${_formatDate(when)}')
      ..writeln('(Generated on your device)')
      ..writeln();

    buffer
      ..writeln(_section('Source Note'))
      ..writeln(note.trim().isEmpty ? 'This note is empty.' : note.trim())
      ..writeln();

    buffer.writeln(_section('Summary'));
    if (summary == null) {
      buffer.writeln('No summary yet.');
    } else {
      buffer
        ..writeln('Short summary')
        ..writeln(summary.shortSummary.trim())
        ..writeln()
        ..writeln('Detailed summary')
        ..writeln(summary.detailedSummary.trim());
      if (summary.keyPoints.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Key points');
        for (final point in summary.keyPoints) {
          buffer.writeln('• ${point.trim()}');
        }
      }
    }
    buffer.writeln();

    buffer.writeln(_section('Flashcards'));
    if (flashcards.isEmpty) {
      buffer.writeln('No flashcards yet.');
    } else {
      for (var i = 0; i < flashcards.length; i++) {
        final card = flashcards[i];
        buffer
          ..writeln('${i + 1}. Q: ${card.question.trim()}')
          ..writeln('   A: ${card.answer.trim()}');
      }
    }
    buffer.writeln();

    buffer.writeln(_section('Quiz'));
    if (quiz == null || quiz.questions.isEmpty) {
      buffer.writeln('No quiz yet.');
    } else {
      for (var i = 0; i < quiz.questions.length; i++) {
        final q = quiz.questions[i];
        buffer
          ..writeln('${i + 1}. ${q.prompt.trim()}')
          ..writeln('   Answer: ${q.correctAnswer.trim()}');
      }
    }
    buffer
      ..writeln()
      ..writeln('Privacy Note:')
      ..write('This export was created locally from Gurukula AI. Your study '
          'data stays on your device.');

    return buffer.toString().trimRight();
  }

  static String _section(String title) => '=== $title ===';

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' //
    ];
    final local = date.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
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
