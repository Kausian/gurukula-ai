import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/share_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/share_actions.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/flashcard.dart';
import '../study_providers.dart';

/// Flashcards tab: generated study cards with flip + reviewed toggle.
class FlashcardsTab extends ConsumerStatefulWidget {
  const FlashcardsTab({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends ConsumerState<FlashcardsTab> {
  bool _busy = false;

  Future<void> _generate() async {
    setState(() => _busy = true);
    final count = await ref
        .read(studyControllerProvider)
        .generateFlashcards(widget.documentId);
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created $count flashcards')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(flashcardsForDocumentProvider(widget.documentId));

    if (cards.isEmpty) {
      return EmptyState(
        icon: Icons.style_outlined,
        title: 'No flashcards yet',
        message: 'Generate a set of study cards from this note.',
        action: FilledButton.icon(
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
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${cards.length} cards',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ShareActions(
              label: 'Flashcards',
              fileBaseName:
                  '${ref.read(documentProvider(widget.documentId))?.title ?? 'Note'} flashcards',
              buildText: () => ShareFormat.flashcards(
                ref.read(documentProvider(widget.documentId))?.title ?? 'Note',
                cards,
              ),
            ),
            TextButton.icon(
              onPressed: _busy ? null : _generate,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add more'),
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
