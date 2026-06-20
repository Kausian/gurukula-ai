import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/share_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/share_actions.dart';
import '../../../data/models/enums.dart';
import '../study_providers.dart';

/// Tools tab: proofread and rewrite the note's text in different tones.
class ToolsTab extends ConsumerStatefulWidget {
  const ToolsTab({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends ConsumerState<ToolsTab> {
  late final TextEditingController _input;
  bool _busy = false;
  String? _result;
  String? _resultLabel;

  static const _tools = <(String, RewriteTone, IconData)>[
    ('Proofread', RewriteTone.proofread, Icons.spellcheck_rounded),
    ('Simpler', RewriteTone.simple, Icons.lightbulb_outline_rounded),
    ('Formal', RewriteTone.formal, Icons.account_balance_outlined),
    ('Shorter', RewriteTone.short, Icons.short_text_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final document = ref.read(documentProvider(widget.documentId));
    _input = TextEditingController(text: document?.cleanedText ?? '');
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _run(RewriteTone tone, String label) async {
    if (_input.text.trim().isEmpty) return;
    setState(() => _busy = true);
    final rewrite = await ref
        .read(studyControllerProvider)
        .createRewrite(widget.documentId, _input.text.trim(), tone);
    if (mounted) {
      setState(() {
        _busy = false;
        _result = rewrite.rewrittenText;
        _resultLabel = label;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const SectionHeader(title: 'Text'),
        AppCard(
          child: TextField(
            controller: _input,
            maxLines: 6,
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              isCollapsed: true,
              hintText: 'Text to proofread or rewrite',
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Tools'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (label, tone, icon) in _tools)
              ActionChip(
                avatar: Icon(icon, size: 18),
                label: Text(label),
                onPressed: _busy ? null : () => _run(tone, label),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (_busy)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
        else if (_result != null) ...[
          SectionHeader(
            title: 'Result',
            trailing: ShareActions(
              label: 'Rewrite',
              fileBaseName: '${_resultLabel ?? 'Rewrite'} rewrite',
              buildText: () =>
                  ShareFormat.rewrite(_resultLabel ?? 'Result', _result ?? ''),
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_result!, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 15, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('${_resultLabel ?? 'Result'} saved to your Library',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
