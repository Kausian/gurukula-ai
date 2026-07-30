import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/export_filename.dart';
import '../../../core/utils/share_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/share_actions.dart';
import '../../../core/widgets/stale_notice_banner.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/flashcard.dart';
import '../../../services/ai_service.dart';
import '../study_providers.dart';
import 'generation_options.dart';

/// Flashcards tab: generated study cards with flip + reviewed toggle.
class FlashcardsTab extends ConsumerStatefulWidget {
  const FlashcardsTab({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends ConsumerState<FlashcardsTab> {
  bool _busy = false;
  FlashcardStyle _style = FlashcardStyle.quickRevision;

  Future<void> _generate() async {
    setState(() => _busy = true);
    final count = await ref
        .read(studyControllerProvider)
        .generateFlashcards(widget.documentId, style: _style);
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created $count flashcards')),
      );
    }
  }

  Widget _styleChips() => OptionChips<FlashcardStyle>(
        label: 'Flashcard style',
        options: FlashcardStyle.values,
        selected: _style,
        enabled: !_busy,
        labelOf: (s) => switch (s) {
          FlashcardStyle.quickRevision => 'Quick revision',
          FlashcardStyle.examPrep => 'Exam prep',
        },
        onSelected: (s) => setState(() => _style = s),
      );

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(flashcardsForDocumentProvider(widget.documentId));
    final document = ref.watch(documentProvider(widget.documentId));

    // Stale when the note was edited after the newest card was generated
    // (cards are sorted oldest-first).
    final stale = document != null &&
        cards.isNotEmpty &&
        document.updatedAt.isAfter(cards.last.createdAt);

    if (cards.isEmpty) {
      return EmptyState(
        icon: Icons.style_outlined,
        title: 'No flashcards yet',
        message: 'Generate a set of study cards from this note.',
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _styleChips(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _generate,
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_busy ? 'Generating' : 'Generate flashcards'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _styleChips(),
        const SizedBox(height: 16),
        if (stale) ...[
          StaleNoticeBanner(
            message: 'You edited this note after these cards were made. '
                'Add fresh cards from the latest Note — your old cards and '
                'revision progress will stay.',
            busy: _busy,
            onRegenerate: _busy ? null : _generate,
            regenerateLabel: 'Add fresh cards',
          ),
          const SizedBox(height: 16),
        ],
        // OverflowBar keeps the count and actions on one line when they fit,
        // and stacks them when the screen is too narrow, so the header never
        // overflows.
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          overflowSpacing: 8,
          children: [
            Text('${cards.length} cards',
                style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShareActions(
                  label: 'Flashcards',
                  fileBaseName: exportFileName(
                      ref.read(documentProvider(widget.documentId))?.title ??
                          'Note',
                      'Flashcards'),
                  buildText: () => ShareFormat.flashcards(
                    ref.read(documentProvider(widget.documentId))?.title ??
                        'Note',
                    cards,
                  ),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _generate,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Add fresh cards'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => context.push('/revision/${widget.documentId}'),
          icon: const Icon(Icons.school_rounded),
          label: const Text('Start revision'),
        ),
        const SizedBox(height: 16),
        for (final card in cards) ...[
          _FlashcardTile(card: card),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _FlashcardTile extends ConsumerStatefulWidget {
  const _FlashcardTile({required this.card});

  final Flashcard card;

  @override
  ConsumerState<_FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends ConsumerState<_FlashcardTile> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    return AppCard(
      onTap: () => setState(() => _showAnswer = !_showAnswer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(card.question, style: theme.textTheme.titleSmall),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                  label: _difficultyLabel(card.difficulty),
                  tone: BadgeTone.neutral),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _showAnswer
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Row(
              children: [
                Icon(Icons.touch_app_outlined,
                    size: 15, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('Tap to reveal answer', style: theme.textTheme.bodySmall),
              ],
            ),
            secondChild: Text(card.answer, style: theme.textTheme.bodyMedium),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Icon(
                card.isReviewed
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 18,
                color: card.isReviewed
                    ? AppColors.success
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text('Reviewed', style: theme.textTheme.bodySmall),
              const Spacer(),
              Switch(
                value: card.isReviewed,
                onChanged: (v) =>
                    ref.read(studyControllerProvider).setReviewed(card, v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _difficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
