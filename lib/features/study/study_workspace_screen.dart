import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'study_providers.dart';
import 'widgets/flashcards_tab.dart';
import 'widgets/note_tab.dart';
import 'widgets/quiz_tab.dart';
import 'widgets/summary_tab.dart';
import 'widgets/tools_tab.dart';

/// The Study Workspace: one screen per document, with Note, Summary, Tools,
/// Flashcards and Quiz tabs. This is the heart of the study flow. The Note tab
/// (v1.17.0) leads, so opening a note shows its latest saved content first.
class StudyWorkspaceScreen extends ConsumerWidget {
  const StudyWorkspaceScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch only the title (not the whole document) so generating flashcards,
    // quizzes or rewrites doesn't rebuild this tab scaffold — that rebuild,
    // landing mid-swipe, was what triggered the TabBarView assertion. Each tab
    // watches its own data. A null title means the document is gone.
    final title =
        ref.watch(documentProvider(documentId).select((doc) => doc?.title));

    if (title == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This note could not be found.')),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit note',
              onPressed: () => context.push('/note/$documentId/edit'),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Note'),
              Tab(text: 'Summary'),
              Tab(text: 'Tools'),
              Tab(text: 'Flashcards'),
              Tab(text: 'Quiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NoteTab(documentId: documentId),
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
