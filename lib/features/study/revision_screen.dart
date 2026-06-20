import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/utils/revision_schedule.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/enums.dart';
import '../../data/models/flashcard.dart';
import '../../data/providers.dart';
import 'study_providers.dart';

/// Focused flashcard Revision Mode (Phase 11A).
///
/// Reveal an answer, then rate the card Easy/Medium/Hard. The rating is stored
/// on the card (via [StudyController.recordReview]) and the session advances.
/// The deck is snapshotted on entry so marking cards never reorders it.
class RevisionScreen extends ConsumerStatefulWidget {
  const RevisionScreen({super.key, required this.scope});

  /// A document id to revise that note's cards, or `all` for every card.
  final String scope;

  @override
  ConsumerState<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends ConsumerState<RevisionScreen> {
  late List<Flashcard> _deck;
  int _index = 0;
  bool _showAnswer = false;
  final Map<Difficulty, int> _tally = {
    Difficulty.easy: 0,
    Difficulty.medium: 0,
    Difficulty.hard: 0,
  };

  @override
  void initState() {
    super.initState();
    _deck = _loadDeck();
  }

  List<Flashcard> _loadDeck() {
    final repo = ref.read(flashcardRepositoryProvider);
    if (widget.scope == 'due') {
      return repo.dueCards(); // already ordered most-overdue first
    }
    final cards =
        widget.scope == 'all' ? repo.getAll() : repo.byDocument(widget.scope);
    cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  Future<void> _rate(Difficulty rating) async {
    final card = _deck[_index];
    await ref.read(studyControllerProvider).recordReview(card, rating);
    if (!mounted) return;
    final days = RevisionSchedule.intervalDays(rating);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text('Next review in $days ${days == 1 ? 'day' : 'days'}'),
      ));
    setState(() {
      _tally[rating] = (_tally[rating] ?? 0) + 1;
      _index++;
      _showAnswer = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _showAnswer = false;
      for (final key in _tally.keys.toList()) {
        _tally[key] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revision')),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_deck.isEmpty) {
      return widget.scope == 'due'
          ? const EmptyState(
              icon: Icons.task_alt_rounded,
              title: "You're all caught up",
              message: 'No flashcards are due for review right now.',
            )
          : const EmptyState(
              icon: Icons.style_outlined,
              title: 'Nothing to revise yet',
              message:
                  'Generate some flashcards first, then come back to revise.',
            );
    }
    if (_index >= _deck.length) {
      return _SummaryView(
        total: _deck.length,
        tally: _tally,
        onRestart: _restart,
        onDone: () => context.pop(),
      );
    }
    return _CardView(
      card: _deck[_index],
      index: _index,
      total: _deck.length,
      showAnswer: _showAnswer,
      onReveal: () => setState(() => _showAnswer = true),
      onRate: _rate,
    );
  }
}

/// One card: progress, question, reveal, then the rating buttons.
class _CardView extends StatelessWidget {
  const _CardView({
    required this.card,
    required this.index,
    required this.total,
    required this.showAnswer,
    required this.onReveal,
    required this.onRate,
  });

  final Flashcard card;
  final int index;
  final int total;
  final bool showAnswer;
  final VoidCallback onReveal;
  final ValueChanged<Difficulty> onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        LinearProgressIndicator(value: (index + 1) / total, minHeight: 4),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            children: [
              Text('Card ${index + 1} of $total',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 6),
                    Text(card.question, style: theme.textTheme.titleLarge),
                    if (showAnswer) ...[
                      const Divider(height: 28),
                      Text('Answer', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 6),
                      Text(card.answer, style: theme.textTheme.bodyLarge),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: showAnswer
              ? Row(
                  children: [
                    _RateButton(
                        label: 'Easy',
                        accent: AppAccents.mint,
                        onTap: () => onRate(Difficulty.easy)),
                    const SizedBox(width: 10),
                    _RateButton(
                        label: 'Medium',
                        accent: AppAccents.lime,
                        onTap: () => onRate(Difficulty.medium)),
                    const SizedBox(width: 10),
                    _RateButton(
                        label: 'Hard',
                        accent: AppAccents.coral,
                        onTap: () => onRate(Difficulty.hard)),
                  ],
                )
              : FilledButton.icon(
                  onPressed: onReveal,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Reveal answer'),
                ),
        ),
      ],
    );
  }
}

/// A colored, equal-width rating button. [Expanded] keeps the themed
/// full-width button from forcing an infinite width inside the Row.
class _RateButton extends StatelessWidget {
  const _RateButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final GurukulaAccent accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: accent.fill,
          foregroundColor: accent.onFill,
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

/// End-of-session recap with the Easy/Medium/Hard tally.
class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.total,
    required this.tally,
    required this.onRestart,
    required this.onDone,
  });

  final int total;
  final Map<Difficulty, int> tally;
  final VoidCallback onRestart;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        AppCard(
          color: theme.colorScheme.primary,
          showBorder: false,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.onPrimary, size: 40),
              const SizedBox(height: 10),
              Text('Reviewed $total ${total == 1 ? 'card' : 'cards'}',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _TallyRow(label: 'Easy', value: tally[Difficulty.easy] ?? 0, accent: AppAccents.mint),
        const SizedBox(height: 10),
        _TallyRow(label: 'Medium', value: tally[Difficulty.medium] ?? 0, accent: AppAccents.lime),
        const SizedBox(height: 10),
        _TallyRow(label: 'Hard', value: tally[Difficulty.hard] ?? 0, accent: AppAccents.coral),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRestart,
                child: const Text('Review again'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onDone,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TallyRow extends StatelessWidget {
  const _TallyRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final GurukulaAccent accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: accent.fill, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          Text('$value', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
