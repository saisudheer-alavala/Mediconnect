import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/doctors/domain/doctor_model.dart';
import 'package:mediconnect/features/doctors/presentation/doctor_controller.dart';

void main() {
  group('Doctor Domain Models Tests', () {
    test('SpecializationModel deserializes and serializes correctly', () {
      final json = {
        'id': 'spec-1',
        'name': 'Cardiology',
        'description': 'Heart and vascular medicine',
        '_count': {'doctors': 5},
      };

      final model = SpecializationModel.fromJson(json);

      expect(model.id, 'spec-1');
      expect(model.name, 'Cardiology');
      expect(model.description, 'Heart and vascular medicine');
      expect(model.doctorCount, 5);

      final map = model.toJson();
      expect(map['name'], 'Cardiology');
      expect(map['doctorCount'], 5);
    });

    test('DoctorAvailabilityModel correctly maps dayOfWeek to dayName', () {
      final json = {
        'id': 'av-1',
        'doctorId': 'doc-1',
        'dayOfWeek': 1, // Monday
        'startTime': '09:00',
        'endTime': '17:00',
        'slotDurationMinutes': 30,
        'isActive': true,
      };

      final model = DoctorAvailabilityModel.fromJson(json);

      expect(model.dayOfWeek, 1);
      expect(model.dayName, 'Monday');
      expect(model.startTime, '09:00');
      expect(model.endTime, '17:00');
      expect(model.slotDurationMinutes, 30);
      expect(model.isActive, isTrue);
    });

    test('DoctorModel deserializes JSON with nested models and computed getters', () {
      final json = {
        'id': 'doc-1',
        'userId': 'user-doc-1',
        'fullName': 'Dr. Sarah Jenkins',
        'qualification': 'MBBS, MD',
        'licenseNumber': 'LIC-12345',
        'experienceYears': 12,
        'clinicName': 'City Heart Clinic',
        'clinicAddress': '123 Health Ave',
        'consultationFee': '75.00',
        'isVerified': true,
        'bio': 'Cardiology specialist',
        'specialization': {
          'id': 'spec-1',
          'name': 'Cardiology',
        },
        'availabilities': [
          {
            'id': 'av-1',
            'doctorId': 'doc-1',
            'dayOfWeek': 1,
            'startTime': '09:00',
            'endTime': '17:00',
          }
        ],
      };

      final doc = DoctorModel.fromJson(json);

      expect(doc.id, 'doc-1');
      expect(doc.fullName, 'Dr. Sarah Jenkins');
      expect(doc.specializationName, 'Cardiology');
      expect(doc.consultationFee, 75.0);
      expect(doc.isVerified, isTrue);
      expect(doc.availabilities.length, 1);
      expect(doc.availabilities.first.dayName, 'Monday');
    });

    test('DoctorSlotModel parses time slot availability correctly', () {
      final json = {
        'startTime': '09:00',
        'endTime': '09:30',
        'isAvailable': true,
      };

      final slot = DoctorSlotModel.fromJson(json);

      expect(slot.startTime, '09:00');
      expect(slot.endTime, '09:30');
      expect(slot.isAvailable, isTrue);
    });
  });

  group('DoctorDirectoryState Tests', () {
    test('default state and copyWith behavior', () {
      const state = DoctorDirectoryState();

      expect(state.isLoading, isFalse);
      expect(state.doctors, isEmpty);
      expect(state.specializations, isEmpty);
      expect(state.selectedSpecializationId, isNull);

      final updated = state.copyWith(
        isLoading: true,
        searchQuery: 'Jenkins',
      );

      expect(updated.isLoading, isTrue);
      expect(updated.searchQuery, 'Jenkins');
    });
  });
}
