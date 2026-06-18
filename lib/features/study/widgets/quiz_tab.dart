import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/icon_chip.dart';
import '../../../core/widgets/status_badge.dart';
import '../quiz_providers.dart';

/// Quiz tab: generate a quiz from the note, then take it.
class QuizTab extends ConsumerStatefulWidget {
  const QuizTab({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends ConsumerState<QuizTab> {
  bool _busy = false;

  Future<void> _generate() async {
    setState(() => _busy = true);
    final id = await ref
        .read(quizControllerProvider)
        .generateForDocument(widget.documentId);
    if (mounted) {
      setState(() => _busy = false);
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add more text to generate a quiz')),
        );
      }
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
        action: FilledButton.icon(
          onPressed: _busy ? null : _generate,
          icon: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5))
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(_busy ? 'Generating' : 'Generate quiz'),
        ),
      );
    }

    final best = ref.watch(bestResultForQuizProvider(quiz.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
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
        Row(
          children: [
            const StatusBadge(
                label: 'Saved on device',
                icon: Icons.lock_rounded,
                tone: BadgeTone.success),
            const Spacer(),
            TextButton.icon(
              onPressed: _busy ? null : _generate,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('New quiz'),
            ),
          ],
        ),
      ],
    );
  }
}
