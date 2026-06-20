import '../../data/providers.dart';

/// Applies the Library search query, type filter, source filter and sort order
/// (Phase 12A search/type/sort, Phase 12B source).
///
/// Pure and UI-free so it can be unit-tested directly. [typeIndex] follows the
/// chip row: 0 = All, otherwise `LibraryCategory.values[typeIndex - 1]`. A null
/// [source] means "All sources"; a specific source excludes items that have no
/// source (e.g. ideas).
List<LibraryItem> filterAndSortLibrary(
  List<LibraryItem> items, {
  required String query,
  required int typeIndex,
  required LibrarySort sort,
  LibrarySource? source,
}) {
  final q = query.trim().toLowerCase();

  final filtered = items.where((item) {
    final typeOk = typeIndex == 0 ||
        item.category == LibraryCategory.values[typeIndex - 1];
    final searchOk = q.isEmpty || item.searchText.contains(q);
    final sourceOk = source == null || item.source == source;
    return typeOk && searchOk && sourceOk;
  }).toList();

  filtered.sort((a, b) => sort == LibrarySort.newest
      ? b.createdAt.compareTo(a.createdAt)
      : a.createdAt.compareTo(b.createdAt));

  return filtered;
}
