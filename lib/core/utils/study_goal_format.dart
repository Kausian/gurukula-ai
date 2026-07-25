/// Helpers for showing how much time is left until a study goal's target date
/// (v1.20.0). Calendar-day based, so "days remaining" ignores the time of day.
class StudyGoalTime {
  StudyGoalTime._();

  /// Whole calendar days from today until [target] (local time). Negative when
  /// the date has already passed, 0 when it is today.
  static int daysUntil(DateTime target, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final t = DateTime(target.year, target.month, target.day);
    return t.difference(today).inDays;
  }

  /// A short, student-friendly label for the days remaining.
  static String remainingLabel(DateTime target, {DateTime? now}) {
    final days = daysUntil(target, now: now);
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';
    if (days > 1) return 'in $days days';
    return '${-days} days ago';
  }

  /// Whether the target date is in the past (before today).
  static bool isOverdue(DateTime target, {DateTime? now}) =>
      daysUntil(target, now: now) < 0;
}
