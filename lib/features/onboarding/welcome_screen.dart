import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/colorful_feature_card.dart';

/// First-time value screen: a bold, colorful student-app landing.
///
/// Real Google Sign-In arrives in Phase 3; the CTA opens the app shell for now.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const List<_Feature> _features = [
    _Feature(AppAccents.lavender, Icons.summarize_rounded, 'Summaries',
        'Clear notes in seconds'),
    _Feature(AppAccents.lime, Icons.style_rounded, 'Flashcards',
        'Study cards from any text'),
    _Feature(AppAccents.coral, Icons.lightbulb_rounded, 'Idea Lab',
        'Build project ideas'),
    _Feature(AppAccents.mint, Icons.lock_rounded, 'Private notes',
        'Everything stays on device'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand wordmark.
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.school_rounded,
                        color: theme.colorScheme.onPrimary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(AppStrings.brand, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Text('offline',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 36),

              // Hero.
              Text(AppStrings.heroHeadline, style: theme.textTheme.displayLarge),
              const SizedBox(height: 14),
              Text(
                AppStrings.welcomeSubtitle,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),

              // Colorful feature grid.
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.08,
                children: [
                  for (final f in _features)
                    ColorfulFeatureCard(
                      accent: f.accent,
                      icon: f.icon,
                      title: f.title,
                      subtitle: f.subtitle,
                    ),
                ],
              ),
              const SizedBox(height: 28),

              // CTA.
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('${AppStrings.privacyNote}.',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature(this.accent, this.icon, this.title, this.subtitle);
  final GurukulaAccent accent;
  final IconData icon;
  final String title;
  final String subtitle;
}
