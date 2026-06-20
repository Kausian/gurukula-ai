import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/txt_export_service.dart';

/// A compact Copy + Share (+ optional Export .txt) control for study content
/// (Phase 10A; export added in Phase 13). Works inline in a tab header or
/// inside an [AppBar.actions].
///
/// [buildText] is called lazily so the latest content is captured at the moment
/// the student taps, and the heavy string is only built when needed.
class ShareActions extends StatelessWidget {
  const ShareActions({
    super.key,
    required this.buildText,
    required this.label,
    this.fileBaseName,
  });

  /// Produces the plain text to copy/share. Returns an empty string when there
  /// is nothing to export, in which case the action is a no-op.
  final String Function() buildText;

  /// Short noun for the SnackBar and share subject, e.g. 'Summary'.
  final String label;

  /// When set, an "Export .txt" action appears that saves the text as a file
  /// using this base name (Phase 13). When null, no export button is shown.
  final String? fileBaseName;

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

  Future<void> _export(BuildContext context) async {
    final text = buildText();
    final base = fileBaseName;
    if (text.isEmpty || base == null) return;
    try {
      final ok = await const TxtExportService()
          .exportAsTxt(text: text, fileBaseName: base);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label exported as .txt')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not export file')),
        );
      }
    }
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
        if (fileBaseName != null)
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export $label as .txt',
            onPressed: () => _export(context),
          ),
      ],
    );
  }
}
