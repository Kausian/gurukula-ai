import 'package:flutter/material.dart';
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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, overflow: TextOverflow.ellipsis),
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
