/// Turns an arbitrary label into a safe file-name stem (no extension) for
/// `.txt` export (Phase 13).
///
/// Strips characters that are illegal in file names, collapses whitespace,
/// bounds the length, and falls back to a default when nothing usable is left.
String sanitizeFileName(
  String input, {
  String fallback = 'gurukula-export',
  int maxLength = 60,
}) {
  // Replace illegal/file-system characters and control chars with a space.
  var name = input.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), ' ');
  // Collapse runs of whitespace, and trim leading dots/spaces.
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  name = name.replaceAll(RegExp(r'^\.+'), '').trim();
  if (name.length > maxLength) name = name.substring(0, maxLength).trim();
  return name.isEmpty ? fallback : name;
}

/// Builds a readable, dated export file-name stem (no extension) from a
/// content [title], a content [type] label and an optional [date] (v1.23.0).
///
/// Example: `exportFileName('Biology: Cells', 'Summary')` →
/// `"Biology Cells Summary 2026-07-26"` (illegal characters removed).
String exportFileName(String title, String type, {DateTime? date}) {
  final d = (date ?? DateTime.now()).toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  final stamp = '${d.year}-${two(d.month)}-${two(d.day)}';
  final base = title.trim().isEmpty ? 'Gurukula' : title.trim();
  return sanitizeFileName('$base $type $stamp');
}
