import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/utils/study_goal_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/icon_chip.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/study_goal.dart';
import 'study_planner_providers.dart';

/// Study Planner (v1.20.0): a simple local list of study goals / exams, ordered
/// by target date, with days remaining and a readiness status.
class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(studyGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
      floatingActionButton: goals.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/planner/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New goal'),
            ),
      body: SafeArea(
        child: goals.isEmpty
            ? _empty(context)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                itemCount: goals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _GoalCard(
                  goal: goals[index],
                  onTap: () => context.push('/planner/${goals[index].id}/edit'),
                ),
              ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    // EmptyState is already scroll-safe and vertically centered, so it is
    // returned directly — wrapping it in another scroll view left a large
    // blank gap.
    return EmptyState(
      icon: Icons.event_note_rounded,
      title: 'Plan your first goal',
      message: 'Add an exam or study goal to track how many days you '
          'have left and how ready you feel.',
      action: FilledButton.icon(
        onPressed: () => context.push('/planner/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New goal'),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, this.onTap});

  final StudyGoal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final overdue = StudyGoalTime.isOverdue(goal.targetDate);
    final days = StudyGoalTime.daysUntil(goal.targetDate);
    final soon = !overdue && days <= 3;
    final countdownColor = overdue
        ? AppAccents.coral.fill
        : soon
            ? scheme.primary
            : scheme.onSurfaceVariant;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconChip(
                  icon: Icons.event_note_rounded,
                  color: AppAccents.sky.fill,
                  size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (goal.subject.isNotEmpty) ...[
                      Text(goal.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 2),
                    ],
                    Text(goal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(_dateLabel(goal.targetDate),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StudyGoalTime.remainingLabel(goal.targetDate),
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: countdownColor, fontWeight: FontWeight.w700),
                  ),
                  if (overdue)
                    Text('past',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: AppAccents.coral.fill)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatusChip(status: goal.status),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' //
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StudyGoalStatus status;

  @override
  Widget build(BuildContext context) {
    final (tone, icon) = switch (status) {
      StudyGoalStatus.notStarted => (BadgeTone.neutral, Icons.circle_outlined),
      StudyGoalStatus.inProgress => (BadgeTone.info, Icons.timelapse_rounded),
      StudyGoalStatus.ready => (BadgeTone.success, Icons.check_circle_rounded),
    };
    return StatusBadge(
      label: studyGoalStatusLabel(status),
      tone: tone,
      icon: icon,
    );
  }
}
