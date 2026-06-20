import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/share_format.dart';
import '../../core/widgets/share_actions.dart';
import '../../data/providers.dart';

/// Shows a saved rewrite (Phase 12B) as a read-only modal bottom sheet with
/// Copy/Share. Rewrites have no dedicated screen, so this is the safe way to
/// open one from the Library without touching the data model or routing.
Future<void> showRewritePreview(
  BuildContext context,
  WidgetRef ref,
  String rewriteId,
  String title,
) {
  final rewrite = ref.read(rewriteRepositoryProvider).getById(rewriteId);
  if (rewrite == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rewrite not found')),
    );
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _RewriteSheet(title: title, text: rewrite.rewrittenText),
  );
}

class _RewriteSheet extends StatelessWidget {
  const _RewriteSheet({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                  ShareActions(
                    label: 'Rewrite',
                    buildText: () => ShareFormat.rewrite(title, text),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(text, style: theme.textTheme.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
