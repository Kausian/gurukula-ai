import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../study_providers.dart';

/// Summary tab: short summary, detailed summary and key points.
class SummaryTab extends ConsumerWidget {
  const SummaryTab({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(summaryForDocumentProvider(documentId));

    if (summary == null) {
      return const EmptyState(
        icon: Icons.summarize_outlined,
        title: 'No summary yet',
        message: 'This note does not have a summary.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const SectionHeader(title: 'Short summary'),
        AppCard(
          child: Text(summary.shortSummary, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Detailed summary'),
        AppCard(
          child: Text(summary.detailedSummary, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Key points'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < summary.keyPoints.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(summary.keyPoints[i],
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurface)),
                    ),
                  ],
                ),
              ],
              if (summary.keyPoints.isEmpty)
                Text('No key points.', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
