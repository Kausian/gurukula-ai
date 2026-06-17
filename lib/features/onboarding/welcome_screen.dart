import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

/// First-time value screen.
///
/// Explains what Gurukula does and offers the primary call to action.
/// Real Google Sign-In is added in Phase 3; for now the button lets the
/// user explore the app shell.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const List<_Feature> _features = [
    _Feature(Icons.summarize_outlined, 'Summarize lecture notes'),
    _Feature(Icons.style_outlined, 'Generate flashcards'),
    _Feature(Icons.edit_outlined, 'Rewrite and proofread text'),
    _Feature(Icons.lightbulb_outline, 'Build project ideas'),
    _Feature(Icons.lock_outline, 'Keep your study data on your device'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 34,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.brand,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tagline,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              for (final feature in _features) ...[
                Row(
                  children: [
                    Icon(feature.icon,
                        color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(feature.label,
                          style: theme.textTheme.bodyLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Sign-in is added in a later phase — continue to explore.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
}
