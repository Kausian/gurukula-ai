import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_card.dart';
import 'account_controller.dart';

/// Delete Account flow (v1.27.0): a serious, explicit confirmation screen.
///
/// The student must type DELETE (and, for email accounts, re-enter their
/// password). Deletion removes the Firebase account first, then wipes all local
/// data and signs out — the auth gate then returns to the Auth Landing screen.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirm = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  static const _deletedItems = [
    'Your account and sign-in',
    'Your student profile',
    'All notes, summaries, flashcards and quizzes',
    'Quiz results, rewrites and ideas',
    'Study goals and activity history',
    'Privacy Lock settings',
  ];

  @override
  void dispose() {
    _confirm.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _passwordAccount =>
      ref.read(accountControllerProvider).isPasswordAccount;

  bool get _canDelete {
    final typed = _confirm.text.trim().toUpperCase() == 'DELETE';
    final pwOk = !_passwordAccount || _password.text.isNotEmpty;
    return typed && pwOk && !_busy;
  }

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountControllerProvider).deleteAccount(
            password: _passwordAccount ? _password.text : null,
          );
      // On success the auth gate routes to the Auth Landing screen.
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = authErrorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            AppCard(
              color: scheme.errorContainer.withValues(alpha: 0.4),
              showBorder: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: scheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This permanently deletes your account and everything '
                      'stored on this device. This cannot be undone.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('What gets deleted', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            for (final item in _deletedItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.close_rounded, size: 18, color: scheme.error),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(item, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Files you already exported or shared outside the app are not '
              'affected.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (_passwordAccount) ...[
              Text('Confirm your password', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _password,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Password',
                  isDense: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    iconSize: 20,
                    icon: Icon(_obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                'You may be asked to sign in with Google again to confirm.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
            ],
            Text('Type DELETE to confirm', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _confirm,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'DELETE',
                isDense: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: _canDelete ? _delete : null,
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.delete_forever_rounded),
              label: Text(_busy ? 'Deleting…' : 'Delete my account'),
            ),
          ],
        ),
      ),
    );
  }
}
