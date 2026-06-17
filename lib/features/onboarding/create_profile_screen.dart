import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/models/user_profile.dart';
import '../../data/providers.dart';
import '../auth/auth_providers.dart';

/// Collects (or confirms) the student's profile after Google sign-in.
///
/// Prefilled from any existing local profile (including the Phase 2 sample),
/// then saved back to Hive with the Google identity attached.
class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  static const _levels = ['High school', 'College', 'University', 'Self-learner'];
  static const _languages = ['English', 'Tamil', 'Hindi', 'Sinhala', 'Other'];

  late final TextEditingController _username;
  late final TextEditingController _subject;
  late final TextEditingController _goal;
  late String _level;
  late String _language;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(profileRepositoryProvider).current;
    final user = ref.read(currentUserProvider);

    _username = TextEditingController(
        text: existing?.username ?? user?.displayName ?? '');
    _subject = TextEditingController(text: existing?.mainSubject ?? '');
    _goal = TextEditingController(text: existing?.learningGoal ?? '');
    _level = _levels.contains(existing?.studyLevel)
        ? existing!.studyLevel
        : 'University';
    _language = _languages.contains(existing?.preferredLanguage)
        ? existing!.preferredLanguage
        : 'English';
  }

  @override
  void dispose() {
    _username.dispose();
    _subject.dispose();
    _goal.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_username.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    final existing = repo.current;
    final now = DateTime.now().toUtc();

    final profile = UserProfile(
      id: existing?.id ?? const Uuid().v4(),
      googleUid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      username: _username.text.trim(),
      studyLevel: _level,
      mainSubject: _subject.text.trim(),
      learningGoal: _goal.text.trim(),
      preferredLanguage: _language,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await repo.save(profile);
    ref.invalidate(currentProfileProvider);

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const PageHeader(
              title: 'Create your profile',
              subtitle: 'This stays on your device and personalises Gurukula.',
            ),
            const SizedBox(height: 20),
            if (user?.email != null)
              AppCard(
                color: theme.colorScheme.surfaceContainer,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Signed in as ${user!.email}',
                          style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _Field(
              label: 'Username',
              child: TextField(
                controller: _username,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Kausian'),
              ),
            ),
            _Field(
              label: 'Study level',
              child: DropdownButtonFormField<String>(
                initialValue: _level,
                items: [
                  for (final l in _levels)
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _level = v ?? _level),
              ),
            ),
            _Field(
              label: 'Main subject / field',
              child: TextField(
                controller: _subject,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(hintText: 'e.g. Computer Science'),
              ),
            ),
            _Field(
              label: 'Learning goal',
              child: TextField(
                controller: _goal,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'e.g. Prepare for exams and build projects'),
              ),
            ),
            _Field(
              label: 'Preferred language',
              child: DropdownButtonFormField<String>(
                initialValue: _language,
                items: [
                  for (final l in _languages)
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _language = v ?? _language),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Save and continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A labelled form field block.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
