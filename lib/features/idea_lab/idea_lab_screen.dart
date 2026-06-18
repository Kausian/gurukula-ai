import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/enums.dart';
import '../../data/models/idea.dart';
import 'idea_providers.dart';

/// Idea Lab: generate, improve and plan project ideas, all saved locally.
class IdeaLabScreen extends ConsumerWidget {
  const IdeaLabScreen({super.key});

  static const List<_Mode> _modes = [
    _Mode(AppAccents.lavender, Icons.auto_awesome_rounded, 'Generate new idea',
        _ModeKind.generate),
    _Mode(AppAccents.lime, Icons.tune_rounded, 'Improve my idea',
        _ModeKind.openLatest),
    _Mode(AppAccents.mint, Icons.checklist_rounded, 'Turn into a project plan',
        _ModeKind.openLatest),
    _Mode(AppAccents.coral, Icons.workspace_premium_rounded, 'Make it CV-worthy',
        _ModeKind.openLatest),
  ];

  void _onMode(BuildContext context, List<Idea> ideas, _ModeKind kind) {
    if (kind == _ModeKind.generate) {
      context.push('/idea-lab/new');
      return;
    }
    if (ideas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate an idea first')),
      );
      return;
    }
    // Open the most recent idea; its refine actions live on the detail screen.
    context.push('/idea/${ideas.first.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ideas = ref.watch(ideasListProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            const PageHeader(
              title: 'Idea Lab',
              subtitle: 'Your on-device innovation coach.',
            ),
            const SizedBox(height: 22),

            // Hero.
            AppCard(
              color: AppAccents.lavender.fill,
              showBorder: false,
              onTap: () => context.push('/idea-lab/new'),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconChip(
                    icon: Icons.rocket_launch_rounded,
                    iconColor: AppAccents.lavender.onFill,
                    background: Colors.white.withValues(alpha: 0.45),
                    size: 52,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Build your next project idea',
                    style: TextStyle(
                        fontSize: 21,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppAccents.lavender.onFill),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Go from a blank page to a plan you can put on your CV.',
                    style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color:
                            AppAccents.lavender.onFill.withValues(alpha: 0.72)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const SectionHeader(title: 'Choose a mode'),
            for (final mode in _modes) ...[
              _ModeCard(mode: mode, onTap: () => _onMode(context, ideas, mode.kind)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),

            const SectionHeader(title: 'Your ideas'),
            if (ideas.isEmpty)
              AppCard(
                child: Row(
                  children: [
                    IconChip(
                        icon: Icons.lightbulb_outline_rounded,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'No ideas yet. Generate your first project idea above.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final idea in ideas) ...[
                _IdeaTile(idea: idea, onTap: () => context.push('/idea/${idea.id}')),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, this.onTap});
  final _Mode mode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconChip(icon: mode.icon, color: mode.accent.fill, size: 48),
          const SizedBox(width: 16),
          Expanded(child: Text(mode.title, style: theme.textTheme.titleMedium)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _IdeaTile extends StatelessWidget {
  const _IdeaTile({required this.idea, this.onTap});
  final Idea idea;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconChip(icon: Icons.lightbulb_rounded, color: AppAccents.coral.fill),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(idea.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text('Updated ${timeAgo(idea.updatedAt)}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(label: _difficulty(idea.difficulty), tone: BadgeTone.neutral),
        ],
      ),
    );
  }

  String _difficulty(Difficulty d) {
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

enum _ModeKind { generate, openLatest }

class _Mode {
  const _Mode(this.accent, this.icon, this.title, this.kind);
  final GurukulaAccent accent;
  final IconData icon;
  final String title;
  final _ModeKind kind;
}
