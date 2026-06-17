import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/text_clean.dart';
import '../../data/models/activity_event.dart';
import '../../data/models/enums.dart';
import '../../data/models/flashcard.dart';
import '../../data/models/rewrite.dart';
import '../../data/models/study_document.dart';
import '../../data/models/summary.dart';
import '../../data/providers.dart';
import '../../services/ai_service.dart';
import '../../services/mock_ai_service.dart';

/// The active AI implementation. Mock for now; Gemini Nano drops in here later.
final aiServiceProvider = Provider<AiService>((ref) => const MockAiService());

/// Current on-device AI mode, shown in the Profile status card.
final aiModeProvider = Provider<AiAvailability>((ref) => AiAvailability.mock);

// ---------------------------------------------------------------------------
// Workspace read models, keyed by document id. All rebuild on data changes.
// ---------------------------------------------------------------------------

final documentProvider = Provider.family<StudyDocument?, String>((ref, id) {
  ref.watch(dataChangesProvider);
  return ref.watch(documentRepositoryProvider).getById(id);
});

final summaryForDocumentProvider = Provider.family<Summary?, String>((ref, id) {
  ref.watch(dataChangesProvider);
  final list = ref.watch(summaryRepositoryProvider).byDocument(id);
  return list.isEmpty ? null : list.first;
});

final flashcardsForDocumentProvider =
    Provider.family<List<Flashcard>, String>((ref, id) {
  ref.watch(dataChangesProvider);
  final cards = ref.watch(flashcardRepositoryProvider).byDocument(id)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return cards;
});

final rewritesForDocumentProvider =
    Provider.family<List<Rewrite>, String>((ref, id) {
  ref.watch(dataChangesProvider);
  final rewrites = ref.watch(rewriteRepositoryProvider).byDocument(id)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return rewrites;
});

/// Orchestrates the study flow: create a document, summarize, generate
/// flashcards and rewrites, and log each action as an [ActivityEvent].
final studyControllerProvider =
    Provider<StudyController>((ref) => StudyController(ref));

class StudyController {
  StudyController(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  AiService get _ai => _ref.read(aiServiceProvider);
  String get _userId => _ref.read(currentProfileProvider)?.id ?? 'local';

  Future<void> _log(ActivityType type, String referenceId, String title) {
    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: _userId,
      type: type,
      referenceId: referenceId,
      title: title,
      createdAt: DateTime.now().toUtc(),
    );
    return _ref.read(activityRepositoryProvider).save(event);
  }

  /// Creates a document from pasted text and auto-generates its summary.
  /// Returns the new document id.
  Future<String> createDocumentFromText({
    required String title,
    required String text,
  }) async {
    final cleaned = cleanText(text);
    final now = DateTime.now().toUtc();
    final docId = _uuid.v4();
    final resolvedTitle =
        title.trim().isEmpty ? _deriveTitle(cleaned) : title.trim();

    final document = StudyDocument(
      id: docId,
      userId: _userId,
      title: resolvedTitle,
      type: DocumentType.text,
      rawText: text,
      cleanedText: cleaned,
      createdAt: now,
      updatedAt: now,
    );
    await _ref.read(documentRepositoryProvider).save(document);
    await _log(ActivityType.documentUploaded, docId, resolvedTitle);

    final aiSummary = await _ai.summarizeText(cleaned);
    final summary = Summary(
      id: _uuid.v4(),
      documentId: docId,
      shortSummary: aiSummary.shortSummary,
      detailedSummary: aiSummary.detailedSummary,
      keyPoints: aiSummary.keyPoints,
      createdAt: DateTime.now().toUtc(),
    );
    await _ref.read(summaryRepositoryProvider).save(summary);
    await _log(ActivityType.summaryCreated, summary.id, '$resolvedTitle summary');

    return docId;
  }

  /// Generates and saves flashcards for a document. Returns how many were made.
  Future<int> generateFlashcards(String documentId, {int count = 5}) async {
    final document = _ref.read(documentRepositoryProvider).getById(documentId);
    if (document == null) return 0;

    final drafts =
        await _ai.generateFlashcards(document.cleanedText, count: count);
    final now = DateTime.now().toUtc();
    final repo = _ref.read(flashcardRepositoryProvider);

    for (final draft in drafts) {
      await repo.save(
        Flashcard(
          id: _uuid.v4(),
          documentId: documentId,
          question: draft.question,
          answer: draft.answer,
          difficulty: draft.difficulty,
          isReviewed: false,
          createdAt: now,
        ),
      );
    }
    if (drafts.isNotEmpty) {
      await _log(ActivityType.flashcardCreated, documentId,
          '${drafts.length} flashcards from ${document.title}');
    }
    return drafts.length;
  }

  /// Runs a proofread or rewrite and saves the result as a [Rewrite].
  Future<Rewrite> createRewrite(
    String documentId,
    String sourceText,
    RewriteTone tone,
  ) async {
    final result = tone == RewriteTone.proofread
        ? await _ai.proofreadText(sourceText)
        : await _ai.rewriteText(sourceText, tone);

    final rewrite = Rewrite(
      id: _uuid.v4(),
      documentId: documentId,
      originalText: sourceText,
      rewrittenText: result,
      tone: tone,
      createdAt: DateTime.now().toUtc(),
    );
    await _ref.read(rewriteRepositoryProvider).save(rewrite);
    await _log(ActivityType.rewriteCreated, rewrite.id, toneLabel(tone));
    return rewrite;
  }

  /// Toggles the reviewed state of a flashcard.
  Future<void> setReviewed(Flashcard card, bool reviewed) {
    return _ref
        .read(flashcardRepositoryProvider)
        .save(card.copyWith(isReviewed: reviewed));
  }

  String _deriveTitle(String cleaned) {
    final words = firstWords(cleaned, 6);
    if (words.isEmpty) return 'Untitled note';
    return words[0].toUpperCase() + words.substring(1);
  }
}

/// Human-readable label for a rewrite tone.
String toneLabel(RewriteTone tone) {
  switch (tone) {
    case RewriteTone.simple:
      return 'Rewritten simply';
    case RewriteTone.formal:
      return 'Rewritten formally';
    case RewriteTone.short:
      return 'Rewritten shortly';
    case RewriteTone.proofread:
      return 'Proofread';
  }
}
