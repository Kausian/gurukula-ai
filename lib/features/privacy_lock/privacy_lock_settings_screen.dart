import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import 'privacy_lock_providers.dart';

/// Privacy Lock settings (v1.21.0): enable/disable the lock, set/change the
/// PIN, and toggle biometric unlock. Reached from Profile → Privacy Lock.
class PrivacyLockSettingsScreen extends ConsumerWidget {
  const PrivacyLockSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(privacyLockControllerProvider);
    final biometricAvailable =
        ref.watch(biometricAvailableProvider).value ?? false;
    final storageProtected = ref.watch(storageProtectionActiveProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Lock')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            AppCard(
              child: Row(
                children: [
                  Icon(Icons.shield_rounded, color: scheme.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Protect your study space',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Use biometric unlock or a PIN to open Gurukula AI. '
                          'Your study data stays on this device.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Storage protection'),
            AppCard(
              child: Row(
                children: [
                  Icon(
                    storageProtected
                        ? Icons.lock_rounded
                        : Icons.lock_open_rounded,
                    size: 24,
                    color: storageProtected
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('Encrypted Storage',
                                  style: theme.textTheme.titleSmall),
                            ),
                            StatusBadge(
                              label: storageProtected ? 'On' : 'Off',
                              tone: storageProtected
                                  ? BadgeTone.success
                                  : BadgeTone.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          storageProtected
                              ? 'Your saved study data is protected on this '
                                  'device.'
                              : 'Encrypted storage is not active on this '
                                  'device. Your study data is still stored '
                                  'locally only.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Privacy Lock protects app access. Encrypted Storage protects '
              'saved study data.',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Lock'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    value: state.enabled,
                    title: const Text('Privacy Lock'),
                    subtitle: Text(state.enabled
                        ? 'On — a PIN is required to open the app'
                        : 'Off'),
                    onChanged: (value) => value
                        ? _enable(context, ref, biometricAvailable)
                        : _disable(context, ref),
                  ),
                  if (state.enabled) ...[
                    const Divider(height: 1),
                    if (biometricAvailable)
                      SwitchListTile(
                        value: state.biometricEnabled,
                        title: const Text('Biometric unlock'),
                        subtitle:
                            const Text('Use fingerprint or face to unlock'),
                        onChanged: (value) => ref
                            .read(privacyLockControllerProvider.notifier)
                            .setBiometric(value),
                      ),
                    if (biometricAvailable) const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.pin_rounded),
                      title: const Text('Change PIN'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _changePin(context, ref),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Keep your PIN safe. If you forget it, you will need to '
                    'clear the app data to regain access.',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enable(
      BuildContext context, WidgetRef ref, bool biometricAvailable) async {
    final pin = await _promptNewPin(context);
    if (pin == null) return;
    var useBiometric = false;
    if (biometricAvailable && context.mounted) {
      useBiometric = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Biometric unlock'),
              content: const Text(
                  'Also allow fingerprint or face unlock? You can change this '
                  'later.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Not now')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Enable')),
              ],
            ),
          ) ??
          false;
    }
    await ref
        .read(privacyLockControllerProvider.notifier)
        .enable(pin: pin, biometric: useBiometric);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy Lock is on')),
      );
    }
  }

  Future<void> _disable(BuildContext context, WidgetRef ref) async {
    final pin = await _promptPin(context, title: 'Enter PIN to turn off');
    if (pin == null) return;
    final ok = await ref.read(privacyLockControllerProvider.notifier).disable(pin);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(ok ? 'Privacy Lock is off' : 'Wrong PIN. Lock stays on.')),
      );
    }
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    final current = await _promptPin(context, title: 'Enter current PIN');
    if (current == null) return;
    if (!context.mounted) return;
    final next = await _promptNewPin(context);
    if (next == null) return;
    final ok = await ref
        .read(privacyLockControllerProvider.notifier)
        .changePin(currentPin: current, newPin: next);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ok ? 'PIN changed' : 'Current PIN was incorrect')),
      );
    }
  }

  /// Prompts for a new PIN with confirmation. Returns the PIN, or null if
  /// cancelled.
  Future<String?> _promptNewPin(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const _SetPinDialog(),
    );
  }

  /// Prompts for a single PIN entry. Returns the PIN, or null if cancelled.
  Future<String?> _promptPin(BuildContext context, {required String title}) {
    return showDialog<String>(
      context: context,
      builder: (context) => _EnterPinDialog(title: title),
    );
  }
}

/// Dialog to set a PIN and confirm it. Pops the validated PIN.
class _SetPinDialog extends StatefulWidget {
  const _SetPinDialog();

  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pin.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'Use at least 4 digits');
      return;
    }
    if (pin != _confirm.text.trim()) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    Navigator.pop(context, pin);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Set a PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinField(controller: _pin, hint: 'New PIN (4–6 digits)', autofocus: true),
          const SizedBox(height: 12),
          _PinField(controller: _confirm, hint: 'Confirm PIN'),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

/// Dialog to enter a single PIN. Pops the entered PIN.
class _EnterPinDialog extends StatefulWidget {
  const _EnterPinDialog({required this.title});

  final String title;

  @override
  State<_EnterPinDialog> createState() => _EnterPinDialogState();
}

class _EnterPinDialogState extends State<_EnterPinDialog> {
  final _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: _PinField(controller: _pin, hint: 'PIN', autofocus: true),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(context, _pin.text.trim()),
            child: const Text('OK')),
      ],
    );
  }
}

class _PinField extends StatelessWidget {
  const _PinField({
    required this.controller,
    required this.hint,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(counterText: '', hintText: hint),
    );
  }
}
