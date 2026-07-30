// Tests for v1.22.0 Encrypted Storage: the physical box-name mapping and the
// migration copy/verify logic. The AES cipher and secure key store are
// platform-only and covered by the build; the risky part — copying every
// entry and verifying counts before the plaintext is deleted — is unit-tested
// here with plaintext boxes (the copy is cipher-agnostic).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/app_storage.dart';
import 'package:gurukula_ai/data/models/study_document.dart';
import 'package:gurukula_ai/data/models/enums.dart';
import 'package:gurukula_ai/hive_registrar.g.dart';

StudyDocument _doc(String id) => StudyDocument(
      id: id,
      userId: 'u',
      title: 'Note $id',
      type: DocumentType.text,
      rawText: 'raw $id',
      cleanedText: 'clean $id',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  group('AppStorage.physical', () {
    tearDown(() => AppStorage.encryptionActive = false);

    test('uses the canonical name when encryption is off', () {
      AppStorage.encryptionActive = false;
      expect(AppStorage.physical('documents'), 'documents');
    });

    test('uses the _sec twin when encryption is on', () {
      AppStorage.encryptionActive = true;
      expect(AppStorage.physical('documents'), 'documents_sec');
    });
  });

  group('AppStorage.copyBox', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('gurukula_enc');
      Hive.init(tempDir.path);
      Hive.registerAdapters();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('copies all entries and verifies the count matches', () async {
      final src = await Hive.openBox<dynamic>('src1');
      final dst = await Hive.openBox<dynamic>('dst1');
      await src.putAll({'a': _doc('a'), 'b': _doc('b'), 'c': _doc('c')});

      final ok = await AppStorage.copyBox(src, dst);
      expect(ok, isTrue);
      expect(dst.length, 3);
      expect((dst.get('b') as StudyDocument).title, 'Note b');

      await src.deleteFromDisk();
      await dst.deleteFromDisk();
    });

    test('is idempotent when the destination is already fully copied', () async {
      final src = await Hive.openBox<dynamic>('src2');
      final dst = await Hive.openBox<dynamic>('dst2');
      await src.putAll({'a': _doc('a'), 'b': _doc('b')});

      expect(await AppStorage.copyBox(src, dst), isTrue);
      // Running again must not duplicate or corrupt anything.
      expect(await AppStorage.copyBox(src, dst), isTrue);
      expect(dst.length, 2);

      await src.deleteFromDisk();
      await dst.deleteFromDisk();
    });

    test('handles an empty source box', () async {
      final src = await Hive.openBox<dynamic>('src3');
      final dst = await Hive.openBox<dynamic>('dst3');

      expect(await AppStorage.copyBox(src, dst), isTrue);
      expect(dst.length, 0);

      await src.deleteFromDisk();
      await dst.deleteFromDisk();
    });
  });
}
