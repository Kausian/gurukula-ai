import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/enums.dart';
import 'study_providers.dart';

/// Arguments passed (via go_router `extra`) to the import preview screen.
class ImportPreviewArgs {
  const ImportPreviewArgs({
    required this.text,
    required this.fileName,
    required this.type,
  });

  /// Text extracted from the file, on-device.
  final String text;

  /// Original file name, e.g. `lecture-1.txt`. Stored on the document.
  final String fileName;

  /// How the file entered the app (`text` for .txt, `pdf` for .pdf).
  final DocumentType type;
}

/// Lets the student review and edit text extracted from an imported file
/// before it becomes a Study Workspace. Nothing is saved until they confirm.
class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({super.key, required this.args});

  final ImportPreviewArgs args;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: _defaultTitle(widget.args.fileName));
    _body = TextEditingController(text: widget.args.text);
  }

  /// File name without its extension, used as a friendly default title.
  String _defaultTitle(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    return base.trim();
  }

  int get _wordCount {
    final words = _body.text.trim().split(RegExp(r'\s+'));
    return _body.text.trim().isEmpty ? 0 : words.length;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no text to save')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final id =
          await ref.read(studyControllerProvider).createDocumentFromImport(
                title: _title.text,
                text: _body.text,
                type: widget.args.type,
                sourceFileName: widget.args.fileName,
              );
      if (mounted) context.pushReplacement('/workspace/$id');
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the workspace.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Review imported text')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_rounded,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.args.fileName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_wordCount words',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Title (optional)',
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TextField(
                  controller: _body,
                  expands: true,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Edit the extracted text before saving',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 15, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.args.type == DocumentType.image
                          ? 'Text recognized on your device. Works best with '
                              'clear printed English text — Sinhala and Tamil '
                              'are not supported yet. First-time setup may need '
                              'Google Play Services once.'
                          : 'Imported and processed on your device. Nothing is '
                              'uploaded.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _create,
                icon: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_busy ? 'Creating' : 'Create study workspace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
