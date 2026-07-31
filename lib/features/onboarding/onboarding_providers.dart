import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../data/local/hive_boxes.dart';

/// Whether the first-run onboarding has been completed (v1.25.0).
///
/// Stored as a simple flag in the (plaintext, bootstrap) settings box — the
/// same pattern as theme mode and the privacy-lock flags. A missing flag means
/// "not completed", so brand-new installs see onboarding on first run.
final onboardingCompletedProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends Notifier<bool> {
  static const _key = 'onboardingCompleted';

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.settings);

  @override
  bool build() => _box.get(_key, defaultValue: false) as bool? ?? false;

  /// Marks onboarding as done and persists it. Idempotent.
  Future<void> complete() async {
    await _box.put(_key, true);
    state = true;
  }

  /// Clears the flag so onboarding would show again (used by tests; the app's
  /// "View onboarding" simply reopens the screen without clearing this).
  Future<void> reset() async {
    await _box.put(_key, false);
    state = false;
  }
}
