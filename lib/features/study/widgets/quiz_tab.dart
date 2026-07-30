import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/export_filename.dart';
import '../../../core/utils/share_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_chip.dart';
import '../../../core/widgets/share_actions.dart';
import '../../../core/widgets/stale_notice_banner.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../services/ai_service.dart';
import '../quiz_providers.dart';
import '../study_providers.dart';
import 'generation_options.dart';

/// Quiz tab: generate a quiz from the note, then take it.
class QuizTab extends ConsumerStatefulWidget {
  const QuizTab({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends ConsumerState<QuizTab> {
  bool _busy = false;
  QuizDifficulty _difficulty = QuizDifficulty.medium;

  Widget _difficultyChips() => OptionChips<QuizDifficulty>(
        label: 'Quiz difficulty',
        options: QuizDifficulty.values,
        selected: _difficulty,
        enabled: !_busy,
        labelOf: (d) => switch (d) {
          QuizDifficulty.easy => 'Easy',
          QuizDifficulty.medium => 'Medium',
          QuizDifficulty.hard => 'Hard',
        },
        onSelected: (d) => setState(() => _difficulty = d),
      );

  /// First-time generation (empty state): just make a quiz.
  Future<void> _generate() async {
    setState(() => _busy = true);
    final id = await ref
        .read(quizControllerProvider)
        .generateForDocument(widget.documentId, difficulty: _difficulty);
    if (mounted) {
      setState(() => _busy = false);
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add more text to generate a quiz')),
        );
      }
    }
  }

  /// Regenerate: replace the current quiz with a fresh one from the latest
  /// Note. Confirms first only if the current quiz has already been attempted,
  /// since its best score won't carry over to the new quiz.
  Future<void> _regenerate() async {
    final quiz = ref.read(quizForDocumentProvider(widget.documentId));
    final hasAttempt =
        quiz != null && ref.read(bestResultForQuizProvider(quiz.id)) != null;

    if (hasAttempt) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Regenerate quiz?'),
          content: const Text(
            'This makes a new quiz from the latest Note and replaces your '
            'current one. Your best score on the old quiz won\'t carry over.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep current'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Regenerate'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _busy = true);
    final id = await ref
        .read(quizControllerProvider)
        .regenerateForDocument(widget.documentId, difficulty: _difficulty);
    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(id == null
              ? 'Add more text to generate a quiz'
              : 'Quiz regenerated from the latest Note'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = ref.watch(quizForDocumentProvider(widget.documentId));

    if (quiz == null) {
      return EmptyState(
        icon: Icons.quiz_outlined,
        title: 'No quiz yet',
        message: 'Generate a quiz to test yourself on this note.',
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _difficultyChips(),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _generate,
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_busy ? 'Generating' : 'Generate quiz'),
            ),
          ],
        ),
      );
    }

    final best = ref.watch(bestResultForQuizProvider(quiz.id));
    final document = ref.watch(documentProvider(widget.documentId));
    final stale =
        document != null && document.updatedAt.isAfter(quiz.createdAt);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _difficultyChips(),
        const SizedBox(height: 16),
        if (stale) ...[
          StaleNoticeBanner(
            message: 'You edited this note after this quiz was made. '
                'Regenerate using the latest Note.',
            busy: _busy,
            onRegenerate: _busy ? null : _regenerate,
            regenerateLabel: 'Regenerate quiz',
          ),
          const SizedBox(height: 16),
        ],
        AppCard(
          color: theme.colorScheme.primary,
          showBorder: false,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconChip(
                    icon: Icons.quiz_rounded,
                    iconColor: theme.colorScheme.onPrimary,
                    background: Colors.white.withValues(alpha: 0.25),
                    size: 46,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quiz ready',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: theme.colorScheme.onPrimary)),
                        const SizedBox(height: 2),
                        Text('${quiz.questions.length} questions',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                  if (best != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary
                            .withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('Best ${best.score}/${best.total}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimary)),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimary,
                  foregroundColor: theme.colorScheme.primary,
                ),
                onPressed: () => context.push('/quiz/${quiz.id}'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start quiz'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // OverflowBar keeps the badge and the regenerate action on one line
        // when they fit, and stacks them when the screen is too narrow.
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          overflowSpacing: 8,
          children: [
            const StatusBadge(
                label: 'Saved on device',
                icon: Icons.lock_rounded,
                tone: BadgeTone.success),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShareActions(
                  label: 'Quiz',
                  fileBaseName: exportFileName(
                      ref.read(documentProvider(widget.documentId))?.title ??
                          'Note',
                      'Quiz'),
                  buildText: () => ShareFormat.quiz(
                    ref.read(documentProvider(widget.documentId))?.title ??
                        'Note',
                    quiz,
                  ),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _regenerate,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Regenerate quiz'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
