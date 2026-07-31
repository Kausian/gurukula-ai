import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A "Continue with Google" outlined button used across the auth screens
/// (v1.26.0). Full-width and 56dp tall to match the primary/secondary auth
/// buttons, with a simple bold "G" glyph rather than a bundled Google logo.
class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.onPressed,
    this.busy = false,
    this.label = 'Continue with Google',
  });

  final VoidCallback onPressed;
  final bool busy;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: busy ? null : onPressed,
      style: authOutlinedButtonStyle(context),
      icon: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : Text(
              'G',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
      label: Text(busy ? 'Please wait…' : label),
    );
  }
}

/// Shared style for the secondary (outlined) auth buttons — Sign up and
/// Continue with Google — so they match the primary Log in button's width,
/// height and radius exactly.
ButtonStyle authOutlinedButtonStyle(BuildContext context) {
  final theme = Theme.of(context);
  return OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(56),
    foregroundColor: theme.colorScheme.onSurface,
    side: BorderSide(color: theme.colorScheme.outline),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
    ),
    textStyle: theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16,
    ),
  );
}
