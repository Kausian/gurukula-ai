import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'account_controller.dart';

/// Sign up screen (v1.26.0): a compact, student-focused create-account form.
/// Asks only what a study assistant needs — no phone, DOB, gender or address.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _subject = TextEditingController();
  final _institution = TextEditingController();

  String _level = 'University';
  String _goal = 'Exams';
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _subject.dispose();
    _institution.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Please enter your full name.';
    if (_email.text.trim().isEmpty) return 'Please enter your email.';
    if (_password.text.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_password.text != _confirm.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> _signUp() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(accountControllerProvider).signUpWithEmail(
            email: _email.text.trim(),
            password: _password.text,
            details: StudentDetails(
              fullName: _name.text.trim(),
              studyLevel: _level,
              subject: _subject.text.trim(),
              studyGoal: _goal,
              institution: _institution.text.trim(),
            ),
          );
      // Profile is saved; the auth gate routes to onboarding/home.
    } catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          children: [
            Text('Set up your study space',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Just a few student details — all stored on your device.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 22),

            _SectionLabel('Account'),
            _CompactField(
              controller: _name,
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              capitalization: TextCapitalization.words,
            ),
            _CompactField(
              controller: _email,
              label: 'Email',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            _CompactField(
              controller: _password,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              suffix: IconButton(
                iconSize: 20,
                icon: Icon(_obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            _CompactField(
              controller: _confirm,
              label: 'Confirm password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
            ),

            const SizedBox(height: 14),
            _SectionLabel('Student details'),
            _CompactDropdown(
              label: 'Study level',
              value: _level,
              items: kStudyLevels,
              onChanged: (v) => setState(() => _level = v),
            ),
            _CompactField(
              controller: _subject,
              label: 'Course or subject area',
              hint: 'e.g. Computer Science',
              capitalization: TextCapitalization.words,
            ),
            _CompactDropdown(
              label: 'Main study goal',
              value: _goal,
              items: kStudyGoals,
              onChanged: (v) => setState(() => _goal = v),
            ),
            _CompactField(
              controller: _institution,
              label: 'Institution (optional)',
              hint: 'e.g. Springfield University',
              capitalization: TextCapitalization.words,
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _signUp,
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Create account'),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                    style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed:
                      _busy ? null : () => context.pushReplacement('/login'),
                  child: const Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A small muted section label above a group of fields.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// A compact filled text field with a consistent height for the auth forms.
class _CompactField extends StatelessWidget {
  const _CompactField({
    required this.controller,
    required this.label,
    this.icon,
    this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        decoration: authFieldDecoration(context, label: label, icon: icon,
            hint: hint, suffix: suffix),
      ),
    );
  }
}

/// A compact filled dropdown matching [_CompactField].
class _CompactDropdown extends StatelessWidget {
  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: authFieldDecoration(context, label: label),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (v) => onChanged(v ?? value),
      ),
    );
  }
}

/// Compact filled input decoration shared by the auth forms (v1.26.0). Overrides
/// the taller global content padding so the auth fields feel modern, not bulky.
InputDecoration authFieldDecoration(
  BuildContext context, {
  required String label,
  IconData? icon,
  String? hint,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    isDense: true,
    prefixIcon: icon == null ? null : Icon(icon, size: 20),
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
