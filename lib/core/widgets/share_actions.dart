import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// A compact Copy + Share control for exporting study content as plain text
/// (Phase 10A). Works inline in a tab header or inside an [AppBar.actions].
///
/// [buildText] is called lazily so the latest content is captured at the moment
/// the student taps, and the heavy string is only built when needed.
class ShareActions extends StatelessWidget {
  const ShareActions({
    super.key,
    required this.buildText,
    required this.label,
  });

  /// Produces the plain text to copy/share. Returns an empty string when there
  /// is nothing to export, in which case the action is a no-op.
  final String Function() buildText;

  /// Short noun for the SnackBar and share subject, e.g. 'Summary'.
  final String label;

  Future<void> _copy(BuildContext context) async {
    final text = buildText();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label copied')),
      );
    }
  }

  Future<void> _share() async {
    final text = buildText();
    if (text.isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text, subject: label));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.copy_rounded),
          tooltip: 'Copy $label',
          onPressed: () => _copy(context),
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          tooltip: 'Share $label',
          onPressed: _share,
        ),
      ],
    );
  }
}
