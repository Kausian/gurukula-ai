import 'package:flutter/material.dart';

import '../../core/widgets/empty_state.dart';

/// Upload entry point.
///
/// Paste-text and PDF upload flows are implemented in Phase 4 / Phase 7.
class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: const EmptyState(
        icon: Icons.upload_file_outlined,
        title: 'Add your notes',
        message:
            'Paste text or upload a PDF to create a study workspace. '
            'This is added in a later phase.',
      ),
    );
  }
}
