import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/section_header.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../services/ai_service.dart';
import 'idea_providers.dart';
import 'widgets/idea_sections.dart';

/// "Generate new idea": collects a brief, generates a draft via the AI service,
/// previews it, and saves it to Hive on confirmation.
class IdeaFormScreen extends ConsumerStatefulWidget {
  const IdeaFormScreen({super.key});

  @override
  ConsumerState<IdeaFormScreen> createState() => _IdeaFormScreenState();
}

class _IdeaFormScreenState extends ConsumerState<IdeaFormScreen> {
  static const _levels = {
    Difficulty.easy: 'Beginner',
    Difficulty.medium: 'Intermediate',
    Difficulty.hard: 'Advanced',
  };
  static const _times = ['A weekend', '1-2 weeks', '1 month', 'A semester'];

  late final TextEditingController _subject;
  final _problemArea = TextEditingController();
  final _techStack = TextEditingController();
  Difficulty _level = Difficulty.medium;
  String _time = '1-2 weeks';
  bool _zeroCost = true;

  bool _busy = false;
  AiIdea? _preview;

  @override
  void initState() {
    super.initState();
    final subject = ref.read(currentProfileProvider)?.mainSubject ?? '';
    _subject = TextEditingController(text: subject);
  }

  @override
  void dispose() {
    _subject.dispose();
    _problemArea.dispose();
    _techStack.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_subject.text.trim().isEmpty || _problemArea.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a subject and a problem area')),
      );
      return;
    }
    setState(() => _busy = true);
    final idea = await ref.read(ideaControllerProvider).generate(
          IdeaBrief(
            subject: _subject.text.trim(),
            skillLevel: _level,
            problemArea: _problemArea.text.trim(),
            techStack: _techStack.text.trim(),
            timeLimit: _time,
            zeroCost: _zeroCost,
          ),
        );
    if (mounted) {
      setState(() {
        _busy = false;
        _preview = idea;
      });
    }
  }

  Future<void> _save() async {
    final preview = _preview;
    if (preview == null) return;
    setState(() => _busy = true);
    final id = await ref.read(ideaControllerProvider).save(preview);
    if (mounted) context.pushReplacement('/idea/$id');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate an idea')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _field(
              'Subject / field',
              TextField(
                controller: _subject,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(hintText: 'e.g. Computer Science'),
              ),
            ),
            _field(
              'Problem area',
              TextField(
                controller: _problemArea,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'e.g. student productivity'),
              ),
            ),
            _field(
              'Skill level',
              DropdownButtonFormField<Difficulty>(
                initialValue: _level,
                items: [
                  for (final entry in _levels.entries)
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                ],
                onChanged: (v) => setState(() => _level = v ?? _level),
              ),
            ),
            _field(
              'Preferred tech stack (optional)',
              TextField(
                controller: _techStack,
                decoration:
                    const InputDecoration(hintText: 'e.g. Flutter, Dart'),
              ),
            ),
            _field(
              'Time limit',
              DropdownButtonFormField<String>(
                initialValue: _time,
                items: [
                  for (final t in _times)
                    DropdownMenuItem(value: t, child: Text(t)),
                ],
                onChanged: (v) => setState(() => _time = v ?? _time),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Zero-cost required', style: theme.textTheme.titleSmall),
              subtitle: Text('Only free, on-device tools',
                  style: theme.textTheme.bodySmall),
              value: _zeroCost,
              onChanged: (v) => setState(() => _zeroCost = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _generate,
              icon: _busy && preview == null
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(preview == null ? 'Generate idea' : 'Regenerate'),
            ),
            if (preview != null) ...[
              const SizedBox(height: 28),
              const SectionHeader(title: 'Preview'),
              Text(preview.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16),
              IdeaSections(idea: preview),
              const SizedBox(height: 4),
              FilledButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.bookmark_added_rounded),
                label: const Text('Save idea'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
