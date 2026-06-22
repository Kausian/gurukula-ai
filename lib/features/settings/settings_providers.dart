import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/local/hive_boxes.dart';
import '../../data/providers.dart';

/// The app's version name from the build (e.g. "1.10.0"), read at runtime so
/// the About section is always accurate.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// The app theme mode, persisted locally in the settings box.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'themeMode';

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.settings);

  @override
  ThemeMode build() => _fromString(_box.get(_key) as String?);

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _box.put(_key, mode.name);
  }

  ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Deletes all local study data (documents, summaries, flashcards, rewrites,
/// ideas, quizzes, quiz results and activity). The profile and sign-in are
/// kept.
Future<void> deleteLocalStudyData(WidgetRef ref) async {
  await ref.read(documentRepositoryProvider).clearAll();
  await ref.read(summaryRepositoryProvider).clearAll();
  await ref.read(flashcardRepositoryProvider).clearAll();
  await ref.read(rewriteRepositoryProvider).clearAll();
  await ref.read(ideaRepositoryProvider).clearAll();
  await ref.read(quizRepositoryProvider).clearAll();
  await ref.read(quizResultRepositoryProvider).clearAll();
  await ref.read(activityRepositoryProvider).clearAll();
}
