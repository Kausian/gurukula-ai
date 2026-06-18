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

/// A quiz question produced by an [AiService] (before it is saved to Hive).
class AiQuizQuestion {
  const AiQuizQuestion({
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  final QuestionType type;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
}

/// The inputs a student gives the Idea Lab to generate a new project idea.
class IdeaBrief {
  const IdeaBrief({
    required this.subject,
    required this.skillLevel,
    required this.problemArea,
    required this.techStack,
    required this.timeLimit,
    required this.zeroCost,
  });

  final String subject;
  final Difficulty skillLevel;
  final String problemArea;
  final String techStack;
  final String timeLimit;
  final bool zeroCost;
}

/// A structured project idea produced by an [AiService] (maps to the Hive Idea).
class AiIdea {
  const AiIdea({
    required this.title,
    required this.problem,
    required this.targetUsers,
    required this.features,
    required this.techStack,
    required this.difficulty,
    required this.mvpPlan,
    required this.whyUnique,
  });

  final String title;
  final String problem;
  final List<String> targetUsers;
  final List<String> features;
  final List<String> techStack;
  final Difficulty difficulty;
  final String mvpPlan;
  final String whyUnique;

  AiIdea copyWith({
    String? title,
    String? problem,
    List<String>? targetUsers,
    List<String>? features,
    List<String>? techStack,
    Difficulty? difficulty,
    String? mvpPlan,
    String? whyUnique,
  }) {
    return AiIdea(
      title: title ?? this.title,
      problem: problem ?? this.problem,
      targetUsers: targetUsers ?? this.targetUsers,
      features: features ?? this.features,
      techStack: techStack ?? this.techStack,
      difficulty: difficulty ?? this.difficulty,
      mvpPlan: mvpPlan ?? this.mvpPlan,
      whyUnique: whyUnique ?? this.whyUnique,
    );
  }
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

  Future<List<AiQuizQuestion>> generateQuiz(String text, {int count});

  // ---- Idea Lab ----

  Future<AiIdea> generateIdea(IdeaBrief brief);

  Future<AiIdea> improveIdea(AiIdea current, {String guidance});

  Future<String> projectPlanFor(AiIdea idea);

  Future<String> cvPitchFor(AiIdea idea);
}
