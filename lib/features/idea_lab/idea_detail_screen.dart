import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/share_format.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/share_actions.dart';
import '../../data/models/idea.dart';
import '../../services/ai_service.dart';
import 'idea_providers.dart';
import 'widgets/idea_sections.dart';

/// Shows a saved idea and offers the refine actions: improve, turn into a
/// project plan, and make it CV-worthy. All edits update the idea in Hive.
class IdeaDetailScreen extends ConsumerStatefulWidget {
  const IdeaDetailScreen({super.key, required this.ideaId});

  final String ideaId;

  @override
  ConsumerState<IdeaDetailScreen> createState() => _IdeaDetailScreenState();
}

class _IdeaDetailScreenState extends ConsumerState<IdeaDetailScreen> {
  String? _busyAction;

  Future<void> _run(String action, Future<void> Function() task) async {
    setState(() => _busyAction = action);
    await task();
    if (mounted) {
      setState(() => _busyAction = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$action done')),
      );
    }
  }

  Future<void> _editNotes(Idea idea) async {
    final controller = TextEditingController(text: idea.notes);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notes'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Your notes or pitch'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      await ref.read(ideaControllerProvider).updateNotes(idea.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final idea = ref.watch(ideaByIdProvider(widget.ideaId));

    if (idea == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This idea could not be found.')),
      );
    }

    final aiIdea = AiIdea(
      title: idea.title,
      problem: idea.problem,
      targetUsers: idea.targetUsers,
      features: idea.features,
      techStack: idea.techStack,
      difficulty: idea.difficulty,
      mvpPlan: idea.mvpPlan,
      whyUnique: idea.whyUnique ?? '',
    );
    final controller = ref.read(ideaControllerProvider);
    final busy = _busyAction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(idea.title, overflow: TextOverflow.ellipsis),
        actions: [
          ShareActions(
            label: 'Idea',
            fileBaseName: '${idea.title} idea',
            buildText: () => ShareFormat.idea(idea),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(idea.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),

            // Refine actions.
            const SectionHeader(title: 'Refine'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ActionChip(
                  label: 'Improve',
                  icon: Icons.tune_rounded,
                  busy: _busyAction == 'Improve',
                  enabled: !busy,
                  onTap: () =>
                      _run('Improve', () => controller.improve(idea.id)),
                ),
                _ActionChip(
                  label: 'Project plan',
                  icon: Icons.checklist_rounded,
                  busy: _busyAction == 'Project plan',
                  enabled: !busy,
                  onTap: () => _run('Project plan',
                      () => controller.makeProjectPlan(idea.id)),
                ),
                _ActionChip(
                  label: 'Make CV-worthy',
                  icon: Icons.workspace_premium_rounded,
                  busy: _busyAction == 'Make CV-worthy',
                  enabled: !busy,
                  onTap: () => _run('Make CV-worthy',
                      () => controller.makeCvWorthy(idea.id)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            IdeaSections(idea: aiIdea),

            // Notes / CV pitch.
            const SectionHeader(title: 'Notes'),
            AppCard(
              onTap: () => _editNotes(idea),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      idea.notes.trim().isEmpty
                          ? 'Add notes or a CV pitch'
                          : idea.notes,
                      style: idea.notes.trim().isEmpty
                          ? theme.textTheme.bodyMedium
                          : theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.edit_outlined,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon, size: 18),
      label: Text(label),
      onPressed: enabled ? onTap : null,
    );
  }
}
