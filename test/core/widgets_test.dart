import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/widgets/custom_button.dart';
import 'package:mediconnect/core/widgets/custom_text_field.dart';
import 'package:mediconnect/core/widgets/empty_state_view.dart';
import 'package:mediconnect/core/widgets/error_view.dart';
import 'package:mediconnect/core/widgets/loading_indicator.dart';

void main() {
  group('CustomButton Tests', () {
    testWidgets('renders button text and triggers onPressed callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Book Now',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Book Now'), findsOneWidget);
      await tester.tap(find.text('Book Now'));
      expect(tapped, isTrue);
    });

    testWidgets('shows progress indicator and disables tapping when isLoading is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
      await tester.tap(find.byType(CustomButton));
      expect(tapped, isFalse);
    });
  });

  group('CustomTextField Tests', () {
    testWidgets('allows text entry and toggles password visibility', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              labelText: 'Password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Secret123');
      expect(controller.text, 'Secret123');

      // Tap toggle icon
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('ErrorView & EmptyStateView Tests', () {
    testWidgets('renders ErrorView with retry button', (tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Failed to load doctors',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Failed to load doctors'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retryTriggered, isTrue);
    });

    testWidgets('renders EmptyStateView with action button', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'No Medicines',
              description: 'You have no medicines scheduled for today.',
              actionText: 'Add Medicine',
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No Medicines'), findsOneWidget);
      expect(find.text('You have no medicines scheduled for today.'), findsOneWidget);
      await tester.tap(find.text('Add Medicine'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('renders LoadingIndicator with message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: 'Fetching appointments...'),
          ),
        ),
      );

      expect(find.text('Fetching appointments...'), findsOneWidget);
    });
  });
}
