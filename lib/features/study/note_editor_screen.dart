import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'study_providers.dart';

/// Note editor (v1.16.0): view and edit a saved note's title and body.
///
/// This is the simple, stable foundation for a richer editor later — plain
/// text only. Saving writes back to the same [StudyDocument] via the existing
/// local (Hive) storage, so all AI generation keeps using the updated content.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  // The last-saved baseline, used to detect unsaved changes.
  String _savedTitle = '';
  String _savedBody = '';

  bool _loaded = false;
  bool _found = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Read the document once; edits are local until the user saves.
    final doc = ref.read(documentProvider(widget.documentId));
    if (doc == null) {
      _found = false;
    } else {
      _title.text = doc.title;
      _body.text = doc.cleanedText;
      _savedTitle = _title.text;
      _savedBody = _body.text;
    }
    _loaded = true;
    _title.addListener(_onChanged);
    _body.addListener(_onChanged);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Rebuild so the Save button reflects whether there are unsaved changes.
    setState(() {});
  }

  bool get _dirty =>
      _title.text != _savedTitle || _body.text != _savedBody;

  Future<void> _save() async {
    if (_body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A note needs some text before saving.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final ok = await ref.read(studyControllerProvider).updateDocumentContent(
            documentId: widget.documentId,
            title: _title.text,
            body: _body.text,
          );
      if (!mounted) return;
      if (!ok) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This note could not be found.')),
        );
        return;
      }
      setState(() {
        _savedTitle = _title.text;
        _savedBody = _body.text;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Changes saved')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your changes.')),
      );
    }
  }

  /// Asks before leaving with unsaved edits, so a stray back-swipe can't lose
  /// the student's work.
  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this note have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loaded && !_found) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit note')),
        body: const Center(child: Text('This note could not be found.')),
      );
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard() && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit note'),
          actions: [
            TextButton(
              onPressed: (_saving || !_dirty) ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.titleMedium,
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
                    decoration: const InputDecoration(
                      hintText: 'Edit your note here',
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
                        _dirty
                            ? 'Unsaved changes · stored only on your device.'
                            : 'All changes saved · stored only on your device.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: (_saving || !_dirty) ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Saving' : 'Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
