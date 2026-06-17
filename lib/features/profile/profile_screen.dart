import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';

/// Profile — student card, study stats, AI status, settings and privacy.
///
/// Google Sign-In and the full profile are added in Phase 3.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const EmptyState(
        icon: Icons.person_outline,
        title: 'Sign in to get started',
        message:
            'Create your student profile to personalise Gurukula. '
            'This is added in a later phase.',
      ),
    );
  }
}
