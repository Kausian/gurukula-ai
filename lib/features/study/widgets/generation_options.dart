import 'package:flutter/material.dart';

/// A compact labelled row of single-select choice chips for generation options
/// (v1.24.0): summary length, flashcard style, quiz difficulty.
///
/// Kept generic and tiny so all three study tabs share one consistent control.
class OptionChips<T> extends StatelessWidget {
  const OptionChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final List<T> options;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(labelOf(option)),
                selected: option == selected,
                onSelected:
                    enabled ? (_) => onSelected(option) : null,
              ),
          ],
        ),
      ],
    );
  }
}
