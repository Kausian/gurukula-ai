import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/section_header.dart';
import '../../data/models/study_goal.dart';
import '../../data/providers.dart';
import 'study_planner_providers.dart';

/// Create or edit a study goal (v1.20.0). When [goalId] is null this creates a
/// new goal; otherwise it edits (and can delete) an existing one.
class StudyGoalFormScreen extends ConsumerStatefulWidget {
  const StudyGoalFormScreen({super.key, this.goalId});

  final String? goalId;

  bool get isEditing => goalId != null;

  @override
  ConsumerState<StudyGoalFormScreen> createState() =>
      _StudyGoalFormScreenState();
}

class _StudyGoalFormScreenState extends ConsumerState<StudyGoalFormScreen> {
  final _title = TextEditingController();
  final _subject = TextEditingController();
  final _description = TextEditingController();

  late DateTime _targetDate;
  StudyGoalStatus _status = StudyGoalStatus.notStarted;
  String? _documentId;
  bool _loaded = false;
  bool _found = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _targetDate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 7));

    final id = widget.goalId;
    if (id != null) {
      final goal = ref.read(studyGoalByIdProvider(id));
      if (goal == null) {
        _found = false;
      } else {
        _title.text = goal.title;
        _subject.text = goal.subject;
        _description.text = goal.description;
        _targetDate = goal.targetDate;
        _status = goal.status;
        _documentId = goal.documentId;
      }
    }
    _loaded = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Exam or target date',
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your goal a title first')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final controller = ref.read(studyPlannerControllerProvider);
      if (widget.isEditing) {
        await controller.update(
          widget.goalId!,
          title: _title.text,
          subject: _subject.text,
          targetDate: _targetDate,
          description: _description.text,
          status: _status,
          documentId: _documentId,
          clearDocumentId: _documentId == null,
        );
      } else {
        await controller.create(
          title: _title.text,
          subject: _subject.text,
          targetDate: _targetDate,
          description: _description.text,
          status: _status,
          documentId: _documentId,
        );
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the goal.')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this goal?'),
        content: const Text('This removes the study goal from your planner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(studyPlannerControllerProvider).delete(widget.goalId!);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loaded && !_found) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study goal')),
        body: const Center(child: Text('This goal could not be found.')),
      );
    }

    // Notes available to optionally link.
    ref.watch(dataChangesProvider);
    final notes = ref.watch(documentRepositoryProvider).getAll()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    // Guard against a stale link whose note was deleted.
    final linkValue =
        notes.any((n) => n.id == _documentId) ? _documentId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit goal' : 'New goal'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete goal',
              onPressed: _busy ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Final exam',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _subject,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Subject / module',
                hintText: 'e.g. Operating Systems',
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Target date'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(_dateLabel(_targetDate),
                        style: theme.textTheme.bodyLarge),
                    const Spacer(),
                    Text('Change',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Progress'),
            SegmentedButton<StudyGoalStatus>(
              segments: const [
                ButtonSegment(
                    value: StudyGoalStatus.notStarted, label: Text('Not started')),
                ButtonSegment(
                    value: StudyGoalStatus.inProgress, label: Text('In progress')),
                ButtonSegment(
                    value: StudyGoalStatus.ready, label: Text('Ready')),
              ],
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Description (optional)'),
            TextField(
              controller: _description,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What do you need to cover or revise?',
              ),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionHeader(title: 'Linked note (optional)'),
              DropdownButtonFormField<String?>(
                initialValue: linkValue,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No linked note'),
                  ),
                  for (final n in notes)
                    DropdownMenuItem<String?>(
                      value: n.id,
                      child: Text(n.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _documentId = value),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _save,
              icon: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(widget.isEditing ? 'Save changes' : 'Create goal'),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December' //
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
