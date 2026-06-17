import '../data/models/enums.dart';

/// On-device AI readiness, surfaced in the UI.
enum AiAvailability { available, downloading, unsupported, mock }

/// A summary produced by an [AiService].
class AiSummary {
  const AiSummary({
    required this.shortSummary,
    required this.detailedSummary,
    required this.keyPoints,
  });

  final String shortSummary;
  final String detailedSummary;
  final List<String> keyPoints;
}

/// A draft flashcard produced by an [AiService] (before it is saved to Hive).
class AiFlashcardDraft {
  const AiFlashcardDraft({
    required this.question,
    required this.answer,
    required this.difficulty,
  });

  final String question;
  final String answer;
  final Difficulty difficulty;
}

/// Abstraction over the study AI features.
///
/// Phase 4 ships [MockAiService]; Phase 5 adds a Gemini Nano implementation
/// behind the same interface, so screens never change. Inputs are kept small
/// because on-device models have tight token limits.
abstract class AiService {
  Future<AiAvailability> checkAvailability();

  Future<AiSummary> summarizeText(String text);

  Future<List<AiFlashcardDraft>> generateFlashcards(String text, {int count});

  Future<String> proofreadText(String text);

  Future<String> rewriteText(String text, RewriteTone tone);
}
