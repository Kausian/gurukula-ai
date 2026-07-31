// Tests for v1.25.0 onboarding completion flag: defaults to "not completed"
// when missing, persists across restarts, and can be reset.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:gurukula_ai/data/local/hive_boxes.dart';
import 'package:gurukula_ai/features/onboarding/onboarding_providers.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('gurukula_onboarding');
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

  test('defaults to not completed when the flag is missing (fresh install)',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(onboardingCompletedProvider), isFalse);
  });

  test('completing persists across an app restart', () async {
    final container = ProviderContainer();
    await container.read(onboardingCompletedProvider.notifier).complete();
    expect(container.read(onboardingCompletedProvider), isTrue);
    container.dispose();

    // A fresh container (like relaunching the app) reads the saved flag.
    final restarted = ProviderContainer();
    addTearDown(restarted.dispose);
    expect(restarted.read(onboardingCompletedProvider), isTrue);
  });

  test('reset clears the flag so onboarding would show again', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(onboardingCompletedProvider.notifier);

    await controller.complete();
    expect(container.read(onboardingCompletedProvider), isTrue);
    await controller.reset();
    expect(container.read(onboardingCompletedProvider), isFalse);
  });
}
