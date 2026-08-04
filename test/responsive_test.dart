// Responsiveness smoke tests (v1.31.1).
//
// These are deliberately small and non-fragile: no golden/screenshot checks.
// They assert the responsive helpers behave, and that the scroll-safe shared
// widgets render without a RenderFlex overflow on a short screen at a large
// system font size — the exact conditions that bite small Android phones.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/app/theme.dart';
import 'package:gurukula_ai/core/ui/responsive.dart';
import 'package:gurukula_ai/core/widgets/empty_state.dart';

void main() {
  group('Responsive', () {
    Future<ScreenSize> sizeFor(WidgetTester tester, double width) async {
      late ScreenSize result;
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = Responsive.sizeOf(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      return result;
    }

    testWidgets('classifies phone / large / tablet widths', (tester) async {
      expect(await sizeFor(tester, 360), ScreenSize.compact);
      expect(await sizeFor(tester, 700), ScreenSize.medium);
      expect(await sizeFor(tester, 900), ScreenSize.expanded);
    });

    testWidgets('scaledHeight grows with the system font size', (tester) async {
      late double atOne;
      late double atLarge;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: Builder(builder: (context) {
            atLarge = Responsive.scaledHeight(context, 100);
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            atOne = Responsive.scaledHeight(context, 100);
            return const SizedBox.shrink();
          }),
        ),
      );
      expect(atOne, 100);
      // Grows, but is capped (default maxScale 1.5) so it can't run away.
      expect(atLarge, greaterThan(atOne));
      expect(atLarge, lessThanOrEqualTo(150));
    });
  });

  testWidgets('MaxWidthBox caps content width on a wide screen',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MaxWidthBox(
            child: SizedBox(height: 20, child: Text('x')),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(SizedBox).first);
    expect(size.width, lessThanOrEqualTo(Responsive.maxContentWidth));
  });

  testWidgets(
      'EmptyState with an action does not overflow on a short, large-font screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 380);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: Scaffold(
          body: EmptyState(
            icon: Icons.folder_open_rounded,
            title: 'Start your study space',
            message: 'Add your first note to create summaries, flashcards and '
                'quizzes. Everything stays on your device.',
            action: FilledButton(
              onPressed: () {},
              child: const Text('Add a note'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // No RenderFlex overflow was thrown, and the content is scroll-safe.
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
