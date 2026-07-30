// Tests for v1.21.0 Privacy Lock: the PIN hasher (no plaintext, salted,
// verifiable) and the lock controller lifecycle (enable/unlock/disable/change).
// Biometric (local_auth) is not exercised here — it is UI/plugin-only.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/core/utils/pin_hasher.dart';
import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/features/privacy_lock/privacy_lock_providers.dart';

void main() {
  group('PinHasher', () {
    test('never returns the raw PIN and verifies correctly', () {
      final salt = PinHasher.newSalt();
      final hash = PinHasher.hashPin('1234', salt);

      expect(hash, isNot(contains('1234')));
      expect(hash.length, greaterThan(20));
      expect(PinHasher.verify('1234', salt, hash), isTrue);
      expect(PinHasher.verify('0000', salt, hash), isFalse);
    });

    test('same PIN with different salts yields different hashes', () {
      final h1 = PinHasher.hashPin('4321', PinHasher.newSalt());
      final h2 = PinHasher.hashPin('4321', PinHasher.newSalt());
      expect(h1, isNot(equals(h2)));
    });
  });

  group('PrivacyLockController', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('gurukula_lock');
      Hive.init(tempDir.path);
      await Hive.openBox<dynamic>(HiveBoxes.settings);
    });

    tearDown(() async {
      await Hive.box<dynamic>(HiveBoxes.settings).clear();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('starts disabled and unlocked by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(privacyLockControllerProvider);
      expect(state.enabled, isFalse);
      expect(state.isLocked, isFalse);
    });

    test('enabling sets a PIN and keeps the current session unlocked', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(privacyLockControllerProvider.notifier);

      await controller.enable(pin: '2468', biometric: false);
      final state = container.read(privacyLockControllerProvider);
      expect(state.enabled, isTrue);
      expect(state.hasPin, isTrue);
      expect(state.isLocked, isFalse); // set up in-session, not locked yet

      // The raw PIN is not stored anywhere in the settings box.
      final box = Hive.box<dynamic>(HiveBoxes.settings);
      expect(box.get('privacyLockPinHash'), isNot(contains('2468')));
    });

    test('a fresh controller (app restart) is locked when enabled', () async {
      final setup = ProviderContainer();
      await setup
          .read(privacyLockControllerProvider.notifier)
          .enable(pin: '2468', biometric: false);
      setup.dispose();

      // Simulate a cold start: a brand new container reads persisted prefs.
      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      expect(restarted.read(privacyLockControllerProvider).isLocked, isTrue);
    });

    test('unlockWithPin accepts the right PIN and rejects wrong ones', () async {
      // Set up the lock, then simulate a cold start so the session is locked.
      final setup = ProviderContainer();
      await setup
          .read(privacyLockControllerProvider.notifier)
          .enable(pin: '2468', biometric: false);
      setup.dispose();

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(privacyLockControllerProvider.notifier);
      expect(container.read(privacyLockControllerProvider).isLocked, isTrue);

      expect(controller.unlockWithPin('0000'), isFalse);
      expect(container.read(privacyLockControllerProvider).isLocked, isTrue);
      expect(controller.unlockWithPin('2468'), isTrue);
      expect(container.read(privacyLockControllerProvider).isLocked, isFalse);
    });

    test('disable requires the correct PIN', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(privacyLockControllerProvider.notifier);
      await controller.enable(pin: '2468', biometric: true);

      expect(await controller.disable('0000'), isFalse);
      expect(container.read(privacyLockControllerProvider).enabled, isTrue);

      expect(await controller.disable('2468'), isTrue);
      final state = container.read(privacyLockControllerProvider);
      expect(state.enabled, isFalse);
      expect(state.hasPin, isFalse);
      expect(state.biometricEnabled, isFalse);
    });

    test('changePin requires the current PIN and updates it', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller =
          container.read(privacyLockControllerProvider.notifier);
      await controller.enable(pin: '1111', biometric: false);

      expect(
          await controller.changePin(currentPin: '9999', newPin: '2222'),
          isFalse);
      expect(
          await controller.changePin(currentPin: '1111', newPin: '2222'),
          isTrue);

      // New PIN works, old one does not, on a fresh (locked) session.
      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      final rc = restarted.read(privacyLockControllerProvider.notifier);
      expect(rc.unlockWithPin('1111'), isFalse);
      expect(rc.unlockWithPin('2222'), isTrue);
    });
  });
}
