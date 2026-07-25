import '../../data/providers.dart';

/// Applies the Library search query, type filter, source filter, note-attribute
/// filter and sort order (Phase 12A search/type/sort, Phase 12B source, v1.18.0
/// note filter).
///
/// Pure and UI-free so it can be unit-tested directly. [typeIndex] follows the
/// chip row: 0 = All, otherwise `LibraryCategory.values[typeIndex - 1]`. A null
/// [source] means "All sources"; a specific source excludes items that have no
/// source (e.g. ideas). [noteFilter] defaults to `all`; any other value narrows
/// the list to notes with that attribute (favorites / summary / flashcards /
/// quiz).
List<LibraryItem> filterAndSortLibrary(
  List<LibraryItem> items, {
  required String query,
  required int typeIndex,
  required LibrarySort sort,
  LibrarySource? source,
  LibraryNoteFilter noteFilter = LibraryNoteFilter.all,
}) {
  final q = query.trim().toLowerCase();

  final filtered = items.where((item) {
    final typeOk = typeIndex == 0 ||
        item.category == LibraryCategory.values[typeIndex - 1];
    final searchOk = q.isEmpty || item.searchText.contains(q);
    final sourceOk = source == null || item.source == source;
    final noteOk = _noteFilterOk(item, noteFilter);
    return typeOk && searchOk && sourceOk && noteOk;
  }).toList();

  filtered.sort((a, b) => sort == LibrarySort.newest
      ? b.createdAt.compareTo(a.createdAt)
      : a.createdAt.compareTo(b.createdAt));

  return filtered;
}

/// Whether [item] passes the note lens. `favorites` implies notes only, so
/// summaries/flashcards/ideas etc. are excluded.
bool _noteFilterOk(LibraryItem item, LibraryNoteFilter filter) {
  switch (filter) {
    case LibraryNoteFilter.all:
      return true;
    case LibraryNoteFilter.favorites:
      return item.category == LibraryCategory.notes && item.isFavorite;
  }
}
