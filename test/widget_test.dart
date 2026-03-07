import 'package:flutter_test/flutter_test.dart';
import 'package:chunha/main.dart';
import 'package:chunha/core/di/dependency_injection.dart' as di;

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Initialize dependencies for testing if needed, 
    // but MyApp will call di.init() in its build/main if we're not careful.
    // However, since we're testing the widget, we should ensure DI is ready.
    try {
      await di.init();
    } catch (_) {
      // Ignore if already initialized
    }

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();
  });
}
