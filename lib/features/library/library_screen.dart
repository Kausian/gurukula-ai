import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/library_filter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/providers.dart';
import 'rewrite_preview_sheet.dart';

/// Library: a saved learning space, all stored on device, backed by Hive.
///
/// Phase 12A adds live search, a Rewrites type, and newest/oldest sorting.
/// v1.18.0 adds note-centric organization: richer note cards (what each note
/// contains + freshness), favorites, and a note-attribute filter row.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _search = TextEditingController();

  // Order must match LibraryCategory.values (All is prepended).
  static const List<String> _filters = [
    'All',
    'Notes',
    'Summaries',
    'Flashcards',
    'Ideas',
    'Quizzes',
    'Rewrites',
  ];

  // Order must match LibraryNoteFilter.values.
  static const List<String> _noteFilters = [
    'All notes',
    'Favorites',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Opens a library item: workspace for notes and generated content, the idea
  /// detail for ideas, and a read-only preview sheet for rewrites (Phase 12B).
  void _open(LibraryItem item) {
    switch (item.category) {
      case LibraryCategory.notes:
      case LibraryCategory.summaries:
      case LibraryCategory.flashcards:
      case LibraryCategory.quizzes:
        final docId = item.documentId;
        if (docId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Original note not found')),
          );
          return;
        }
        context.push('/workspace/$docId');
      case LibraryCategory.ideas:
        context.push('/idea/${item.id}');
      case LibraryCategory.rewrites:
        showRewritePreview(context, ref, item.id, item.title);
    }
  }

  /// Picking a content-type chip clears the note lens, so the two filters never
  /// fight and produce a confusing empty list.
  void _onTypeSelected(int index) {
    ref.read(libraryFilterProvider.notifier).state = index;
    ref.read(libraryNoteFilterProvider.notifier).state = LibraryNoteFilter.all;
  }

  /// Picking a note lens (other than "All notes") clears the type chip to All,
  /// so the note filter reads as an independent lens over notes.
  void _onNoteFilterSelected(int index) {
    final value = LibraryNoteFilter.values[index];
    ref.read(libraryNoteFilterProvider.notifier).state = value;
    if (value != LibraryNoteFilter.all) {
      ref.read(libraryFilterProvider.notifier).state = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final selected = ref.watch(libraryFilterProvider);
    final query = ref.watch(librarySearchProvider);
    final sort = ref.watch(librarySortProvider);
    final source = ref.watch(librarySourceProvider);
    final noteFilter = ref.watch(libraryNoteFilterProvider);
    final allItems = ref.watch(libraryItemsProvider);

    final items = filterAndSortLibrary(
      allItems,
      query: query,
      typeIndex: selected,
      sort: sort,
      source: source,
      noteFilter: noteFilter,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Library',
                subtitle: 'Everything you create, in one place.',
                trailing: StatusBadge(
                    label: 'On device',
                    icon: Icons.lock_rounded,
                    tone: BadgeTone.success),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _search,
                onChanged: (value) =>
                    ref.read(librarySearchProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search your library',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: scheme.onSurfaceVariant),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Clear',
                          onPressed: () {
                            _search.clear();
                            ref.read(librarySearchProvider.notifier).state = '';
                          },
                        ),
                ),
              ),
              const SizedBox(height: 14),
              FilterChipRow(
                labels: _filters,
                selectedIndex: selected,
                onSelected: _onTypeSelected,
              ),
              const SizedBox(height: 10),
              FilterChipRow(
                labels: _noteFilters,
                selectedIndex: noteFilter.index,
                onSelected: _onNoteFilterSelected,
              ),
              const SizedBox(height: 8),
              // OverflowBar keeps the count and the source/sort controls on one
              // line when they fit, and stacks them when the screen is too
              // narrow or the font is large, so the row never overflows.
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowAlignment: OverflowBarAlignment.start,
                overflowSpacing: 4,
                children: [
                  Text('${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: theme.textTheme.bodySmall),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  PopupMenuButton<LibrarySource?>(
                    initialValue: source,
                    tooltip: 'Filter by source',
                    onSelected: (value) =>
                        ref.read(librarySourceProvider.notifier).state = value,
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: null, child: Text('All sources')),
                      PopupMenuItem(
                          value: LibrarySource.pasted, child: Text('Pasted')),
                      PopupMenuItem(
                          value: LibrarySource.txt, child: Text('TXT import')),
                      PopupMenuItem(
                          value: LibrarySource.pdf, child: Text('PDF import')),
                      PopupMenuItem(
                          value: LibrarySource.image, child: Text('Scanned')),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list_rounded,
                            size: 18, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(_sourceLabel(source),
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: scheme.primary)),
                        Icon(Icons.arrow_drop_down_rounded, color: scheme.primary),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(librarySortProvider.notifier).state =
                            sort == LibrarySort.newest
                                ? LibrarySort.oldest
                                : LibrarySort.newest,
                    icon: Icon(
                        sort == LibrarySort.newest
                            ? Icons.south_rounded
                            : Icons.north_rounded,
                        size: 18),
                    label: Text(
                        sort == LibrarySort.newest ? 'Newest' : 'Oldest'),
                  ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: items.isEmpty
                    ? _emptyState(allItems.isEmpty, noteFilter, query)
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item.category == LibraryCategory.notes) {
                            return _NoteLibraryTile(
                              item: item,
                              onTap: () => _open(item),
                              onToggleFavorite: () => ref
                                  .read(favoriteDocIdsProvider.notifier)
                                  .toggle(item.id),
                            );
                          }
                          return _LibraryTile(
                            item: item,
                            onTap: () => _open(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sourceLabel(LibrarySource? source) {
    switch (source) {
      case null:
        return 'Source';
      case LibrarySource.pasted:
        return 'Pasted';
      case LibrarySource.txt:
        return 'TXT';
      case LibrarySource.pdf:
        return 'PDF';
      case LibrarySource.image:
        return 'Scanned';
    }
  }

  Widget _emptyState(
      bool libraryEmpty, LibraryNoteFilter noteFilter, String query) {
    late final EmptyState state;
    if (libraryEmpty) {
      // First-note guidance for new users (v1.25.0): a clear path to add or
      // import notes, since a fresh Library has nothing to open yet.
      state = EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'Start your study space',
        message: 'Add your first note to create summaries, flashcards and '
            'quizzes. Everything stays on your device.',
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () => context.push('/paste'),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Add a note'),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => context.go('/upload'),
              icon: const Icon(Icons.file_upload_outlined, size: 20),
              label: const Text('Import from file, PDF or scan'),
            ),
          ],
        ),
      );
    } else if (noteFilter == LibraryNoteFilter.favorites) {
      state = const EmptyState(
        icon: Icons.star_outline_rounded,
        title: 'No favorites yet',
        message: 'Tap the star on a note to keep it here for quick access.',
      );
    } else {
      state = const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matches',
        message: 'Try a different search or filter.',
      );
    }
    // Make the empty state keyboard-safe: when the keyboard shrinks the
    // available height below the content, it scrolls instead of overflowing,
    // and stays vertically centered when there is room.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: state,
        ),
      ),
    );
  }
}

/// A rich note card (v1.18.0): title, preview, metadata, what the note
/// contains (summary/flashcards/quiz), a freshness flag, and a favorite star.
class _NoteLibraryTile extends StatelessWidget {
  const _NoteLibraryTile({
    required this.item,
    this.onTap,
    this.onToggleFavorite,
  });

  final LibraryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final updated = item.updatedAt ?? item.createdAt;

    final meta = <String>[
      _sourceName(item.source),
      'Updated ${timeAgo(updated)}',
      item.wordCount == 0 ? 'Empty note' : '${item.wordCount} words',
    ].where((s) => s.isNotEmpty).join('  ·  ');

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconChip(
              icon: Icons.description_rounded,
              color: AppAccents.lavender.fill,
              size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                if (item.preview.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(item.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 6),
                Text(meta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            iconSize: 22,
            visualDensity: VisualDensity.compact,
            tooltip: item.isFavorite ? 'Unfavorite' : 'Favorite',
            onPressed: onToggleFavorite,
            icon: Icon(
              item.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: item.isFavorite
                  ? AppAccents.lime.fill
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _sourceName(LibrarySource? source) {
    switch (source) {
      case LibrarySource.pasted:
        return 'Pasted';
      case LibrarySource.txt:
        return 'TXT';
      case LibrarySource.pdf:
        return 'PDF';
      case LibrarySource.image:
        return 'Scanned';
      case null:
        return '';
    }
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.item, this.onTap});

  final LibraryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleFor(item.category);
    final fileName = item.sourceFileName;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconChip(icon: style.icon, color: style.color, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text('${style.label} · ${timeAgo(item.createdAt)}',
                    style: theme.textTheme.bodySmall),
                if (fileName != null && fileName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.insert_drive_file_outlined,
                          size: 13, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _TileStyle _styleFor(LibraryCategory category) {
    switch (category) {
      case LibraryCategory.notes:
        return _TileStyle(
            Icons.description_rounded, AppAccents.lavender.fill, 'Note');
      case LibraryCategory.summaries:
        return _TileStyle(
            Icons.summarize_rounded, AppAccents.mint.fill, 'Summary');
      case LibraryCategory.flashcards:
        return _TileStyle(
            Icons.style_rounded, AppAccents.lime.fill, 'Flashcard');
      case LibraryCategory.ideas:
        return _TileStyle(
            Icons.lightbulb_rounded, AppAccents.coral.fill, 'Idea');
      case LibraryCategory.quizzes:
        return _TileStyle(Icons.quiz_rounded, AppAccents.sky.fill, 'Quiz');
      case LibraryCategory.rewrites:
        return _TileStyle(
            Icons.edit_note_rounded, AppAccents.pink.fill, 'Rewrite');
    }
  }
}

class _TileStyle {
  const _TileStyle(this.icon, this.color, this.label);
  final IconData icon;
  final Color color;
  final String label;
}
