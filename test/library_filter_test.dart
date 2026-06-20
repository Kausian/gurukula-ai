// Pure unit tests for Library search, type filter and sort (Phase 12A).

import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/core/utils/library_filter.dart';
import 'package:gurukula_ai/data/providers.dart';

LibraryItem _item(
  String id,
  LibraryCategory category,
  DateTime createdAt, {
  String title = '',
  String search = '',
  LibrarySource? source,
}) =>
    LibraryItem(
      id: id,
      title: title.isEmpty ? id : title,
      category: category,
      createdAt: createdAt,
      source: source,
      searchText: search.toLowerCase(),
    );

void main() {
  final items = [
    _item('a', LibraryCategory.notes, DateTime.utc(2026, 1, 1),
        title: 'Biology notes', search: 'biology notes photosynthesis'),
    _item('b', LibraryCategory.flashcards, DateTime.utc(2026, 3, 1),
        title: 'What is H2O', search: 'what is h2o water chemistry'),
    _item('c', LibraryCategory.rewrites, DateTime.utc(2026, 2, 1),
        title: 'Formal rewrite', search: 'formal rewrite lecture.pdf'),
  ];

  test('empty query returns everything, newest first', () {
    final result = filterAndSortLibrary(items,
        query: '', typeIndex: 0, sort: LibrarySort.newest);
    expect(result.map((i) => i.id).toList(), ['b', 'c', 'a']);
  });

  test('oldest sort reverses order', () {
    final result = filterAndSortLibrary(items,
        query: '', typeIndex: 0, sort: LibrarySort.oldest);
    expect(result.map((i) => i.id).toList(), ['a', 'c', 'b']);
  });

  test('query matches content preview, case-insensitively', () {
    final result = filterAndSortLibrary(items,
        query: 'PHOTOSYNTHESIS', typeIndex: 0, sort: LibrarySort.newest);
    expect(result.map((i) => i.id).toList(), ['a']);
  });

  test('query matches a source file name in the search index', () {
    final result = filterAndSortLibrary(items,
        query: 'lecture.pdf', typeIndex: 0, sort: LibrarySort.newest);
    expect(result.single.id, 'c');
  });

  test('type filter narrows to one category', () {
    // typeIndex 6 -> LibraryCategory.values[5] == rewrites.
    final result = filterAndSortLibrary(items,
        query: '', typeIndex: 6, sort: LibrarySort.newest);
    expect(result.single.category, LibraryCategory.rewrites);
  });

  test('search and type filter combine', () {
    final result = filterAndSortLibrary(items,
        query: 'water', typeIndex: 3, sort: LibrarySort.newest);
    expect(result.single.id, 'b'); // flashcards type + matches 'water'
  });

  group('source filter (Phase 12B)', () {
    final sourced = [
      _item('pasted', LibraryCategory.notes, DateTime.utc(2026, 1, 1),
          source: LibrarySource.pasted),
      _item('txt', LibraryCategory.notes, DateTime.utc(2026, 1, 2),
          source: LibrarySource.txt),
      _item('pdf', LibraryCategory.notes, DateTime.utc(2026, 1, 3),
          source: LibrarySource.pdf),
      _item('idea', LibraryCategory.ideas, DateTime.utc(2026, 1, 4)), // no source
    ];

    test('null source returns everything, including unsourced items', () {
      final result = filterAndSortLibrary(sourced,
          query: '', typeIndex: 0, sort: LibrarySort.newest, source: null);
      expect(result.length, 4);
    });

    test('a specific source keeps only matching items and drops unsourced', () {
      final result = filterAndSortLibrary(sourced,
          query: '',
          typeIndex: 0,
          sort: LibrarySort.newest,
          source: LibrarySource.pdf);
      expect(result.map((i) => i.id).toList(), ['pdf']);
    });

    test('source composes with type and sort', () {
      final result = filterAndSortLibrary(sourced,
          query: '',
          typeIndex: 1, // Notes
          sort: LibrarySort.oldest,
          source: LibrarySource.txt);
      expect(result.single.id, 'txt');
    });
  });
}
