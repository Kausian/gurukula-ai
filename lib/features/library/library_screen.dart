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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final selected = ref.watch(libraryFilterProvider);
    final query = ref.watch(librarySearchProvider);
    final sort = ref.watch(librarySortProvider);
    final source = ref.watch(librarySourceProvider);
    final allItems = ref.watch(libraryItemsProvider);

    final items = filterAndSortLibrary(
      allItems,
      query: query,
      typeIndex: selected,
      sort: sort,
      source: source,
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
                onSelected: (index) =>
                    ref.read(libraryFilterProvider.notifier).state = index,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('${items.length} ${items.length == 1 ? 'item' : 'items'}',
                      style: theme.textTheme.bodySmall),
                  const Spacer(),
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
              const SizedBox(height: 4),
              Expanded(
                child: items.isEmpty
                    ? _emptyState(allItems.isEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _LibraryTile(
                          item: items[index],
                          onTap: () => _open(items[index]),
                        ),
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

  Widget _emptyState(bool libraryEmpty) {
    final state = libraryEmpty
        ? const EmptyState(
            icon: Icons.folder_open_rounded,
            title: 'Nothing here yet',
            message: 'Items you create will appear here, all stored privately '
                'on your device.',
          )
        : const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No matches',
            message: 'Try a different search or filter.',
          );
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
