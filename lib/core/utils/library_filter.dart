import '../../data/providers.dart';

/// Applies the Library search query, type filter and sort order (Phase 12A).
///
/// Pure and UI-free so it can be unit-tested directly. [typeIndex] follows the
/// chip row: 0 = All, otherwise `LibraryCategory.values[typeIndex - 1]`.
List<LibraryItem> filterAndSortLibrary(
  List<LibraryItem> items, {
  required String query,
  required int typeIndex,
  required LibrarySort sort,
}) {
  final q = query.trim().toLowerCase();

  final filtered = items.where((item) {
    final typeOk = typeIndex == 0 ||
        item.category == LibraryCategory.values[typeIndex - 1];
    final searchOk = q.isEmpty || item.searchText.contains(q);
    return typeOk && searchOk;
  }).toList();

  filtered.sort((a, b) => sort == LibrarySort.newest
      ? b.createdAt.compareTo(a.createdAt)
      : a.createdAt.compareTo(b.createdAt));

  return filtered;
}
