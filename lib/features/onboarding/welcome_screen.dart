import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/colorful_feature_card.dart';
import '../auth/auth_providers.dart';

/// First-time value screen: a bold, colorful student-app landing.
///
/// The CTA triggers real Google Sign-In; the auth gate then routes the student
/// to profile creation (new account) or straight to Home.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _busy = false;

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

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // On success the auth gate redirects automatically.
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
              Text(AppStrings.heroHeadline, style: theme.textTheme.displayLarge),
              const SizedBox(height: 14),
              Text(
                AppStrings.welcomeSubtitle,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
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
              FilledButton.icon(
                onPressed: _busy ? null : _signIn,
                icon: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.g_mobiledata_rounded, size: 30),
                label: Text(_busy ? 'Signing in' : 'Continue with Google'),
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
