import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../study_providers.dart';

/// Note tab (v1.17.0): a read-only view of the source note that all study
/// tools generate from.
///
/// It always reads the current [StudyDocument] via [documentProvider], so
/// editing the note and returning here shows the latest saved title and body.
/// This is intentionally *not* an editor — it links out to the existing note
/// editor at `/note/:id/edit` so there is a single source of truth for editing.
class NoteTab extends ConsumerWidget {
  const NoteTab({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final document = ref.watch(documentProvider(documentId));

    if (document == null) {
      return const EmptyState(
        icon: Icons.description_outlined,
        title: 'Note not found',
        message: 'This note could not be loaded.',
      );
    }

    final body = document.cleanedText.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Source note', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => context.push('/note/$documentId/edit'),
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Edit note'),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'This is the note your summaries, flashcards and quizzes are '
          'generated from.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        Text(document.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        AppCard(
          child: body.isEmpty
              ? Row(
                  children: [
                    Icon(Icons.notes_rounded,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This note is empty. Tap "Edit note" to add content.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                )
              // Selectable so students can copy straight from the source note.
              : SelectableText(body, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 15, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Stored locally on this device.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
