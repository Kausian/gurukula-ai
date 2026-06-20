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
