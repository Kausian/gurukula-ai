import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/export_filename.dart';
import '../../../core/utils/share_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/share_actions.dart';
import '../../../services/txt_export_service.dart';
import '../quiz_providers.dart';
import '../study_providers.dart';

/// Note tab (v1.17.0): a read-only view of the source note that all study
/// tools generate from. v1.23.0 adds clean export of the source note and a
/// combined "study pack" export.
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
        // Overflow-safe header: the title and the actions wrap onto separate
        // lines on narrow screens instead of overflowing.
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          overflowSpacing: 4,
          children: [
            Text('Source note', style: theme.textTheme.titleMedium),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShareActions(
                  label: 'Note',
                  fileBaseName: exportFileName(document.title, 'Note'),
                  buildText: () => ShareFormat.note(
                    document.title,
                    document.cleanedText,
                    updatedAt: document.updatedAt,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/note/$documentId/edit'),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Edit'),
                ),
              ],
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
                        'This note is empty. Tap "Edit" to add content.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                )
              // Selectable so students can copy straight from the source note.
              : SelectableText(body, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        _StudyPackButton(documentId: documentId),
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

/// Exports the note plus its summary, flashcards and quiz as one `.txt` study
/// pack (v1.23.0). Stateful for the busy state + success/error feedback.
class _StudyPackButton extends ConsumerStatefulWidget {
  const _StudyPackButton({required this.documentId});

  final String documentId;

  @override
  ConsumerState<_StudyPackButton> createState() => _StudyPackButtonState();
}

class _StudyPackButtonState extends ConsumerState<_StudyPackButton> {
  bool _busy = false;

  Future<void> _export() async {
    final document = ref.read(documentProvider(widget.documentId));
    if (document == null) return;
    setState(() => _busy = true);

    final text = ShareFormat.studyPack(
      title: document.title,
      note: document.cleanedText,
      summary: ref.read(summaryForDocumentProvider(widget.documentId)),
      flashcards: ref.read(flashcardsForDocumentProvider(widget.documentId)),
      quiz: ref.read(quizForDocumentProvider(widget.documentId)),
      exportedAt: DateTime.now(),
    );

    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await const TxtExportService().exportAsTxt(
        text: text,
        fileBaseName: exportFileName(document.title, 'Study pack'),
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (ok) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Study pack exported as .txt')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not export the study pack')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: _busy ? null : _export,
      icon: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : const Icon(Icons.inventory_2_outlined, size: 20),
      label: Text(_busy ? 'Preparing…' : 'Export study pack (.txt)'),
    );
  }
}
