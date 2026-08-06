// Library empty-state tests (v1.31.1).
//
// Guards the fix that restored meaningful Library empty states. These override
// `libraryItemsProvider` (and the filter StateProviders) directly, so they run
// fast and never touch Hive, Firebase or async generation — they only assert
// which empty state the screen renders for each reason the list is empty.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/data/providers.dart';
import 'package:gurukula_ai/features/library/library_screen.dart';

/// A single fake note item, enough to make the library "non-empty".
LibraryItem _note() => LibraryItem(
      id: 'n1',
      title: 'Photosynthesis notes',
      category: LibraryCategory.notes,
      createdAt: DateTime(2026, 1, 1),
      documentId: 'n1',
      source: LibrarySource.pasted,
      searchText: 'photosynthesis notes plants light energy',
    );

Future<void> _pumpLibrary(
  WidgetTester tester, {
  required List<LibraryItem> items,
  String search = '',
  int typeIndex = 0,
  LibraryNoteFilter noteFilter = LibraryNoteFilter.all,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryItemsProvider.overrideWithValue(items),
        librarySearchProvider.overrideWith((ref) => search),
        libraryFilterProvider.overrideWith((ref) => typeIndex),
        libraryNoteFilterProvider.overrideWith((ref) => noteFilter),
      ],
      child: const MaterialApp(home: LibraryScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('empty library → "Your library is empty" with both actions',
      (tester) async {
    await _pumpLibrary(tester, items: const []);

    expect(find.text('Your library is empty'), findsOneWidget);
    expect(find.text('Add a note'), findsOneWidget);
    expect(find.text('Import notes'), findsOneWidget);
  });

  testWidgets('search with no matches → "No results found" with Clear search',
      (tester) async {
    await _pumpLibrary(tester, items: [_note()], search: 'zzznomatch');

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
    expect(find.text('Your library is empty'), findsNothing);
  });

  testWidgets('a filter with no matches → "Nothing matches these filters"',
      (tester) async {
    // One note item, but the Quizzes type chip (index 5) is selected.
    await _pumpLibrary(tester, items: [_note()], typeIndex: 5);

    expect(find.text('Nothing matches these filters'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('Favorites lens with no favorites → "No favorites yet"',
      (tester) async {
    // A non-favorite note plus the Favorites lens yields no matches.
    await _pumpLibrary(
      tester,
      items: [_note()],
      noteFilter: LibraryNoteFilter.favorites,
    );

    expect(find.text('No favorites yet'), findsOneWidget);
  });
}
