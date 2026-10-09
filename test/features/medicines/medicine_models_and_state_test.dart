import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/medicines/domain/medicine_model.dart';
import 'package:mediconnect/features/medicines/presentation/medicine_controller.dart';

void main() {
  group('Medicine Domain Models Tests', () {
    test('MedicineModel deserializes and serializes JSON correctly', () {
      final json = {
        'id': 'med-123',
        'patientId': 'patient-456',
        'name': 'Metformin',
        'dosage': '500mg',
        'frequency': 'Twice daily',
        'instructions': 'Take after food',
        'startDate': '2026-10-01T00:00:00.000Z',
        'endDate': '2026-12-31T00:00:00.000Z',
        'isActive': true,
        'reminders': [
          {'id': 'rem-1', 'medicineId': 'med-123', 'reminderTime': '08:00'},
          {'id': 'rem-2', 'medicineId': 'med-123', 'reminderTime': '20:00'},
        ],
      };

      final model = MedicineModel.fromJson(json);

      expect(model.id, 'med-123');
      expect(model.name, 'Metformin');
      expect(model.dosage, '500mg');
      expect(model.frequency, 'Twice daily');
      expect(model.instructions, 'Take after food');
      expect(model.isActive, true);
      expect(model.reminders.length, 2);
      expect(model.reminders.first.reminderTime, '08:00');

      final serialized = model.toJson();
      expect(serialized['id'], 'med-123');
      expect(serialized['name'], 'Metformin');
      expect((serialized['reminders'] as List).length, 2);
    });

    test('TodayDoseItem deserializes JSON and status getters work as expected', () {
      final json = {
        'medicineId': 'med-123',
        'medicineName': 'Atorvastatin',
        'dosage': '20mg',
        'frequency': 'Once daily',
        'instructions': 'At night',
        'reminderId': 'rem-1',
        'reminderTime': '21:00',
        'scheduledTime': '2026-10-08T21:00:00.000Z',
        'status': 'TAKEN',
        'logId': 'log-999',
        'takenTime': '2026-10-08T21:05:00.000Z',
      };

      final dose = TodayDoseItem.fromJson(json);

      expect(dose.medicineName, 'Atorvastatin');
      expect(dose.reminderTime, '21:00');
      expect(dose.status, 'TAKEN');
      expect(dose.isTaken, isTrue);
      expect(dose.isSkipped, isFalse);
      expect(dose.isPending, isFalse);

      final pendingCopy = dose.copyWith(status: 'PENDING');
      expect(pendingCopy.isPending, isTrue);
      expect(pendingCopy.isTaken, isFalse);
    });

    test('AdherenceReportModel parses metrics correctly', () {
      final json = {
        'totalDoses': 20,
        'takenDoses': 18,
        'skippedDoses': 1,
        'missedDoses': 1,
        'adherenceRatePercentage': 90.0,
        'periodDays': 7,
      };

      final report = AdherenceReportModel.fromJson(json);

      expect(report.totalDoses, 20);
      expect(report.takenDoses, 18);
      expect(report.adherenceRatePercentage, 90.0);
      expect(report.periodDays, 7);
    });
  });

  group('MedicineState Tests', () {
    test('MedicineState default values and copyWith function properly', () {
      const state = MedicineState();

      expect(state.isLoading, isFalse);
      expect(state.isSubmitting, isFalse);
      expect(state.medicines, isEmpty);
      expect(state.todayDoses, isEmpty);
      expect(state.errorMessage, isNull);

      final updated = state.copyWith(
        isLoading: true,
        errorMessage: 'Connection failure',
      );

      expect(updated.isLoading, isTrue);
      expect(updated.errorMessage, 'Connection failure');

      final cleared = updated.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });
  });
}
