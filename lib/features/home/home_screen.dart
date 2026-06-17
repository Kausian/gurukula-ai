import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/challenge_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/learning_tool_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';

/// Home dashboard: a colorful, interactive study space.
///
/// Phase 1.5 shell: hero workspace card, explore-tools row, progress stats,
/// a daily challenge and a recent-activity empty state. Real data lands in
/// Phase 2.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_Tool> _tools = [
    _Tool(AppAccents.lavender, Icons.upload_file_rounded, 'Upload notes'),
    _Tool(AppAccents.lime, Icons.content_paste_rounded, 'Paste text'),
    _Tool(AppAccents.coral, Icons.lightbulb_rounded, 'Generate idea'),
    _Tool(AppAccents.mint, Icons.style_rounded, 'Review flashcards'),
  ];

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in a later phase')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Extra bottom padding so the last card clears the bottom nav bar.
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: [
            PageHeader(
              title: 'Your study space',
              subtitle: 'Offline-first study, all on your device.',
              trailing: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(Icons.person_rounded,
                    color: scheme.onSurfaceVariant, size: 24),
              ),
            ),
            const SizedBox(height: 22),

            _WorkspaceHero(),
            const SizedBox(height: 28),

            // Explore tools (horizontal).
            const SectionHeader(title: 'Explore tools'),
            SizedBox(
              height: 142,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tools.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final tool = _tools[index];
                  return LearningToolCard(
                    accent: tool.accent,
                    icon: tool.icon,
                    label: tool.label,
                    onTap: () => _comingSoon(context),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // Progress.
            const SectionHeader(title: 'Your progress'),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                      icon: Icons.summarize_rounded,
                      value: '0',
                      label: 'Notes',
                      color: AppAccents.lavender.fill),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                      icon: Icons.style_rounded,
                      value: '0',
                      label: 'Flashcards',
                      color: AppAccents.mint.fill),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                      icon: Icons.lightbulb_rounded,
                      value: '0',
                      label: 'Ideas',
                      color: AppAccents.coral.fill),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Daily challenge.
            ChallengeCard(
              accent: AppAccents.coral,
              eyebrow: "Today's boost",
              title: 'Create 5 flashcards from your next note.',
              actionLabel: 'Start',
              onTap: () => _comingSoon(context),
            ),
            const SizedBox(height: 28),

            // Recent activity.
            const SectionHeader(title: 'Recent activity'),
            AppCard(
              child: Row(
                children: [
                  IconChip(
                      icon: Icons.history_rounded,
                      color: scheme.onSurfaceVariant),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No activity yet',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 3),
                        Text(
                          'Your summaries, flashcards and ideas will appear '
                          'here as you study.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filled hero card showing the offline workspace and its privacy state.
class _WorkspaceHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = scheme.onPrimary;

    return AppCard(
      color: scheme.primary,
      showBorder: false,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Protection ring.
          SizedBox(
            width: 66,
            height: 66,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 5,
                  color: onHero,
                  backgroundColor: onHero.withValues(alpha: 0.25),
                ),
                Icon(Icons.shield_rounded, color: onHero, size: 26),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Offline study workspace',
                    style: theme.textTheme.titleMedium?.copyWith(color: onHero)),
                const SizedBox(height: 4),
                Text(
                  'Everything you create stays private on this device.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: onHero.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(label: 'Local-first', onHero: onHero),
                    _HeroPill(label: 'On-device ready', onHero: onHero),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.onHero});

  final String label;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w700, color: onHero),
      ),
    );
  }
}

class _Tool {
  const _Tool(this.accent, this.icon, this.label);
  final GurukulaAccent accent;
  final IconData icon;
  final String label;
}
