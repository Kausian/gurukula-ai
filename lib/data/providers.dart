import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart'; // StateProvider (Riverpod 3.x)
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'local/hive_boxes.dart';
import 'models/activity_event.dart';
import 'models/flashcard.dart';
import 'models/idea.dart';
import 'models/rewrite.dart';
import 'models/study_document.dart';
import 'models/summary.dart';
import 'models/user_profile.dart';
import 'repositories/activity_repository.dart';
import 'repositories/document_repository.dart';
import 'repositories/flashcard_repository.dart';
import 'repositories/idea_repository.dart';
import 'repositories/profile_repository.dart';
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
    required this.sessions,
  });

  final int notes;
  final int flashcards;
  final int ideas;
  final int sessions;
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  ref.watch(dataChangesProvider);
  return DashboardStats(
    notes: ref.watch(documentRepositoryProvider).getAll().length,
    flashcards: ref.watch(flashcardRepositoryProvider).getAll().length,
    ideas: ref.watch(ideaRepositoryProvider).getAll().length,
    sessions: ref.watch(activityRepositoryProvider).getAll().length,
  );
});

/// Recent activity events for the Home dashboard.
final recentActivityProvider = Provider<List<ActivityEvent>>((ref) {
  ref.watch(dataChangesProvider);
  return ref.watch(activityRepositoryProvider).recent();
});

// ---------------------------------------------------------------------------
// Library view model: a single list across all saved content types.
// ---------------------------------------------------------------------------

enum LibraryCategory { notes, summaries, flashcards, ideas }

class LibraryItem {
  const LibraryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final LibraryCategory category;
  final DateTime createdAt;
}

/// Selected filter chip index on the Library screen (0 = All).
final libraryFilterProvider = StateProvider<int>((ref) => 0);

/// All saved items, newest first, ready for the Library list.
final libraryItemsProvider = Provider<List<LibraryItem>>((ref) {
  ref.watch(dataChangesProvider);
  final documents = ref.watch(documentRepositoryProvider).getAll();
  final summaries = ref.watch(summaryRepositoryProvider).getAll();
  final flashcards = ref.watch(flashcardRepositoryProvider).getAll();
  final ideas = ref.watch(ideaRepositoryProvider).getAll();
  final docRepo = ref.watch(documentRepositoryProvider);

  final items = <LibraryItem>[
    for (final d in documents)
      LibraryItem(
        id: d.id,
        title: d.title,
        category: LibraryCategory.notes,
        createdAt: d.createdAt,
      ),
    for (final s in summaries)
      LibraryItem(
        id: s.id,
        title: docRepo.getById(s.documentId)?.title ?? 'Summary',
        category: LibraryCategory.summaries,
        createdAt: s.createdAt,
      ),
    for (final f in flashcards)
      LibraryItem(
        id: f.id,
        title: f.question,
        category: LibraryCategory.flashcards,
        createdAt: f.createdAt,
      ),
    for (final i in ideas)
      LibraryItem(
        id: i.id,
        title: i.title,
        category: LibraryCategory.ideas,
        createdAt: i.createdAt,
      ),
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return items;
});
