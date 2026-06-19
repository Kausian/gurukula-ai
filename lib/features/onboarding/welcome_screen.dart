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

  /// Lays out two feature cards side by side. [IntrinsicHeight] makes both
  /// cards match the taller one's content height, so neither is clipped.
  Widget _featureRow(_Feature left, _Feature right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ColorfulFeatureCard(
              accent: left.accent,
              icon: left.icon,
              title: left.title,
              subtitle: left.subtitle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ColorfulFeatureCard(
              accent: right.accent,
              icon: right.icon,
              title: right.title,
              subtitle: right.subtitle,
            ),
          ),
        ],
      ),
    );
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/logo/gurukula_logo.png',
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                  Text('offline-first',
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
              // Two intrinsic-height rows instead of a fixed-aspect GridView so
              // each card grows to fit its content (and larger font scales)
              // without a RenderFlex overflow.
              _featureRow(_features[0], _features[1]),
              const SizedBox(height: 14),
              _featureRow(_features[2], _features[3]),
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
