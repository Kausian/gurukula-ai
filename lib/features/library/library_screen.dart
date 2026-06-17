import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_chip_row.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_badge.dart';

/// Library: a saved learning space, all stored on device.
///
/// Search and filters are interactive shells for now; real content is populated
/// once local storage lands in Phase 2.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const List<String> _filters = [
    'All',
    'Notes',
    'Summaries',
    'Flashcards',
    'Ideas',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
              const FilterChipRow(labels: _filters),
              const Expanded(
                child: EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'Nothing saved yet',
                  message:
                      'Your notes, summaries, flashcards and ideas will live '
                      'here, all stored privately on your device.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
