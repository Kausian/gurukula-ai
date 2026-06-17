import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';

/// Idea Lab: a creative, colorful student project coach.
///
/// Idea generation runs through the AI service in Phase 6; the mode cards are
/// interactive placeholders for now.
class IdeaLabScreen extends StatelessWidget {
  const IdeaLabScreen({super.key});

  static const List<_Mode> _modes = [
    _Mode(AppAccents.lavender, Icons.auto_awesome_rounded, 'Generate new idea',
        'A CV-worthy idea from your subject and level.'),
    _Mode(AppAccents.lime, Icons.tune_rounded, 'Improve my idea',
        'Sharpen an idea you already have.'),
    _Mode(AppAccents.mint, Icons.checklist_rounded, 'Turn into a project plan',
        'Break it into an MVP and milestones.'),
    _Mode(AppAccents.coral, Icons.workspace_premium_rounded, 'Make it CV-worthy',
        'Frame it to stand out to recruiters.'),
  ];

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in a later phase')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            _IdeaHero(onTap: () => _comingSoon(context)),
            const SizedBox(height: 28),

            const SectionHeader(title: 'Choose a mode'),
            for (final mode in _modes) ...[
              _ModeCard(mode: mode, onTap: () => _comingSoon(context)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Text(
              'Ideas you generate are saved here and in your Library, right on '
              'your device.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaHero extends StatelessWidget {
  const _IdeaHero({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppAccents.lavender;
    final ink = accent.onFill;
    return AppCard(
      color: accent.fill,
      showBorder: false,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconChip(
            icon: Icons.rocket_launch_rounded,
            iconColor: ink,
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
                color: ink),
          ),
          const SizedBox(height: 6),
          Text(
            'Go from a blank page to a plan you can put on your CV.',
            style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: ink.withValues(alpha: 0.72)),
          ),
        ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(mode.description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _Mode {
  const _Mode(this.accent, this.icon, this.title, this.description);
  final GurukulaAccent accent;
  final IconData icon;
  final String title;
  final String description;
}
