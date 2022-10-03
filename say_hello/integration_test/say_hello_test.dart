import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

// The application under test.
import 'package:say_hello/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the Say Hello button; verify count',
        (WidgetTester tester) async {
          app.main();
          await tester.pumpAndSettle();

          // Finds the Say Hello button to tap on.
          final Finder button = find.text("Say Hello");

          // Emulate a tap on the floating action button.
          await tester.tap(button);

          await tester.pumpAndSettle();

          expect(find.text('I have said hello 1 time'), findsOneWidget);
      });
  });
}
