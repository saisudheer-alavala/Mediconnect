import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/appointments/data/appointment_repository.dart';
import 'package:mediconnect/features/appointments/domain/appointment_model.dart';
import 'package:mediconnect/features/appointments/presentation/appointment_controller.dart';

class _FakeAppointmentRepository extends AppointmentRepository {
  _FakeAppointmentRepository()
      : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<AppointmentModel>> getAppointments({String? status, bool? upcomingOnly}) async {
    return [
      AppointmentModel(
        id: 'appt-mock-1',
        patientId: 'p-1',
        doctorId: 'd-1',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        startTime: '10:00',
        endTime: '10:30',
        status: 'CONFIRMED',
        doctorName: 'Dr. Jane Smith',
        specializationName: 'Cardiology',
        clinicName: 'Metro Heart Center',
        consultationFee: 80.0,
      ),
    ];
  }

  @override
  Future<AppointmentModel> bookAppointment(Map<String, dynamic> data) async {
    return AppointmentModel(
      id: 'appt-new-1',
      patientId: 'p-1',
      doctorId: data['doctorId'] as String,
      appointmentDate: DateTime.parse(data['appointmentDate'] as String),
      startTime: data['startTime'] as String,
      endTime: '10:30',
      status: 'CONFIRMED',
      doctorName: 'Dr. John Watson',
      specializationName: 'General Practice',
      clinicName: 'Baker Clinic',
      consultationFee: 70.0,
      patientNotes: data['patientNotes'] as String?,
    );
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id, {String? reason}) async {
    return AppointmentModel(
      id: id,
      patientId: 'p-1',
      doctorId: 'd-1',
      appointmentDate: DateTime.now(),
      startTime: '10:00',
      endTime: '10:30',
      status: 'CANCELLED',
      cancellationReason: reason,
      doctorName: 'Dr. Cancelled',
      specializationName: 'Specialist',
      clinicName: 'Clinic',
    );
  }
}

void main() {
  group('AppointmentModel Tests', () {
    test('fromJson parses nested doctor and patient objects correctly', () {
      final json = {
        'id': 'appt-100',
        'patientId': 'pat-10',
        'doctorId': 'doc-20',
        'appointmentDate': '2026-10-15T09:00:00.000Z',
        'startTime': '09:30',
        'endTime': '10:00',
        'status': 'CONFIRMED',
        'patientNotes': 'Mild chest ache',
        'doctor': {
          'fullName': 'Dr. Alice Morgan',
          'clinicName': 'Hope Medical Clinic',
          'clinicAddress': '123 Health Way',
          'consultationFee': 85.0,
          'specialization': {'name': 'Cardiology'},
        },
        'patient': {
          'fullName': 'John Doe',
        },
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'appt-100');
      expect(model.patientId, 'pat-10');
      expect(model.doctorId, 'doc-20');
      expect(model.startTime, '09:30');
      expect(model.endTime, '10:00');
      expect(model.status, 'CONFIRMED');
      expect(model.isUpcoming, isTrue);
      expect(model.isConfirmed, isTrue);
      expect(model.isCompleted, isFalse);
      expect(model.isCancelled, isFalse);
      expect(model.doctorName, 'Dr. Alice Morgan');
      expect(model.clinicName, 'Hope Medical Clinic');
      expect(model.clinicAddress, '123 Health Way');
      expect(model.specializationName, 'Cardiology');
      expect(model.consultationFee, 85.0);
      expect(model.patientName, 'John Doe');
      expect(model.patientNotes, 'Mild chest ache');
      expect(model.formattedDate, contains('2026'));
      expect(model.formattedTimeSlot, contains('9:30'));
    });

    test('toJson produces expected structure and copyWith modifies status', () {
      final model = AppointmentModel(
        id: 'appt-1',
        patientId: 'p-1',
        doctorId: 'd-1',
        appointmentDate: DateTime(2026, 11, 20),
        startTime: '14:00',
        endTime: '14:30',
        status: 'PENDING',
        doctorName: 'Dr. Test',
        specializationName: 'Pediatrics',
        clinicName: 'Children Hospital',
        consultationFee: 65.0,
      );

      final json = model.toJson();
      expect(json['id'], 'appt-1');
      expect(json['status'], 'PENDING');
      expect(json['doctorName'], 'Dr. Test');

      final cancelled = model.copyWith(
        status: 'CANCELLED',
        cancellationReason: 'Doctor unavailable',
      );
      expect(cancelled.status, 'CANCELLED');
      expect(cancelled.cancellationReason, 'Doctor unavailable');
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.isUpcoming, isFalse);
    });
  });

  group('AppointmentController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          appointmentRepositoryProvider.overrideWithValue(_FakeAppointmentRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state contains default offline appointments', () {
      final state = container.read(appointmentControllerProvider);

      expect(state.appointments.isNotEmpty, isTrue);
      expect(state.upcomingAppointments.isNotEmpty, isTrue);
      expect(state.completedAppointments.isNotEmpty, isTrue);
      expect(state.cancelledAppointments.isNotEmpty, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isBooking, isFalse);
    });

    test('bookAppointment adds new appointment to the top of list', () async {
      final controller = container.read(appointmentControllerProvider.notifier);

      final success = await controller.bookAppointment(
        doctorId: 'doc-booked-1',
        date: DateTime(2026, 10, 25),
        startTime: '10:00',
        patientNotes: 'Checkup',
      );

      expect(success, isTrue);
      final state = container.read(appointmentControllerProvider);
      expect(state.appointments.first.id, 'appt-new-1');
      expect(state.appointments.first.doctorName, 'Dr. John Watson');
      expect(state.successMessage, contains('Appointment booked successfully'));
      expect(state.isBooking, isFalse);
    });

    test('cancelAppointment updates appointment status to CANCELLED in list', () async {
      final controller = container.read(appointmentControllerProvider.notifier);
      final initialState = container.read(appointmentControllerProvider);
      final upcomingId = initialState.upcomingAppointments.first.id;

      final success = await controller.cancelAppointment(
        upcomingId,
        reason: 'Personal conflict',
      );

      expect(success, isTrue);
      final updatedState = container.read(appointmentControllerProvider);
      final cancelledItem = updatedState.appointments.firstWhere((a) => a.id == upcomingId);
      expect(cancelledItem.status, 'CANCELLED');
      expect(cancelledItem.cancellationReason, 'Personal conflict');
      expect(cancelledItem.isCancelled, isTrue);
    });
  });
}
