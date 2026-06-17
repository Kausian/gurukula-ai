import '../core/utils/text_clean.dart';
import '../data/models/enums.dart';
import 'ai_service.dart';

/// A deterministic, offline stand-in for on-device AI.
///
/// Uses simple text heuristics so the whole study flow works before real
/// Gemini Nano integration (Phase 5). Outputs are intentionally lightweight.
class MockAiService implements AiService {
  const MockAiService();

  // Small simulated processing delay so the UI shows real loading states.
  static const _delay = Duration(milliseconds: 550);

  @override
  Future<AiAvailability> checkAvailability() async => AiAvailability.mock;

  @override
  Future<AiSummary> summarizeText(String text) async {
    await Future<void>.delayed(_delay);
    final sentences = splitSentences(text);
    if (sentences.isEmpty) {
      return const AiSummary(
        shortSummary: 'No text to summarize yet.',
        detailedSummary: 'Add some notes to generate a summary.',
        keyPoints: [],
      );
    }

    final shortSummary = sentences.first;
    final detailedSummary = sentences.take(3).join(' ');
    final keyPoints = sentences
        .take(5)
        .map((s) => firstWords(s, 12))
        .map((s) => s.endsWith('.') ? s.substring(0, s.length - 1) : s)
        .toList();

    return AiSummary(
      shortSummary: shortSummary,
      detailedSummary: detailedSummary,
      keyPoints: keyPoints,
    );
  }

  @override
  Future<List<AiFlashcardDraft>> generateFlashcards(String text,
      {int count = 5}) async {
    await Future<void>.delayed(_delay);
    final sentences = splitSentences(text);
    const difficulties = Difficulty.values;
    final drafts = <AiFlashcardDraft>[];

    for (var i = 0; i < sentences.length && drafts.length < count; i++) {
      final sentence = sentences[i];
      final topic = firstWords(sentence, 6);
      drafts.add(
        AiFlashcardDraft(
          question: 'Explain: $topic',
          answer: sentence,
          difficulty: difficulties[i % difficulties.length],
        ),
      );
    }
    return drafts;
  }

  @override
  Future<String> proofreadText(String text) async {
    await Future<void>.delayed(_delay);
    final cleaned = cleanText(text);
    final sentences = splitSentences(cleaned);
    final fixed = sentences.map((s) {
      var t = s.trim();
      if (t.isEmpty) return t;
      t = t[0].toUpperCase() + t.substring(1);
      if (!RegExp(r'[.!?]$').hasMatch(t)) t = '$t.';
      return t;
    });
    return fixed.join(' ');
  }

  @override
  Future<String> rewriteText(String text, RewriteTone tone) async {
    await Future<void>.delayed(_delay);
    final sentences = splitSentences(cleanText(text));
    if (sentences.isEmpty) return text.trim();

    switch (tone) {
      case RewriteTone.short:
        return sentences.take(2).join(' ');
      case RewriteTone.simple:
        return 'In simple terms: ${sentences.take(2).join(' ')}';
      case RewriteTone.formal:
        return 'To put it formally, ${sentences.take(3).join(' ')}';
      case RewriteTone.proofread:
        return proofreadText(text);
    }
  }
}
