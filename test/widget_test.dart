import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/app/app.dart';
import 'package:mediconnect/core/constants/app_constants.dart';

void main() {
  testWidgets('MediCareApp smoke test renders app name', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MediCareApp(),
      ),
    );

    // Allow initial frames to render (avoid pumpAndSettle on continuous animations)
    await tester.pump(const Duration(milliseconds: 200));

    // Verify that MediCare Connect branding is present
    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
