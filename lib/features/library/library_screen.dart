import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';

/// Library — all locally saved study content.
///
/// Notes, summaries, flashcards, rewrites and ideas appear here from Phase 2.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: const EmptyState(
        icon: Icons.folder_outlined,
        title: 'Nothing saved yet',
        message:
            'Your notes, summaries, flashcards and ideas will live here — '
            'all stored privately on your device.',
      ),
    );
  }
}
