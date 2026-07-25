import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A gentle notice shown above generated study content (summary, flashcards,
/// quiz) when the note was edited after that content was generated.
///
/// It makes staleness obvious and offers a one-tap regenerate, so the student
/// is never misled into thinking their edits weren't saved (v1.16.0 fix).
class StaleNoticeBanner extends StatelessWidget {
  const StaleNoticeBanner({
    super.key,
    required this.message,
    required this.onRegenerate,
    this.busy = false,
    this.regenerateLabel = 'Regenerate',
  });

  final String message;
  final VoidCallback? onRegenerate;
  final bool busy;
  final String regenerateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppAccents.coral;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: accent.fill.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: accent.fill.withValues(alpha: 0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: 8),
          busy
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                )
              : TextButton(
                  onPressed: onRegenerate,
                  child: Text(regenerateLabel),
                ),
        ],
      ),
    );
  }
}
