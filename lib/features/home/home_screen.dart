import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/challenge_card.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/learning_tool_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../data/models/activity_event.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';

/// Home dashboard: a colorful, interactive study space backed by local data.
class HomeScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final activity = ref.watch(recentActivityProvider);
    final profile = ref.watch(currentProfileProvider);

    final greeting =
        profile == null ? 'Your study space' : 'Hi, ${profile.username}';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: [
            PageHeader(
              title: greeting,
              subtitle: 'Offline-first study, all on your device.',
              trailing: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Icon(Icons.person_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24),
              ),
            ),
            const SizedBox(height: 22),

            const _WorkspaceHero(),
            const SizedBox(height: 28),

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
                    onTap: () {
                      if (tool.label == 'Upload notes' ||
                          tool.label == 'Paste text') {
                        context.push('/paste');
                      } else {
                        _comingSoon(context);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            const SectionHeader(title: 'Your progress'),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                      icon: Icons.summarize_rounded,
                      value: '${stats.notes}',
                      label: 'Notes',
                      color: AppAccents.lavender.fill),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                      icon: Icons.style_rounded,
                      value: '${stats.flashcards}',
                      label: 'Flashcards',
                      color: AppAccents.mint.fill),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                      icon: Icons.lightbulb_rounded,
                      value: '${stats.ideas}',
                      label: 'Ideas',
                      color: AppAccents.coral.fill),
                ),
              ],
            ),
            const SizedBox(height: 28),

            ChallengeCard(
              accent: AppAccents.coral,
              eyebrow: "Today's boost",
              title: 'Create 5 flashcards from your next note.',
              actionLabel: 'Start',
              onTap: () => _comingSoon(context),
            ),
            const SizedBox(height: 28),

            const SectionHeader(title: 'Recent activity'),
            _RecentActivity(activity: activity),
          ],
        ),
      ),
    );
  }
}

/// Either a list of recent events, or a friendly empty card.
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.activity});

  final List<ActivityEvent> activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activity.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            IconChip(
                icon: Icons.history_rounded,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No activity yet', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 3),
                  Text(
                    'Your summaries, flashcards and ideas will appear here as '
                    'you study.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < activity.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _ActivityRow(event: activity[i]),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event});

  final ActivityEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleFor(event.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          IconChip(icon: style.icon, color: style.color, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(style.label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(timeAgo(event.createdAt), style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }

  _ActivityStyle _styleFor(ActivityType type) {
    switch (type) {
      case ActivityType.documentUploaded:
        return _ActivityStyle(
            Icons.upload_file_rounded, AppAccents.lavender.fill, 'Note added');
      case ActivityType.summaryCreated:
        return _ActivityStyle(
            Icons.summarize_rounded, AppAccents.mint.fill, 'Summary created');
      case ActivityType.flashcardCreated:
        return _ActivityStyle(
            Icons.style_rounded, AppAccents.lime.fill, 'Flashcards created');
      case ActivityType.ideaSaved:
        return _ActivityStyle(
            Icons.lightbulb_rounded, AppAccents.coral.fill, 'Idea saved');
      case ActivityType.rewriteCreated:
        return _ActivityStyle(
            Icons.edit_rounded, AppAccents.sky.fill, 'Text rewritten');
    }
  }
}

class _ActivityStyle {
  const _ActivityStyle(this.icon, this.color, this.label);
  final IconData icon;
  final Color color;
  final String label;
}

/// Filled hero card showing the offline workspace and its privacy state.
class _WorkspaceHero extends StatelessWidget {
  const _WorkspaceHero();

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
