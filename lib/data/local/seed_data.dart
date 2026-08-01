/// First-run sample-data seeding.
///
/// Sample/demo content is intentionally **disabled for production** (v1.28.1).
///
/// Why it changed: the old implementation read the *canonical* Hive box names
/// (e.g. `documents`, `profiles`) directly. Since v1.22.0 Encrypted Storage,
/// [AppStorage] opens study-data boxes under their physical `_sec` twins when
/// encryption is active (and removes the canonical ones after migration). On a
/// real signed release install, encryption is active, so those canonical boxes
/// are not open and `Hive.box(...)` threw `Box not found`, crashing startup on
/// the splash screen before Auth Landing.
///
/// Beyond the crash, shipping a fixed demo profile and notes into every new
/// account is not appropriate for production. New users now start with clean,
/// empty study data and the app's own empty-state guidance.
///
/// This is kept as a safe no-op so the startup call site stays stable and no
/// existing user data is ever touched. It opens no boxes, so it cannot crash
/// regardless of whether Encrypted Storage is active.
class SeedData {
  SeedData._();

  static Future<void> seedIfNeeded() async {
    // No sample data in production: nothing to open, nothing to seed.
    return;
  }
}
