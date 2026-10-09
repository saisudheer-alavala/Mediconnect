import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/medicines/presentation/add_edit_medicine_screen.dart';
import 'package:mediconnect/features/medicines/presentation/medicine_list_screen.dart';

void main() {
  group('MedicineListScreen Tests', () {
    testWidgets('renders medication list, adherence score and add button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MedicineListScreen(),
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('MediTrack — Medications'), findsOneWidget);

      // Verify adherence score card
      expect(find.text('7-Day Adherence Score'), findsOneWidget);

      // Verify tabs
      expect(find.textContaining('Active'), findsOneWidget);
      expect(find.textContaining('All'), findsOneWidget);

      // Verify FAB
      expect(find.text('Add Medication'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('AddEditMedicineScreen Tests', () {
    testWidgets('renders medicine form fields and validates empty required inputs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddEditMedicineScreen(),
          ),
        ),
      );

      // Verify title & safety disclaimer
      expect(find.text('Add Medication'), findsOneWidget);
      expect(find.textContaining('MediTrack is a personal adherence reminder tool'), findsOneWidget);

      // Verify section headers
      expect(find.text('Medicine Details'), findsOneWidget);
      expect(find.text('Regimen Duration'), findsOneWidget);
      expect(find.text('Reminder Times'), findsOneWidget);

      // Scroll to save button and tap without filling required fields
      final saveButton = find.text('Save Medication Regimen');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      // Check validation error messages
      expect(find.text('Medicine name is required'), findsOneWidget);
      expect(find.text('Dosage is required'), findsOneWidget);
    });
  });
}
