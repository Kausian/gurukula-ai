import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import 'account_controller.dart';
import 'google_button.dart';

/// Auth landing (v1.26.0): the first screen for signed-out users. Clean,
/// centered Gurukula branding with three equally sized actions — Log in, Sign
/// up, and Continue with Google — plus the privacy promise.
class AuthLandingScreen extends ConsumerStatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  ConsumerState<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends ConsumerState<AuthLandingScreen> {
  bool _busy = false;

  Future<void> _google() async {
    setState(() => _busy = true);
    try {
      await ref.read(accountControllerProvider).signInWithGoogle();
      // The auth gate redirects on success.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              // Brand block.
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo/gurukula_logo.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Your private study companion',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const Spacer(flex: 4),
              // Auth button group — all three the same width, height and radius.
              FilledButton(
                onPressed: _busy ? null : () => context.push('/login'),
                child: const Text('Log in'),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                style: authOutlinedButtonStyle(context),
                onPressed: _busy ? null : () => context.push('/signup'),
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 14),
              GoogleButton(busy: _busy, onPressed: _google),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 14, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Your study data stays on this device.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
