// Regression test for the v1.28.1 startup crash: SeedData.seedIfNeeded read
// canonical Hive box names directly, but Encrypted Storage opens study boxes
// under their physical `_sec` twins, so on a signed release those canonical
// boxes are not open and `Hive.box(...)` threw "Box not found", freezing the
// splash screen. Seeding is now a safe no-op that opens no boxes.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/data/local/seed_data.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_seed');
    Hive.init(tempDir.path);
    // Deliberately open ONLY the settings box — mirroring a fresh encrypted
    // startup where the canonical study boxes (documents, profiles, ...) are
    // NOT open under their plain names. This is the exact crash condition.
    await Hive.openBox<dynamic>(HiveBoxes.settings);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('seedIfNeeded does not throw when study boxes are not open', () async {
    // Would have thrown HiveError: Box not found before the fix.
    await expectLater(SeedData.seedIfNeeded(), completes);
  });

  test('seedIfNeeded seeds no sample data (production skip)', () async {
    await SeedData.seedIfNeeded();
    // It opened nothing: only the settings box we opened exists here.
    expect(Hive.isBoxOpen(HiveBoxes.documents), isFalse);
    expect(Hive.isBoxOpen(HiveBoxes.profiles), isFalse);
  });
}
