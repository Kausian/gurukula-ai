import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';

/// Idea Lab — a student innovation coach.
///
/// Idea generation, improvement and project planning are added in Phase 6.
class IdeaLabScreen extends StatelessWidget {
  const IdeaLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Idea Lab')),
      body: const EmptyState(
        icon: Icons.lightbulb_outline,
        title: 'Your innovation coach',
        message:
            'Generate, improve and plan project ideas with on-device AI. '
            'This is added in a later phase.',
      ),
    );
  }
}
