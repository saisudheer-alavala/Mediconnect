import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/home/presentation/doctor_home_screen.dart';
import 'package:mediconnect/features/home/presentation/patient_home_screen.dart';
import 'package:mediconnect/features/medicines/data/medicine_repository.dart';
import 'package:mediconnect/features/medicines/domain/medicine_model.dart';

class _FakeMedicineRepository extends MedicineRepository {
  _FakeMedicineRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<void> logDose(
    String medicineId, {
    required DateTime scheduledTime,
    required String status,
    String? notes,
    DateTime? takenTime,
  }) async {
    return;
  }

  @override
  Future<AdherenceReportModel> getAdherenceReport({int days = 7}) async {
    return const AdherenceReportModel(
      totalDoses: 14,
      takenDoses: 12,
      skippedDoses: 1,
      missedDoses: 1,
      adherenceRatePercentage: 85.7,
      periodDays: 7,
    );
  }
}

void main() {
  group('PatientHomeScreen Tests', () {
    testWidgets('renders patient dashboard elements and toggles medicine taken', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            medicineRepositoryProvider.overrideWithValue(_FakeMedicineRepository()),
          ],
          child: const MaterialApp(
            home: PatientHomeScreen(),
          ),
        ),
      );

      // Verify greetings & cards
      expect(find.text('How are you feeling today?'), findsOneWidget);
      expect(find.text('Emergency Medical ID'), findsOneWidget);
      expect(find.text('Next Consultation'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text("Today's Medicines"), findsOneWidget);
      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('Vitamin D3'), findsOneWidget);

      // Tap to toggle medicine status
      await tester.tap(find.byIcon(Icons.radio_button_unchecked_rounded).first);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('DoctorHomeScreen Tests', () {
    testWidgets('renders doctor practice metrics and next patient card', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DoctorHomeScreen(),
          ),
        ),
      );

      // Verify metric labels
      expect(find.text("Today's Consultations"), findsOneWidget);
      expect(find.text('Pending Requests'), findsOneWidget);
      expect(find.text('Completed Today'), findsOneWidget);
      expect(find.text('Next Patient in Queue'), findsOneWidget);
      expect(find.text('Michael Chang (Male, 42y)'), findsOneWidget);
      expect(find.text('Begin Consultation'), findsOneWidget);

      // Toggle consultation availability switch
      expect(find.text('Accepting Patients'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('Paused / Off Duty'), findsOneWidget);
    });
  });
}
