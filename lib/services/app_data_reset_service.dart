import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../data/local/hive_boxes.dart';
import '../data/providers.dart';
import '../features/onboarding/onboarding_providers.dart';
import '../features/privacy_lock/privacy_lock_providers.dart';

/// Centralized, safe local-data deletion/reset for Play Store compliance
/// (v1.27.0). One place for both "Clear local study data" (keep account) and
/// the local wipe that backs "Delete account".
///
/// Everything works on the already-open Hive boxes via `clear()`, so it is
/// correct whether or not encryption is active — the boxes (and the encryption
/// key) stay intact and consistent, and the app reopens cleanly.
final appDataResetProvider =
    Provider<AppDataResetService>((ref) => AppDataResetService(ref));

class AppDataResetService {
  AppDataResetService(this._ref);

  final Ref _ref;

  // Settings-box keys owned by other features (kept in sync with their sources).
  static const _kFavorites = 'favoriteDocIds';
  static const _kOnboarding = 'onboardingCompleted';
  static const _kLockEnabled = 'privacyLockEnabled';
  static const _kLockBiometric = 'privacyLockBiometric';
  static const _kLockPinHash = 'privacyLockPinHash';
  static const _kLockPinSalt = 'privacyLockPinSalt';

  Box<dynamic> get _settings => Hive.box<dynamic>(HiveBoxes.settings);

  /// Clears all local study content but keeps the account and student profile.
  /// Backs "Clear local study data".
  Future<void> clearStudyData() async {
    await _ref.read(documentRepositoryProvider).clearAll();
    await _ref.read(summaryRepositoryProvider).clearAll();
    await _ref.read(flashcardRepositoryProvider).clearAll();
    await _ref.read(rewriteRepositoryProvider).clearAll();
    await _ref.read(ideaRepositoryProvider).clearAll();
    await _ref.read(quizRepositoryProvider).clearAll();
    await _ref.read(quizResultRepositoryProvider).clearAll();
    await _ref.read(activityRepositoryProvider).clearAll();
    await _ref.read(studyGoalRepositoryProvider).clearAll();
    // Favorites reference now-deleted notes.
    await _settings.delete(_kFavorites);
    _ref.invalidate(favoriteDocIdsProvider);
  }

  /// Wipes every piece of local user data — study content, the student profile,
  /// favorites, onboarding and Privacy Lock. Backs "Delete account".
  ///
  /// Intentionally keeps the encryption key and `storageEncrypted` flag (so the
  /// already-encrypted empty boxes stay valid — no corruption) and the `seeded`
  /// flag (so sample data does not reappear). The result opens like a fresh
  /// install, with no Privacy Lock trap.
  Future<void> wipeAllLocalData() async {
    await clearStudyData();
    await _ref.read(profileRepositoryProvider).clearAll();

    for (final key in const [
      _kOnboarding,
      _kLockEnabled,
      _kLockBiometric,
      _kLockPinHash,
      _kLockPinSalt,
    ]) {
      await _settings.delete(key);
    }

    _ref.invalidate(currentProfileProvider);
    _ref.invalidate(onboardingCompletedProvider);
    _ref.invalidate(privacyLockControllerProvider);
  }
}
