import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'study_providers.dart';
import 'widgets/flashcards_tab.dart';
import 'widgets/quiz_tab.dart';
import 'widgets/summary_tab.dart';
import 'widgets/tools_tab.dart';

/// The Study Workspace: one screen per document, with Summary, Tools and
/// Flashcards tabs. This is the heart of the study flow.
class StudyWorkspaceScreen extends ConsumerWidget {
  const StudyWorkspaceScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final document = ref.watch(documentProvider(documentId));

    if (document == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This note could not be found.')),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(document.title, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'Copy summary',
              onPressed: () async {
                final summary =
                    ref.read(summaryForDocumentProvider(documentId));
                if (summary == null) return;
                await Clipboard.setData(
                    ClipboardData(text: summary.shortSummary));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Summary copied')),
                  );
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Tools'),
              Tab(text: 'Flashcards'),
              Tab(text: 'Quiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SummaryTab(documentId: documentId),
            ToolsTab(documentId: documentId),
            FlashcardsTab(documentId: documentId),
            QuizTab(documentId: documentId),
          ],
        ),
      ),
    );
  }
}
