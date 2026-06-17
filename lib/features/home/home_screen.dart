import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_header.dart';

/// Home dashboard.
///
/// In Phase 1 this is a styled shell: a greeting, quick-action cards, and an
/// empty recent-activity area. Real stats and content arrive in later phases.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_QuickAction> _quickActions = [
    _QuickAction(Icons.upload_file_outlined, 'Upload notes'),
    _QuickAction(Icons.content_paste_outlined, 'Paste text'),
    _QuickAction(Icons.lightbulb_outline, 'Generate idea'),
    _QuickAction(Icons.style_outlined, 'Review flashcards'),
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
      appBar: AppBar(title: const Text(AppStrings.brand)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppStrings.tagline,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.subtitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Quick actions'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              for (final action in _quickActions)
                AppCard(
                  onTap: () => _comingSoon(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.icon, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(action.label, style: theme.textTheme.titleSmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent activity'),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No activity yet. Your recent summaries, flashcards and '
                    'ideas will show up here.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.icon, this.label);
  final IconData icon;
  final String label;
}
