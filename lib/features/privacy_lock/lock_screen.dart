import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'privacy_lock_providers.dart';

/// Full-screen unlock UI shown by [LockGate] when Privacy Lock is active
/// (v1.21.0). Offers biometric unlock (if enabled) with a PIN fallback that is
/// always available, so the user can never be locked out.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pin = TextEditingController();
  String? _error;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    // Auto-offer biometrics when the user opted in.
    final state = ref.read(privacyLockControllerProvider);
    if (state.biometricEnabled) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _authenticateBiometric());
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _authenticateBiometric() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final ok = await runBiometricUnlock(ref.read(localAuthProvider));
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (ok) {
      ref.read(privacyLockControllerProvider.notifier).unlockWithBiometric();
    }
  }

  void _submitPin() {
    final ok = ref
        .read(privacyLockControllerProvider.notifier)
        .unlockWithPin(_pin.text.trim());
    if (!ok) {
      setState(() {
        _error = 'Wrong PIN. Please try again.';
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final biometricEnabled =
        ref.watch(privacyLockControllerProvider).biometricEnabled;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_rounded, size: 42, color: scheme.primary),
                ),
                const SizedBox(height: 24),
                Text('Privacy Lock',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Protect your study space',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextField(
                  controller: _pin,
                  autofocus: !biometricEnabled,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.headlineSmall,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter PIN',
                    errorText: _error,
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _submitPin(),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submitPin,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Unlock'),
                ),
                if (biometricEnabled) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _authenticating ? null : _authenticateBiometric,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(_authenticating
                        ? 'Waiting…'
                        : 'Use biometric unlock'),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('Your study data stays on this device.',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
