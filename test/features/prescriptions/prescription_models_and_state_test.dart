import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/medicines/data/medicine_repository.dart';
import 'package:mediconnect/features/medicines/domain/medicine_model.dart';
import 'package:mediconnect/features/prescriptions/data/prescription_repository.dart';
import 'package:mediconnect/features/prescriptions/domain/prescription_model.dart';
import 'package:mediconnect/features/prescriptions/presentation/prescription_controller.dart';

class _FakeMedicineRepository extends MedicineRepository {
  _FakeMedicineRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<MedicineModel> createMedicine(Map<String, dynamic> data) async {
    return MedicineModel(
      id: 'med-new-${DateTime.now().millisecondsSinceEpoch}',
      patientId: 'patient-current',
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      frequency: data['frequency'] as String,
      instructions: data['instructions'] as String?,
      startDate: DateTime.now(),
      reminders: const [MedicineReminderModel(id: 'rem-1', medicineId: 'med-new', reminderTime: '09:00')],
    );
  }
}

class _FakePrescriptionRepository extends PrescriptionRepository {
  _FakePrescriptionRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async {
    return [
      PrescriptionModel(
        id: 'rx-mock-1',
        patientId: 'patient-1',
        doctorId: 'doc-1',
        doctorName: 'Dr. John Watson',
        doctorSpecialization: 'General Practice',
        clinicName: 'Baker Clinic',
        diagnosis: 'Seasonal Rhinitis',
        issuedAt: DateTime.now(),
        medicines: const [
          PrescriptionMedicineModel(
            id: 'm-1',
            medicineName: 'Loratadine',
            dosage: '10mg',
            frequency: 'Once daily',
            durationDays: 10,
          ),
        ],
      ),
    ];
  }

  @override
  Future<PrescriptionModel> issuePrescription(Map<String, dynamic> payload) async {
    return PrescriptionModel(
      id: 'rx-issued-100',
      patientId: payload['patientId'] as String,
      doctorId: 'doc-current',
      doctorName: 'Dr. Specialist',
      doctorSpecialization: 'Internal Medicine',
      clinicName: 'Metro Hospital',
      diagnosis: payload['diagnosis'] as String,
      generalInstructions: payload['generalInstructions'] as String?,
      issuedAt: DateTime.now(),
      medicines: (payload['medicines'] as List)
          .map((m) => PrescriptionMedicineModel(
                id: 'm-new',
                medicineName: m['medicineName'] as String,
                dosage: m['dosage'] as String,
                frequency: m['frequency'] as String,
                durationDays: m['durationDays'] as int,
                instructions: m['instructions'] as String?,
              ))
          .toList(),
    );
  }
}

void main() {
  group('PrescriptionModel Domain Tests', () {
    test('fromJson and toJson parse nested medicines and physician metadata correctly', () {
      final json = {
        'id': 'rx-test-1',
        'appointmentId': 'appt-test-1',
        'patientId': 'patient-123',
        'doctorId': 'doc-456',
        'diagnosis': 'Bronchitis',
        'generalInstructions': 'Steam inhalation twice daily',
        'issuedAt': '2026-10-08T10:00:00.000Z',
        'doctor': {
          'fullName': 'Dr. Robert Hayes',
          'clinicName': 'Neuro Healthcare Center',
          'clinicAddress': '55 University Avenue',
          'qualification': 'MD, DM',
          'licenseNumber': 'MD-NEURO-771',
          'specialization': {'name': 'Neurology'},
        },
        'patient': {
          'fullName': 'Sarah Connor',
        },
        'medicines': [
          {
            'id': 'med-1',
            'medicineName': 'Azithromycin',
            'dosage': '500mg',
            'frequency': 'Once daily',
            'durationDays': 5,
            'instructions': 'After meals',
          },
        ],
      };

      final model = PrescriptionModel.fromJson(json);

      expect(model.id, 'rx-test-1');
      expect(model.appointmentId, 'appt-test-1');
      expect(model.doctorName, 'Dr. Robert Hayes');
      expect(model.doctorSpecialization, 'Neurology');
      expect(model.clinicName, 'Neuro Healthcare Center');
      expect(model.licenseNumber, 'MD-NEURO-771');
      expect(model.patientName, 'Sarah Connor');
      expect(model.diagnosis, 'Bronchitis');
      expect(model.totalMedicinesCount, 1);
      expect(model.medicines.first.medicineName, 'Azithromycin');
      expect(model.medicines.first.dosage, '500mg');
      expect(model.medicines.first.durationDays, 5);
      expect(model.formattedIssuedDate, contains('Oct 08, 2026'));

      final serialized = model.toJson();
      expect(serialized['id'], 'rx-test-1');
      expect(serialized['diagnosis'], 'Bronchitis');
    });
  });

  group('PrescriptionController State Management Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          prescriptionRepositoryProvider.overrideWithValue(_FakePrescriptionRepository()),
          medicineRepositoryProvider.overrideWithValue(_FakeMedicineRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state loads fallback prescriptions for offline resilience', () {
      final state = container.read(prescriptionControllerProvider);

      expect(state.prescriptions.isNotEmpty, isTrue);
      expect(state.prescriptions.any((p) => p.doctorName.contains('Marcus')), isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isIssuing, isFalse);
    });

    test('issuePrescription adds newly issued prescription to state', () async {
      final controller = container.read(prescriptionControllerProvider.notifier);

      final success = await controller.issuePrescription({
        'patientId': 'patient-abc',
        'diagnosis': 'Gastric Ulcer',
        'medicines': [
          {
            'medicineName': 'Pantoprazole',
            'dosage': '40mg',
            'frequency': 'Once daily before breakfast',
            'durationDays': 14,
          },
        ],
      });

      expect(success, isTrue);
      final state = container.read(prescriptionControllerProvider);
      expect(state.prescriptions.first.id, 'rx-issued-100');
      expect(state.prescriptions.first.diagnosis, 'Gastric Ulcer');
      expect(state.successMessage, contains('Digital prescription issued'));
    });

    test('importPrescriptionToMediTrack triggers medicine creation for each item', () async {
      final controller = container.read(prescriptionControllerProvider.notifier);
      final rx = container.read(prescriptionControllerProvider).prescriptions.first;

      final count = await controller.importPrescriptionToMediTrack(rx);

      expect(count, greaterThan(0));
      expect(container.read(prescriptionControllerProvider).successMessage, contains('Imported'));
    });
  });
}
