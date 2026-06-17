// Smoke test for the Gurukula AI app shell.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gurukula_ai/app/app.dart';

void main() {
  testWidgets('Welcome screen shows brand and primary CTA', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GurukulaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Gurukula'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
