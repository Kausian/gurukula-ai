/// Short, friendly relative time like "just now", "3h ago", "2d ago".
///
/// [dateUtc] is expected in UTC (all timestamps are stored that way).
String timeAgo(DateTime dateUtc) {
  final diff = DateTime.now().toUtc().difference(dateUtc);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
