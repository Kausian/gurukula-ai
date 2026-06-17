import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/providers.dart';

/// Library: a saved learning space, all stored on device, backed by Hive.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  static const List<String> _filters = [
    'All',
    'Notes',
    'Summaries',
    'Flashcards',
    'Ideas',
  ];

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in a later phase')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(libraryFilterProvider);
    final allItems = ref.watch(libraryItemsProvider);

    final items = selected == 0
        ? allItems
        : allItems
            .where((i) => i.category == LibraryCategory.values[selected - 1])
            .toList();

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
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Search your library',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 14),
              FilterChipRow(
                labels: _filters,
                selectedIndex: selected,
                onSelected: (index) =>
                    ref.read(libraryFilterProvider.notifier).state = index,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.folder_open_rounded,
                        title: 'Nothing here yet',
                        message:
                            'Items you create will appear here, all stored '
                            'privately on your device.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _LibraryTile(
                          item: items[index],
                          onTap: () => _comingSoon(context),
                        ),
                      ),
              ),
            ],
          ),
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
    }
  }
}

class _TileStyle {
  const _TileStyle(this.icon, this.color, this.label);
  final IconData icon;
  final Color color;
  final String label;
}
