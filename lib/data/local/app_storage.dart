import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../hive_registrar.g.dart';
import '../models/activity_event.dart';
import '../models/flashcard.dart';
import '../models/idea.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../models/rewrite.dart';
import '../models/study_document.dart';
import '../models/study_goal.dart';
import '../models/summary.dart';
import '../models/user_profile.dart';
import 'encryption_key_store.dart';
import 'hive_boxes.dart';

/// Owns Hive initialization and the v1.22.0 Encrypted Storage migration.
///
/// Study-data boxes are encrypted at rest with a random AES key kept in the
/// device secure store. Existing (plaintext) data is migrated once, with the
/// counts verified before the plaintext copies are deleted. If anything goes
/// wrong — or no key is available — the app runs on the original plaintext
/// boxes so no data is lost.
class AppStorage {
  AppStorage._();

  /// Whether study-data boxes are currently encrypted. Set during [init].
  /// Exposed so the UI can show an honest "Storage Protection" status.
  static bool encryptionActive = false;

  /// Study-data boxes protected by encryption. `settings` is intentionally
  /// excluded: it is needed for bootstrapping (migration flag, theme, seeded
  /// flag) and holds no sensitive plaintext (the Privacy Lock PIN is a hash).
  static const List<String> sensitiveBoxes = [
    HiveBoxes.profiles,
    HiveBoxes.documents,
    HiveBoxes.summaries,
    HiveBoxes.flashcards,
    HiveBoxes.rewrites,
    HiveBoxes.ideas,
    HiveBoxes.quizzes,
    HiveBoxes.quizResults,
    HiveBoxes.activity,
    HiveBoxes.studyGoals,
  ];

  static const String _secSuffix = '_sec';
  static const String _flagKey = 'storageEncrypted';

  /// The physical box name for a logical box: the encrypted twin when
  /// encryption is active, otherwise the canonical (plaintext) name. Repos and
  /// providers resolve box names through here so there is one source of truth.
  static String physical(String logical) =>
      encryptionActive ? '$logical$_secSuffix' : logical;

  /// Initializes Hive and opens every box, migrating to encrypted storage when
  /// safe. Must complete before the app reads any box.
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    // Settings is always plaintext and canonical — it drives bootstrapping.
    await Hive.openBox<dynamic>(HiveBoxes.settings);
    final settings = Hive.box<dynamic>(HiveBoxes.settings);

    final key = await EncryptionKeyStore.getOrCreateKey();

    // No key available -> run fully unencrypted on the canonical boxes.
    if (key == null) {
      encryptionActive = false;
      await _openTypedBoxes(null);
      return;
    }

    final cipher = HiveAesCipher(key);
    final alreadyMigrated =
        settings.get(_flagKey, defaultValue: false) as bool? ?? false;

    if (alreadyMigrated) {
      try {
        encryptionActive = true;
        await _openTypedBoxes(cipher);
        // Idempotent cleanup of any plaintext left from an interrupted run.
        await _deletePlaintextBoxes();
        return;
      } catch (_) {
        // Encrypted boxes couldn't be opened (e.g. key changed). Fail safe:
        // run so the app still opens, without wiping the encrypted files.
        encryptionActive = false;
        await _openTypedBoxes(null);
        return;
      }
    }

    // Not migrated yet: attempt an all-or-nothing, verified migration.
    try {
      await _migrateToEncrypted(cipher);
      await settings.put(_flagKey, true);
      await _deletePlaintextBoxes();
      encryptionActive = true;
      await _openTypedBoxes(cipher);
    } catch (_) {
      // Migration failed -> keep original plaintext data untouched and run
      // unencrypted. The migration is retried on the next launch.
      encryptionActive = false;
      await _cleanupPartialEncryptedBoxes();
      await _openTypedBoxes(null);
    }
  }

  /// Copies every sensitive box into its encrypted twin and verifies the entry
  /// counts. Throws on any mismatch so the caller can abort without deleting
  /// the plaintext originals. Type-agnostic (dynamic) copy: adapters handle
  /// (de)serialization of the real model objects.
  static Future<void> _migrateToEncrypted(HiveCipher cipher) async {
    for (final name in sensitiveBoxes) {
      final src = await Hive.openBox<dynamic>(name);
      final dst =
          await Hive.openBox<dynamic>('$name$_secSuffix', encryptionCipher: cipher);
      try {
        final copied = await copyBox(src, dst);
        if (!copied) {
          throw StateError('Encrypted migration failed for "$name".');
        }
      } finally {
        await src.close();
        await dst.close();
      }
    }
  }

  /// Copies all entries from [src] into [dst] (unless already fully copied) and
  /// returns whether the destination count matches the source. Pure and
  /// cipher-agnostic so it can be unit-tested with plaintext boxes.
  static Future<bool> copyBox(Box<dynamic> src, Box<dynamic> dst) async {
    final alreadyCopied = dst.length == src.length && dst.isNotEmpty;
    if (!alreadyCopied) {
      await dst.clear();
      await dst.putAll({for (final k in src.keys) k: src.get(k)});
    }
    return dst.length == src.length;
  }

  static Future<void> _openTypedBoxes(HiveCipher? cipher) async {
    await Future.wait([
      Hive.openBox<UserProfile>(physical(HiveBoxes.profiles),
          encryptionCipher: cipher),
      Hive.openBox<StudyDocument>(physical(HiveBoxes.documents),
          encryptionCipher: cipher),
      Hive.openBox<Summary>(physical(HiveBoxes.summaries),
          encryptionCipher: cipher),
      Hive.openBox<Flashcard>(physical(HiveBoxes.flashcards),
          encryptionCipher: cipher),
      Hive.openBox<Rewrite>(physical(HiveBoxes.rewrites),
          encryptionCipher: cipher),
      Hive.openBox<Idea>(physical(HiveBoxes.ideas), encryptionCipher: cipher),
      Hive.openBox<Quiz>(physical(HiveBoxes.quizzes), encryptionCipher: cipher),
      Hive.openBox<QuizResult>(physical(HiveBoxes.quizResults),
          encryptionCipher: cipher),
      Hive.openBox<ActivityEvent>(physical(HiveBoxes.activity),
          encryptionCipher: cipher),
      Hive.openBox<StudyGoal>(physical(HiveBoxes.studyGoals),
          encryptionCipher: cipher),
    ]);
  }

  /// Deletes the plaintext originals after a verified migration. Idempotent.
  static Future<void> _deletePlaintextBoxes() async {
    for (final name in sensitiveBoxes) {
      try {
        await Hive.deleteBoxFromDisk(name);
      } catch (_) {
        // Best effort — a failure here doesn't affect the encrypted data.
      }
    }
  }

  /// Removes any partially written encrypted boxes after a failed migration so
  /// the next attempt starts clean. The plaintext originals are left untouched.
  static Future<void> _cleanupPartialEncryptedBoxes() async {
    for (final name in sensitiveBoxes) {
      try {
        await Hive.deleteBoxFromDisk('$name$_secSuffix');
      } catch (_) {
        // Best effort.
      }
    }
  }
}
