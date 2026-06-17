/// Names of the Hive boxes used across the app.
///
/// Keeping these in one place avoids typos and makes the storage layout easy
/// to see at a glance.
class HiveBoxes {
  HiveBoxes._();

  static const String profiles = 'profiles';
  static const String documents = 'documents';
  static const String summaries = 'summaries';
  static const String flashcards = 'flashcards';
  static const String rewrites = 'rewrites';
  static const String ideas = 'ideas';
  static const String activity = 'activity';

  /// Small key/value box for app flags (e.g. whether sample data was seeded).
  static const String settings = 'settings';

  /// Settings keys.
  static const String seededKey = 'seeded';
}
