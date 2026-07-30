import 'dart:math';

import '../core/utils/text_clean.dart';
import '../data/models/enums.dart';
import 'ai_service.dart';

/// Deterministic, offline study-material generation (v1.24.0).
///
/// Pure functions (no delays, no I/O) so they are fast and easy to unit-test.
/// [MockAiService] delegates here, which means these improvements power the
/// fallback path used on every device where on-device AI is unavailable, and
/// for flashcards/quizzes everywhere.
///
/// The approach is honest rule-based NLP: sentence splitting, keyword-frequency
/// scoring, definition detection, de-duplication and seeded shuffling. It does
/// not use any cloud or model, and never claims to be more than a helpful
/// starting point.
class LocalGeneration {
  const LocalGeneration._();

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  static AiSummary summarize(String text,
      {SummaryLength length = SummaryLength.medium}) {
    final sentences = _sentences(text);
    if (sentences.isEmpty) {
      return const AiSummary(
        shortSummary: 'No text to summarize yet.',
        detailedSummary: 'Add some notes to generate a summary.',
        keyPoints: [],
      );
    }

    final freq = _frequencies(sentences);
    final ranked = _rankSentences(sentences, freq);

    final detailCount = switch (length) {
      SummaryLength.short => 2,
      SummaryLength.medium => 3,
      SummaryLength.detailed => 5,
    };
    final pointCount = switch (length) {
      SummaryLength.short => 3,
      SummaryLength.medium => 5,
      SummaryLength.detailed => 7,
    };

    // Short summary: the single strongest sentence (two for detailed).
    final headline = length == SummaryLength.detailed
        ? _inOriginalOrder(ranked.take(2), sentences)
        : [ranked.first];
    final shortSummary = _dedupeJoin(headline, sentences);

    // Detailed: the top sentences, kept in their original reading order.
    final detailed =
        _inOriginalOrder(ranked.take(min(detailCount, sentences.length)),
            sentences);
    final detailedSummary = _dedupeJoin(detailed, sentences);

    // Key points: definitions first, then the highest-signal sentences,
    // trimmed to concise bullets and de-duplicated.
    final points = <String>[];
    final seen = <String>{};
    void add(String raw) {
      final point = _asPoint(raw);
      final norm = _normalize(point);
      if (point.isEmpty || norm.isEmpty || !seen.add(norm)) return;
      points.add(point);
    }

    for (final def in _definitions(sentences)) {
      if (points.length >= pointCount) break;
      add(def.sentence);
    }
    for (final s in ranked) {
      if (points.length >= pointCount) break;
      add(s);
    }

    // A compact "key terms" line rounds out the revision points.
    final terms = _topTerms(freq, 6);
    if (terms.isNotEmpty && points.length < pointCount + 1) {
      points.add('Key terms: ${terms.join(', ')}');
    }

    return AiSummary(
      shortSummary: shortSummary,
      detailedSummary: detailedSummary,
      keyPoints: points,
    );
  }

  // ---------------------------------------------------------------------------
  // Flashcards
  // ---------------------------------------------------------------------------

  static List<AiFlashcardDraft> flashcards(
    String text, {
    int count = 5,
    FlashcardStyle style = FlashcardStyle.quickRevision,
  }) {
    final sentences = _sentences(text);
    if (sentences.isEmpty) return const [];

    final freq = _frequencies(sentences);
    final drafts = <AiFlashcardDraft>[];
    final usedQuestions = <String>{};
    final usedTerms = <String>{};

    void tryAdd(String question, String answer, Difficulty difficulty) {
      final q = question.trim();
      final a = answer.trim();
      if (q.isEmpty || a.isEmpty) return;
      if (!usedQuestions.add(_normalize(q))) return;
      drafts.add(AiFlashcardDraft(question: q, answer: a, difficulty: difficulty));
    }

    // 1) Definition cards — the most useful for revision.
    for (final def in _definitions(sentences)) {
      if (drafts.length >= count) break;
      if (!usedTerms.add(def.term.toLowerCase())) continue;
      final question = style == FlashcardStyle.examPrep
          ? 'Define ${def.term} and explain what it means.'
          : 'What is ${def.term}?';
      tryAdd(question, def.sentence, _difficultyFor(def.sentence));
    }

    // 2) Concept cards from the highest-signal remaining sentences.
    for (final sentence in _rankSentences(sentences, freq)) {
      if (drafts.length >= count) break;
      final term = _keyTerm(sentence, freq);
      if (term == null) continue;
      if (!usedTerms.add(term.toLowerCase())) continue;
      final question = style == FlashcardStyle.examPrep
          ? 'Explain how $term works and why it matters.'
          : 'What is the key idea about $term?';
      tryAdd(question, sentence, _difficultyFor(sentence));
    }

    return drafts.take(count).toList();
  }

  // ---------------------------------------------------------------------------
  // Quiz
  // ---------------------------------------------------------------------------

  static List<AiQuizQuestion> quiz(
    String text, {
    int count = 5,
    QuizDifficulty difficulty = QuizDifficulty.medium,
  }) {
    final all = _sentences(text);
    // Only build questions from clear, self-contained sentences.
    final clear = all.where(_isClearSentence).toList();
    if (clear.isEmpty) return const [];

    final freq = _frequencies(all);
    final pool = _termPool(all);
    final ranked = _rankSentences(clear, freq);
    final questions = <AiQuizQuestion>[];
    final usedPrompts = <String>{};

    // How many of each type, by difficulty. Easy leans on recognition
    // (true/false, cloze); hard leans on recall (short answer, false-statement).
    final clozeTarget = switch (difficulty) {
      QuizDifficulty.easy => count - 1,
      QuizDifficulty.medium => count - 2,
      QuizDifficulty.hard => count - 2,
    };
    final wantFalseTrueFalse = difficulty == QuizDifficulty.hard;

    // 1) Multiple-choice cloze questions.
    for (final sentence in ranked) {
      if (questions.length >= clozeTarget) break;
      final answer = _keyTerm(sentence, freq);
      if (answer == null) continue;
      final options = _buildOptions(answer, pool, seed: questions.length);
      if (options.length < 4) continue;
      final prompt = 'Fill in the blank: ${_blankOut(sentence, answer)}';
      if (!usedPrompts.add(_normalize(prompt))) continue;
      questions.add(AiQuizQuestion(
        type: QuestionType.multipleChoice,
        prompt: prompt,
        options: options,
        correctAnswer: answer,
        explanation: 'From your notes: "$sentence"',
      ));
    }

    // 2) A true/false question. Hard quizzes get a (deterministically) false
    //    statement by swapping the key term; others use a true statement.
    if (questions.length < count) {
      final base = ranked.firstWhere(
        (s) => !usedPrompts.contains(_normalize('Fill in the blank: $s')),
        orElse: () => ranked.first,
      );
      if (wantFalseTrueFalse) {
        final answer = _keyTerm(base, freq);
        final swap = answer == null
            ? null
            : pool.firstWhere(
                (w) => w.toLowerCase() != answer.toLowerCase(),
                orElse: () => '',
              );
        if (answer != null && swap != null && swap.isNotEmpty) {
          final falseStatement = _replaceTerm(base, answer, swap);
          questions.add(AiQuizQuestion(
            type: QuestionType.trueFalse,
            prompt: 'True or false? $falseStatement',
            options: const ['True', 'False'],
            correctAnswer: 'False',
            explanation: 'The original note says "$base".',
          ));
        }
      } else {
        questions.add(AiQuizQuestion(
          type: QuestionType.trueFalse,
          prompt: 'True or false? $base',
          options: const ['True', 'False'],
          correctAnswer: 'True',
          explanation: 'This statement comes directly from your notes.',
        ));
      }
    }

    // 3) A short-answer question for recall.
    if (questions.length < count && clear.length > 1) {
      final sentence = ranked.length > 1 ? ranked[1] : ranked.first;
      final term = _keyTerm(sentence, freq) ?? firstWords(sentence, 4);
      questions.add(AiQuizQuestion(
        type: QuestionType.shortAnswer,
        prompt: 'In your own words, explain: $term',
        options: const [],
        correctAnswer: sentence,
      ));
    }

    return questions.take(count).toList();
  }

  // ---------------------------------------------------------------------------
  // Text analysis helpers
  // ---------------------------------------------------------------------------

  static List<String> _sentences(String text) => splitSentences(cleanText(text));

  static const Set<String> _stopwords = {
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'her',
    'was', 'one', 'our', 'out', 'his', 'has', 'had', 'him', 'how', 'its',
    'who', 'did', 'yes', 'she', 'they', 'them', 'this', 'that', 'with',
    'from', 'have', 'been', 'were', 'when', 'what', 'which', 'their', 'there',
    'these', 'those', 'then', 'than', 'into', 'onto', 'each', 'such', 'also',
    'because', 'while', 'where', 'about', 'would', 'could', 'should', 'being',
    'other', 'between', 'after', 'before', 'over', 'under', 'some', 'more',
    'most', 'many', 'much', 'very', 'often', 'using', 'used', 'like',
  };

  static List<String> _contentWords(String sentence, {int minLen = 4}) {
    return sentence
        .split(RegExp(r'[^A-Za-z]+'))
        .where((w) => w.length >= minLen && !_stopwords.contains(w.toLowerCase()))
        .toList();
  }

  static Map<String, int> _frequencies(List<String> sentences) {
    final freq = <String, int>{};
    for (final s in sentences) {
      for (final w in _contentWords(s)) {
        freq[w.toLowerCase()] = (freq[w.toLowerCase()] ?? 0) + 1;
      }
    }
    return freq;
  }

  /// Sentences ordered by importance (keyword-density score), most useful
  /// first, with a small boost for definition-like sentences and a penalty for
  /// very short or very long sentences.
  static List<String> _rankSentences(
      List<String> sentences, Map<String, int> freq) {
    final scored = <MapEntry<String, double>>[];
    for (var i = 0; i < sentences.length; i++) {
      final s = sentences[i];
      final words = _contentWords(s);
      if (words.isEmpty) continue;
      var score = 0.0;
      for (final w in words) {
        score += freq[w.toLowerCase()] ?? 0;
      }
      score /= words.length; // density, not just length
      if (_looksLikeDefinition(s)) score *= 1.3;
      final wc = s.split(RegExp(r'\s+')).length;
      if (wc < 4 || wc > 40) score *= 0.6;
      // Tiny position bias so ties keep reading order deterministically.
      score += (sentences.length - i) * 0.0001;
      scored.add(MapEntry(s, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  static List<String> _inOriginalOrder(
      Iterable<String> chosen, List<String> sentences) {
    final set = chosen.toSet();
    return sentences.where(set.contains).toList();
  }

  static String _dedupeJoin(List<String> parts, List<String> _) {
    final seen = <String>{};
    final out = <String>[];
    for (final p in parts) {
      final norm = _normalize(p);
      if (norm.isEmpty || !seen.add(norm)) continue;
      out.add(p.trim());
    }
    return out.join(' ');
  }

  static final RegExp _definitionRe = RegExp(
      r'^(.{2,40}?)\s+(?:is|are|means|refers to|is defined as|describes)\s+',
      caseSensitive: false);

  static bool _looksLikeDefinition(String s) => _definitionRe.hasMatch(s);

  static List<_Definition> _definitions(List<String> sentences) {
    final out = <_Definition>[];
    for (final s in sentences) {
      final m = _definitionRe.firstMatch(s);
      if (m == null) continue;
      // Drop a leading article so "A deadlock is…" gives the term "deadlock".
      final term = m
          .group(1)!
          .trim()
          .replaceFirst(RegExp(r'^(a|an|the)\s+', caseSensitive: false), '');
      // Keep terms short and word-like (a concept, not a whole clause).
      if (term.isEmpty || term.split(RegExp(r'\s+')).length > 5) continue;
      out.add(_Definition(term: term, sentence: s.trim()));
    }
    return out;
  }

  /// The most representative content word of a sentence (highest global
  /// frequency, ties broken by length), in its original casing.
  static String? _keyTerm(String sentence, Map<String, int> freq) {
    final words = _contentWords(sentence);
    if (words.isEmpty) return null;
    words.sort((a, b) {
      final fa = freq[a.toLowerCase()] ?? 0;
      final fb = freq[b.toLowerCase()] ?? 0;
      if (fa != fb) return fb.compareTo(fa);
      return b.length.compareTo(a.length);
    });
    return words.first;
  }

  static List<String> _topTerms(Map<String, int> freq, int n) {
    final entries = freq.entries.where((e) => e.value > 1).toList()
      ..sort((a, b) => b.value != a.value
          ? b.value.compareTo(a.value)
          : b.key.length.compareTo(a.key.length));
    return entries.take(n).map((e) => e.key).toList();
  }

  static List<String> _termPool(List<String> sentences) {
    final seen = <String>{};
    final pool = <String>[];
    for (final s in sentences) {
      for (final w in _contentWords(s)) {
        if (seen.add(w.toLowerCase())) pool.add(w);
      }
    }
    return pool;
  }

  /// Four de-duplicated options containing [answer] plus three distractors of
  /// similar length, shuffled deterministically so the answer isn't always in
  /// the same position.
  static List<String> _buildOptions(String answer, List<String> pool,
      {required int seed}) {
    final lower = answer.toLowerCase();
    final candidates = pool
        .where((w) => w.toLowerCase() != lower)
        .toList()
      ..sort((a, b) => (a.length - answer.length)
          .abs()
          .compareTo((b.length - answer.length).abs()));

    final options = <String>[answer];
    final used = <String>{lower};
    for (final c in candidates) {
      if (options.length >= 4) break;
      if (used.add(c.toLowerCase())) options.add(c);
    }
    if (options.length < 4) return options; // caller skips
    options.shuffle(Random(seed + answer.length));
    return options;
  }

  static String _blankOut(String sentence, String term) {
    return sentence.replaceFirst(
        RegExp(RegExp.escape(term), caseSensitive: false), '_____');
  }

  static String _replaceTerm(String sentence, String term, String replacement) {
    return sentence.replaceFirst(
        RegExp(RegExp.escape(term), caseSensitive: false), replacement);
  }

  static bool _isClearSentence(String s) {
    final wc = s.split(RegExp(r'\s+')).length;
    if (wc < 5 || wc > 30) return false;
    return _contentWords(s).length >= 2;
  }

  static Difficulty _difficultyFor(String sentence) {
    final wc = sentence.split(RegExp(r'\s+')).length;
    if (wc <= 10) return Difficulty.easy;
    if (wc <= 20) return Difficulty.medium;
    return Difficulty.hard;
  }

  static String _asPoint(String sentence) {
    var p = sentence.trim();
    if (p.endsWith('.')) p = p.substring(0, p.length - 1);
    // Keep points concise for quick revision.
    final words = p.split(RegExp(r'\s+'));
    if (words.length > 18) p = '${words.take(18).join(' ')}…';
    return p;
  }

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

class _Definition {
  const _Definition({required this.term, required this.sentence});
  final String term;
  final String sentence;
}
