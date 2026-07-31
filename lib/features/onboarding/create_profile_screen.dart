import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/page_header.dart';
import '../../data/providers.dart';
import '../auth/account_controller.dart';
import '../auth/auth_providers.dart';

/// Complete-your-student-profile step (v1.26.0): shown after Google sign-in
/// when there is no local student profile yet. Asks only the small set of
/// student details Gurukula needs — no email/password (Google handles that).
class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _subject;
  late final TextEditingController _institution;
  late String _level;
  late String _goal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(profileRepositoryProvider).current;
    final user = ref.read(currentUserProvider);

    _name = TextEditingController(
        text: existing?.username ?? user?.displayName ?? '');
    _subject = TextEditingController(text: existing?.mainSubject ?? '');
    _institution = TextEditingController(text: existing?.institution ?? '');
    _level = kStudyLevels.contains(existing?.studyLevel)
        ? existing!.studyLevel
        : 'University';
    _goal = kStudyGoals.contains(existing?.learningGoal)
        ? existing!.learningGoal
        : 'Exams';
  }

  @override
  void dispose() {
    _name.dispose();
    _subject.dispose();
    _institution.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(accountControllerProvider).saveProfileForCurrentUser(
          StudentDetails(
            fullName: _name.text.trim(),
            studyLevel: _level,
            subject: _subject.text.trim(),
            studyGoal: _goal,
            institution: _institution.text.trim(),
          ),
        );
    // The router re-evaluates on the profile change; nudging to /splash lets it
    // route to onboarding (if not completed) or Home.
    if (mounted) context.go('/splash');
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
              title: 'Complete your profile',
              subtitle: 'A few student details — kept on your device.',
            ),
            const SizedBox(height: 20),
            if (user?.email != null)
              AppCard(
                color: theme.colorScheme.surfaceContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              label: 'Full name',
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Kausian'),
              ),
            ),
            _Field(
              label: 'Study level',
              child: DropdownButtonFormField<String>(
                initialValue: _level,
                items: [
                  for (final l in kStudyLevels)
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: (v) => setState(() => _level = v ?? _level),
              ),
            ),
            _Field(
              label: 'Course or subject area',
              child: TextField(
                controller: _subject,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(hintText: 'e.g. Computer Science'),
              ),
            ),
            _Field(
              label: 'Main study goal',
              child: DropdownButtonFormField<String>(
                initialValue: _goal,
                items: [
                  for (final g in kStudyGoals)
                    DropdownMenuItem(value: g, child: Text(g)),
                ],
                onChanged: (v) => setState(() => _goal = v ?? _goal),
              ),
            ),
            _Field(
              label: 'Institution (optional)',
              child: TextField(
                controller: _institution,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    hintText: 'e.g. Springfield University'),
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
