import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/enums.dart';
import '../../../services/ai_service.dart';

/// Renders the structured fields of an [AiIdea]: problem, target users,
/// features, tech stack, difficulty, MVP plan and why it is unique.
class IdeaSections extends StatelessWidget {
  const IdeaSections({super.key, required this.idea});

  final AiIdea idea;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _block(
          context,
          'Real-world problem',
          Text(idea.problem, style: theme.textTheme.bodyLarge),
        ),
        _chips(context, 'Target users', idea.targetUsers),
        _bullets(context, 'Main features', idea.features),
        _chips(context, 'Tech stack', idea.techStack),
        const SectionHeader(title: 'Difficulty'),
        StatusBadge(label: _difficulty(idea.difficulty), tone: BadgeTone.info),
        const SizedBox(height: 24),
        _block(
          context,
          'MVP plan',
          Text(idea.mvpPlan, style: theme.textTheme.bodyLarge),
        ),
        if (idea.whyUnique.trim().isNotEmpty)
          _block(
            context,
            'Why it is unique',
            Text(idea.whyUnique, style: theme.textTheme.bodyLarge),
          ),
      ],
    );
  }

  Widget _block(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        AppCard(child: child),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _chips(BuildContext context, String title, List<String> values) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Text(value, style: theme.textTheme.labelLarge),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _bullets(BuildContext context, String title, List<String> values) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < values.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(values[i],
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface))),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
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
