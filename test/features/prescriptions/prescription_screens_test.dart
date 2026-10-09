import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/medicines/data/medicine_repository.dart';
import 'package:mediconnect/features/medicines/domain/medicine_model.dart';
import 'package:mediconnect/features/prescriptions/data/prescription_repository.dart';
import 'package:mediconnect/features/prescriptions/domain/prescription_model.dart';
import 'package:mediconnect/features/prescriptions/presentation/issue_prescription_screen.dart';
import 'package:mediconnect/features/prescriptions/presentation/prescription_details_screen.dart';
import 'package:mediconnect/features/prescriptions/presentation/prescription_list_screen.dart';

final _testDate = DateTime(2026, 10, 8);
final _testPrescription = PrescriptionModel(
  id: 'rx-widget-1',
  patientId: 'patient-widget',
  doctorId: 'doc-widget',
  doctorName: 'Dr. Marcus Vance',
  doctorSpecialization: 'Dermatology',
  qualification: 'MBBS, MD (Dermatology)',
  licenseNumber: 'MD-DERM-44109',
  clinicName: 'Skin & Glow Clinic',
  clinicAddress: '180 Broadway Medical Center',
  patientName: 'Alex Mercer',
  diagnosis: 'Atopic Contact Dermatitis',
  generalInstructions: 'Keep skin hydrated with hypoallergenic moisturizer.',
  issuedAt: _testDate,
  medicines: const [
    PrescriptionMedicineModel(
      id: 'm-1',
      medicineName: 'Cetirizine Hydrochloride',
      dosage: '10mg',
      frequency: 'Once daily at bedtime',
      durationDays: 14,
      instructions: 'Take with water after dinner',
    ),
  ],
);

final _cardioPrescription = PrescriptionModel(
  id: 'rx-widget-2',
  patientId: 'patient-widget',
  doctorId: 'doc-cardio',
  doctorName: 'Dr. Sarah Jenkins',
  doctorSpecialization: 'Cardiology',
  qualification: 'MBBS, MD (Cardiology)',
  licenseNumber: 'MD-CARD-88321',
  clinicName: 'City Heart Hospital',
  diagnosis: 'Mild Hypertension',
  issuedAt: _testDate,
  medicines: const [
    PrescriptionMedicineModel(
      id: 'm-2',
      medicineName: 'Amlodipine Besylate',
      dosage: '5mg',
      frequency: 'Once daily',
      durationDays: 30,
    ),
  ],
);

class _FakeMedicineRepository extends MedicineRepository {
  _FakeMedicineRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<MedicineModel> createMedicine(Map<String, dynamic> data) async {
    return MedicineModel(
      id: 'med-created-1',
      patientId: 'p-1',
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      frequency: data['frequency'] as String,
      startDate: DateTime.now(),
      reminders: const [],
    );
  }
}

class _FakePrescriptionRepository extends PrescriptionRepository {
  _FakePrescriptionRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async {
    return [_testPrescription, _cardioPrescription];
  }

  @override
  Future<PrescriptionModel> issuePrescription(Map<String, dynamic> payload) async {
    return _testPrescription;
  }
}

void main() {
  group('PrescriptionListScreen Widget Tests', () {
    testWidgets('renders prescription list, search field, and filters cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prescriptionRepositoryProvider.overrideWithValue(_FakePrescriptionRepository()),
            medicineRepositoryProvider.overrideWithValue(_FakeMedicineRepository()),
          ],
          child: const MaterialApp(
            home: PrescriptionListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Digital Prescriptions'), findsOneWidget);
      expect(find.text('Search prescription, diagnosis or doctor...'), findsOneWidget);

      // Verify prescription cards
      expect(find.text('Dr. Marcus Vance'), findsWidgets);
      expect(find.text('Atopic Contact Dermatitis'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsWidgets);
      expect(find.text('Mild Hypertension'), findsOneWidget);

      // Search filter
      await tester.enterText(find.byType(TextField), 'Cardiology');
      await tester.pumpAndSettle();

      // Only cardiology prescription should remain
      expect(find.text('Dr. Sarah Jenkins'), findsWidgets);
      expect(find.text('Dr. Marcus Vance'), findsNothing);
    });
  });

  group('PrescriptionDetailsScreen Widget Tests', () {
    testWidgets('renders letterhead, diagnosis, medicines, and imports to MediTrack', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prescriptionRepositoryProvider.overrideWithValue(_FakePrescriptionRepository()),
            medicineRepositoryProvider.overrideWithValue(_FakeMedicineRepository()),
          ],
          child: MaterialApp(
            home: PrescriptionDetailsScreen(prescription: _testPrescription),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Letterhead
      expect(find.text('Digital Prescription'), findsOneWidget);
      expect(find.text('Skin & Glow Clinic'), findsOneWidget);
      expect(find.text('Rx'), findsOneWidget);
      expect(find.text('Lic: MD-DERM-44109'), findsOneWidget);

      // Diagnosis and medicines
      expect(find.text('Atopic Contact Dermatitis'), findsOneWidget);
      expect(find.text('Cetirizine Hydrochloride'), findsOneWidget);
      expect(find.text('10mg'), findsOneWidget);

      // Import button
      final importBtn = find.byKey(const Key('import_to_meditrack_button'));
      expect(importBtn, findsOneWidget);
      await tester.tap(importBtn);
      await tester.pumpAndSettle();

      // Feedback snackbar
      expect(find.textContaining('Successfully imported'), findsOneWidget);
    });
  });

  group('IssuePrescriptionScreen Widget Tests', () {
    testWidgets('allows adding medicines and issuing prescription', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prescriptionRepositoryProvider.overrideWithValue(_FakePrescriptionRepository()),
            medicineRepositoryProvider.overrideWithValue(_FakeMedicineRepository()),
          ],
          child: const MaterialApp(
            home: IssuePrescriptionScreen(
              patientId: 'patient-widget',
              patientName: 'Alex Mercer',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Issue Digital Prescription'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsOneWidget);

      // Enter diagnosis
      final diagnosisInput = find.byKey(const Key('prescription_diagnosis_input'));
      expect(diagnosisInput, findsOneWidget);
      await tester.enterText(diagnosisInput, 'Acute Bronchitis');

      // Add second medicine row
      final addDrugBtn = find.byKey(const Key('add_medicine_row_button'));
      expect(addDrugBtn, findsOneWidget);
      await tester.tap(addDrugBtn);
      await tester.pumpAndSettle();

      expect(find.text('Medication #2'), findsOneWidget);

      // Submit
      final submitBtn = find.byKey(const Key('submit_prescription_button'));
      expect(submitBtn, findsOneWidget);
    });
  });
}
