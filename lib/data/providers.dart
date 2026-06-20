import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // StateProvider (Riverpod 3.x)
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'local/hive_boxes.dart';
import 'models/activity_event.dart';
import 'models/enums.dart';
import 'models/flashcard.dart';
import 'models/idea.dart';
import 'models/quiz.dart';
import 'models/quiz_result.dart';
import 'models/rewrite.dart';
import 'models/study_document.dart';
import 'models/summary.dart';
import 'models/user_profile.dart';
import 'repositories/activity_repository.dart';
import 'repositories/document_repository.dart';
import 'repositories/flashcard_repository.dart';
import 'repositories/idea_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/quiz_repository.dart';
import 'repositories/quiz_result_repository.dart';
import 'repositories/rewrite_repository.dart';
import 'repositories/summary_repository.dart';

// ---------------------------------------------------------------------------
// Repository providers. Each binds a repository to its already-opened box.
// ---------------------------------------------------------------------------

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(Hive.box<UserProfile>(HiveBoxes.profiles)),
);

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepository(Hive.box<StudyDocument>(HiveBoxes.documents)),
);

final summaryRepositoryProvider = Provider<SummaryRepository>(
  (ref) => SummaryRepository(Hive.box<Summary>(HiveBoxes.summaries)),
);

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepository(Hive.box<Flashcard>(HiveBoxes.flashcards)),
);

final rewriteRepositoryProvider = Provider<RewriteRepository>(
  (ref) => RewriteRepository(Hive.box<Rewrite>(HiveBoxes.rewrites)),
);

final ideaRepositoryProvider = Provider<IdeaRepository>(
  (ref) => IdeaRepository(Hive.box<Idea>(HiveBoxes.ideas)),
);

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepository(Hive.box<Quiz>(HiveBoxes.quizzes)),
);

final quizResultRepositoryProvider = Provider<QuizResultRepository>(
  (ref) => QuizResultRepository(Hive.box<QuizResult>(HiveBoxes.quizResults)),
);

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(Hive.box<ActivityEvent>(HiveBoxes.activity)),
);

// ---------------------------------------------------------------------------
// Reactivity: emits whenever any study-data box changes, so the derived
// providers and the Study Workspace rebuild automatically after writes.
// ---------------------------------------------------------------------------

final dataChangesProvider = StreamProvider<int>((ref) {
  final boxes = <Box<dynamic>>[
    ref.watch(profileRepositoryProvider).box,
    ref.watch(documentRepositoryProvider).box,
    ref.watch(summaryRepositoryProvider).box,
    ref.watch(flashcardRepositoryProvider).box,
    ref.watch(rewriteRepositoryProvider).box,
    ref.watch(ideaRepositoryProvider).box,
    ref.watch(quizRepositoryProvider).box,
    ref.watch(quizResultRepositoryProvider).box,
    ref.watch(activityRepositoryProvider).box,
  ];
  final controller = StreamController<int>();
  // Emit a distinct, incrementing value per change so watchers always rebuild
  // (an AsyncData<void>(null) would be deduped as "unchanged" by Riverpod).
  var tick = 0;
  final subs =
      boxes.map((b) => b.watch().listen((_) => controller.add(++tick))).toList();
  ref.onDispose(() {
    for (final sub in subs) {
      sub.cancel();
    }
    controller.close();
  });
  return controller.stream;
});

// ---------------------------------------------------------------------------
// Derived read models for the screens.
// ---------------------------------------------------------------------------

/// The current student profile (null until one is created).
final currentProfileProvider = Provider<UserProfile?>((ref) {
  ref.watch(dataChangesProvider);
  return ref.watch(profileRepositoryProvider).current;
});

/// Aggregate counts shown on Home and Profile.
class DashboardStats {
  const DashboardStats({
    required this.notes,
    required this.flashcards,
    required this.ideas,
    required this.quizzes,
    required this.sessions,
  });

  final int notes;
  final int flashcards;
  final int ideas;
  final int quizzes;
  final int sessions;
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  ref.watch(dataChangesProvider);
  return DashboardStats(
    notes: ref.watch(documentRepositoryProvider).getAll().length,
    flashcards: ref.watch(flashcardRepositoryProvider).getAll().length,
    ideas: ref.watch(ideaRepositoryProvider).getAll().length,
    quizzes: ref.watch(quizResultRepositoryProvider).getAll().length,
    sessions: ref.watch(activityRepositoryProvider).getAll().length,
  );
});

/// Recent activity events for the Home dashboard.
final recentActivityProvider = Provider<List<ActivityEvent>>((ref) {
  ref.watch(dataChangesProvider);
  return ref.watch(activityRepositoryProvider).recent();
});

/// Revision summary for Home: review counts, plus spaced-practice scheduling
/// (Phase 11B) — how many cards are due now and how many are upcoming.
class RevisionStats {
  const RevisionStats({
    required this.reviewed,
    required this.hard,
    required this.due,
    required this.upcoming,
    required this.recent,
  });

  final int reviewed;
  final int hard;
  final int due;
  final int upcoming;
  final List<Flashcard> recent;
}

final revisionStatsProvider = Provider<RevisionStats>((ref) {
  ref.watch(dataChangesProvider);
  final repo = ref.watch(flashcardRepositoryProvider);
  return RevisionStats(
    reviewed: repo.reviewedCount,
    hard: repo.hardReviewedCount,
    due: repo.dueCount(),
    upcoming: repo.upcomingCount(),
    recent: repo.recentlyReviewed(),
  );
});

// ---------------------------------------------------------------------------
// Library view model: a single list across all saved content types.
// ---------------------------------------------------------------------------

enum LibraryCategory { notes, summaries, flashcards, ideas, quizzes, rewrites }

/// How the Library list is ordered (Phase 12A).
enum LibrarySort { newest, oldest }

/// Where a library item ultimately came from (Phase 12B). Items with no parent
/// document (ideas) have a null source and only show under the "All" filter.
enum LibrarySource { pasted, txt, pdf }

class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.documentId,
    this.source,
    this.sourceFileName,
    this.searchText = '',
  });

  final String id;
  final String title;
  final LibraryCategory category;
  final DateTime createdAt;

  /// Parent study document (Phase 12B): a note is its own document; summaries,
  /// flashcards, quizzes and rewrites point at the note they came from. Null
  /// for ideas (and orphaned items whose document was deleted).
  final String? documentId;

  /// How this item's parent document entered the app (Phase 12B). Null when
  /// there is no parent document.
  final LibrarySource? source;

  /// Original imported file name, when the item came from a file (Phase 9).
  final String? sourceFileName;

  /// Lowercased, bounded index of title + file name + a content preview, used
  /// by Library search (Phase 12A).
  final String searchText;
}

/// Derives a [LibrarySource] from the parent document: PDF type → pdf, text
/// type with a file name → txt import, text type without one → pasted.
LibrarySource _sourceOf(StudyDocument doc) {
  if (doc.type == DocumentType.pdf) return LibrarySource.pdf;
  if ((doc.sourceFileName ?? '').isNotEmpty) return LibrarySource.txt;
  return LibrarySource.pasted;
}

/// Selected type-filter chip index on the Library screen (0 = All).
final libraryFilterProvider = StateProvider<int>((ref) => 0);

/// Current Library search query (Phase 12A).
final librarySearchProvider = StateProvider<String>((ref) => '');

/// Current Library sort order (Phase 12A).
final librarySortProvider = StateProvider<LibrarySort>((ref) => LibrarySort.newest);

/// Current Library source filter (Phase 12B). Null = All sources.
final librarySourceProvider = StateProvider<LibrarySource?>((ref) => null);

/// Builds the search index for an item: title + file name + a bounded preview
/// so search stays fast even for large imported documents.
String _librarySearchText(String title, String? fileName, String body) {
  final preview = body.length > 500 ? body.substring(0, 500) : body;
  return '$title ${fileName ?? ''} $preview'.toLowerCase();
}

/// A short, human-readable title for a rewrite, which has no title of its own.
String _rewriteTitle(RewriteTone tone) {
  switch (tone) {
    case RewriteTone.proofread:
      return 'Proofread text';
    case RewriteTone.simple:
      return 'Simplified text';
    case RewriteTone.formal:
      return 'Formal rewrite';
    case RewriteTone.short:
      return 'Shortened text';
  }
}

/// All saved items, newest first, ready for the Library list.
final libraryItemsProvider = Provider<List<LibraryItem>>((ref) {
  ref.watch(dataChangesProvider);
  final documents = ref.watch(documentRepositoryProvider).getAll();
  final summaries = ref.watch(summaryRepositoryProvider).getAll();
  final flashcards = ref.watch(flashcardRepositoryProvider).getAll();
  final ideas = ref.watch(ideaRepositoryProvider).getAll();
  final quizzes = ref.watch(quizRepositoryProvider).getAll();
  final rewrites = ref.watch(rewriteRepositoryProvider).getAll();
  final docRepo = ref.watch(documentRepositoryProvider);

  final items = <LibraryItem>[
    for (final d in documents)
      LibraryItem(
        id: d.id,
        title: d.title,
        category: LibraryCategory.notes,
        createdAt: d.createdAt,
        documentId: d.id,
        source: _sourceOf(d),
        sourceFileName: d.sourceFileName,
        searchText: _librarySearchText(d.title, d.sourceFileName, d.cleanedText),
      ),
    for (final s in summaries)
      () {
        final doc = docRepo.getById(s.documentId);
        final title = doc?.title ?? 'Summary';
        return LibraryItem(
          id: s.id,
          title: title,
          category: LibraryCategory.summaries,
          createdAt: s.createdAt,
          documentId: s.documentId,
          source: doc == null ? null : _sourceOf(doc),
          sourceFileName: doc?.sourceFileName,
          searchText: _librarySearchText(title, doc?.sourceFileName,
              '${s.shortSummary} ${s.keyPoints.join(' ')}'),
        );
      }(),
    for (final f in flashcards)
      () {
        final doc = docRepo.getById(f.documentId);
        return LibraryItem(
          id: f.id,
          title: f.question,
          category: LibraryCategory.flashcards,
          createdAt: f.createdAt,
          documentId: f.documentId,
          source: doc == null ? null : _sourceOf(doc),
          sourceFileName: doc?.sourceFileName,
          searchText: _librarySearchText(
              f.question, doc?.sourceFileName, f.answer),
        );
      }(),
    for (final i in ideas)
      LibraryItem(
        id: i.id,
        title: i.title,
        category: LibraryCategory.ideas,
        createdAt: i.createdAt,
        searchText:
            _librarySearchText(i.title, null, '${i.problem} ${i.features.join(' ')}'),
      ),
    for (final q in quizzes)
      () {
        final doc = docRepo.getById(q.documentId);
        return LibraryItem(
          id: q.id,
          title: q.title,
          category: LibraryCategory.quizzes,
          createdAt: q.createdAt,
          documentId: q.documentId,
          source: doc == null ? null : _sourceOf(doc),
          sourceFileName: doc?.sourceFileName,
          searchText: _librarySearchText(q.title, doc?.sourceFileName,
              q.questions.map((qq) => qq.prompt).join(' ')),
        );
      }(),
    for (final r in rewrites)
      () {
        final doc = docRepo.getById(r.documentId);
        final title = _rewriteTitle(r.tone);
        return LibraryItem(
          id: r.id,
          title: title,
          category: LibraryCategory.rewrites,
          createdAt: r.createdAt,
          documentId: r.documentId,
          source: doc == null ? null : _sourceOf(doc),
          sourceFileName: doc?.sourceFileName,
          searchText:
              _librarySearchText(title, doc?.sourceFileName, r.rewrittenText),
        );
      }(),
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return items;
});
