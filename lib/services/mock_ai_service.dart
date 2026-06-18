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

  @override
  Future<AiIdea> generateIdea(IdeaBrief brief) async {
    await Future<void>.delayed(_delay);
    final subject =
        brief.subject.trim().isEmpty ? 'your field' : brief.subject.trim();
    final area =
        brief.problemArea.trim().isEmpty ? 'studying' : brief.problemArea.trim();
    final stack = brief.techStack.trim().isEmpty
        ? <String>[
            'Flutter',
            'Dart',
            'Local storage',
            if (brief.zeroCost) 'On-device AI',
          ]
        : brief.techStack
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    return AiIdea(
      title: 'Offline ${_titleCase(area)} Companion',
      problem:
          'Many $subject students struggle with $area because most tools need '
          'the internet, paid subscriptions, or cloud accounts.',
      targetUsers: [
        '$subject students',
        'Self-learners',
        'Students with limited internet',
      ],
      features: [
        'Works fully offline',
        'Helps with $area step by step',
        'Generates $subject study material',
        'Keeps all data private on the device',
        if (brief.zeroCost) 'Uses only free, on-device tools',
      ],
      techStack: stack,
      difficulty: brief.skillLevel,
      mvpPlan:
          'Phase 1: build the app shell and local storage. '
          'Phase 2: add the core $area flow. '
          'Phase 3: generate $subject content and polish offline support '
          '(target: ${brief.timeLimit}).',
      whyUnique:
          'Unlike most $area apps, it runs offline at zero cost and keeps '
          'every piece of student data on the device.',
    );
  }

  @override
  Future<AiIdea> improveIdea(AiIdea current, {String guidance = ''}) async {
    await Future<void>.delayed(_delay);
    const extra = <String>[
      'Smart reminders to keep a study streak',
      'Shareable progress summary',
    ];
    final features = [
      ...current.features,
      ...extra.where((f) => !current.features.contains(f)),
    ];
    final title =
        current.title.startsWith('Smart ') ? current.title : 'Smart ${current.title}';
    final note =
        guidance.trim().isEmpty ? '' : ' It now focuses on ${guidance.trim()}.';
    return current.copyWith(
      title: title,
      features: features,
      whyUnique:
          '${current.whyUnique}$note It is sharper and more focused than the '
          'first draft.',
    );
  }

  @override
  Future<String> projectPlanFor(AiIdea idea) async {
    await Future<void>.delayed(_delay);
    final first = idea.features.isNotEmpty
        ? idea.features.first.toLowerCase()
        : 'the core feature';
    final second = idea.features.length > 1
        ? idea.features[1].toLowerCase()
        : 'the main screens';
    return 'Week 1: Set up the app shell, navigation and local storage.\n'
        'Week 2: Build $first.\n'
        'Week 3: Add $second and connect the main screens.\n'
        'Week 4: Test everything offline, polish the UI, and write the README.';
  }

  @override
  Future<String> cvPitchFor(AiIdea idea) async {
    await Future<void>.delayed(_delay);
    return '${idea.title} demonstrates offline-first architecture, local data '
        'ownership and a real student problem solved at zero cost. On a CV, '
        'lead with the impact: ${idea.whyUnique}';
  }

  String _titleCase(String input) {
    return input
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
