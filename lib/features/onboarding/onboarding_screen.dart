import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'onboarding_providers.dart';

/// First-run onboarding (v1.25.0): a short, skippable, swipeable intro to what
/// Gurukula AI does and its privacy-first, offline-focused design.
///
/// Shown once (gated by [onboardingCompletedProvider]); also reachable again
/// from Profile. Wording is deliberately honest: "offline-focused",
/// "on-device where supported", "fallback-safe".
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const List<_Page> _pages = [
    _Page(
      accent: AppAccents.lavender,
      icon: Icons.auto_stories_rounded,
      title: 'Your private study space',
      body: 'Turn notes into summaries, flashcards, quizzes, and revision '
          'tools.',
    ),
    _Page(
      accent: AppAccents.mint,
      icon: Icons.file_upload_outlined,
      title: 'Import your notes',
      body: 'Paste text, import TXT/PDF files, or scan printed notes using '
          'your camera or gallery.',
    ),
    _Page(
      accent: AppAccents.lime,
      icon: Icons.auto_awesome_rounded,
      title: 'Study smarter',
      body: 'Generate summaries, flashcards, quizzes, study packs, and exam '
          'goals from your notes.',
    ),
    _Page(
      accent: AppAccents.coral,
      icon: Icons.lock_rounded,
      title: 'Privacy-first by design',
      body: 'Your study data stays on your device. Privacy Lock protects app '
          'access, and Encrypted Storage protects saved study data.',
    ),
    _Page(
      accent: AppAccents.sky,
      icon: Icons.memory_rounded,
      title: 'On-device where supported',
      body: 'Gurukula AI uses on-device AI where supported, and fallback '
          'generation when it is not available.',
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (!mounted) return;
    // When opened again from Profile we can pop back; on first run we can't, so
    // hand control back to the router (which routes to sign-in or Home).
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/splash');
    }
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(_isLast ? 'Close' : 'Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardingPage(page: _pages[i]),
              ),
            ),
            // Page indicator dots.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? scheme.primary
                          : scheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: page.accent.fill.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 36),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Page {
  const _Page({
    required this.accent,
    required this.icon,
    required this.title,
    required this.body,
  });

  final GurukulaAccent accent;
  final IconData icon;
  final String title;
  final String body;
}
