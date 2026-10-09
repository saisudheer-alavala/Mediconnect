import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/appointments/data/appointment_repository.dart';
import 'package:mediconnect/features/appointments/domain/appointment_model.dart';
import 'package:mediconnect/features/appointments/presentation/appointment_list_screen.dart';
import 'package:mediconnect/features/appointments/presentation/book_appointment_screen.dart';
import 'package:mediconnect/features/doctors/data/doctor_repository.dart';
import 'package:mediconnect/features/doctors/domain/doctor_model.dart';

const _sampleDoctor = DoctorModel(
  id: 'doc-widget-1',
  userId: 'u-1',
  fullName: 'Dr. Sarah Jenkins',
  qualification: 'MBBS, MD (Cardiology)',
  licenseNumber: 'MD-CARD-88321',
  experienceYears: 12,
  clinicName: 'City Heart Hospital',
  clinicAddress: '424 Health Park Blvd, Suite 300',
  consultationFee: 75.0,
  isVerified: true,
  bio: 'Senior consultant cardiologist.',
  specialization: SpecializationModel(id: 'spec-cardio', name: 'Cardiology'),
);

class _FakeDoctorRepository extends DoctorRepository {
  _FakeDoctorRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<DoctorSlotModel>> getAvailableSlots(String doctorId, String date) async {
    return const [
      DoctorSlotModel(startTime: '09:00', endTime: '09:30', isAvailable: true),
      DoctorSlotModel(startTime: '09:30', endTime: '10:00', isAvailable: false),
      DoctorSlotModel(startTime: '10:00', endTime: '10:30', isAvailable: true),
    ];
  }
}

class _FakeAppointmentRepository extends AppointmentRepository {
  _FakeAppointmentRepository() : super(client: ApiClient(storage: SecureStorageService()));

  @override
  Future<List<AppointmentModel>> getAppointments({String? status, bool? upcomingOnly}) async {
    return [
      AppointmentModel(
        id: 'appt-1',
        patientId: 'patient-current',
        doctorId: 'doc-1',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        startTime: '10:30',
        endTime: '11:00',
        status: 'CONFIRMED',
        doctorName: 'Dr. Sarah Jenkins',
        specializationName: 'Cardiology',
        clinicName: 'City Heart Hospital',
        clinicAddress: '424 Health Park Blvd, Suite 300',
        consultationFee: 75.0,
        patientNotes: 'Annual check-up and blood pressure monitoring',
      ),
      AppointmentModel(
        id: 'appt-2',
        patientId: 'patient-current',
        doctorId: 'doc-2',
        appointmentDate: DateTime.now().subtract(const Duration(days: 10)),
        startTime: '14:00',
        endTime: '14:30',
        status: 'COMPLETED',
        doctorName: 'Dr. Marcus Vance',
        specializationName: 'Dermatology',
        clinicName: 'Skin & Glow Clinic',
        clinicAddress: '180 Broadway Medical Center',
        consultationFee: 60.0,
      ),
      AppointmentModel(
        id: 'appt-3',
        patientId: 'patient-current',
        doctorId: 'doc-4',
        appointmentDate: DateTime.now().subtract(const Duration(days: 25)),
        startTime: '11:30',
        endTime: '12:00',
        status: 'CANCELLED',
        cancellationReason: 'Rescheduled due to travel conflict',
        doctorName: 'Dr. Robert Hayes',
        specializationName: 'Neurology',
        clinicName: 'Neuro Healthcare Center',
        clinicAddress: '55 University Avenue',
        consultationFee: 90.0,
      ),
    ];
  }

  @override
  Future<AppointmentModel> bookAppointment(Map<String, dynamic> data) async {
    return AppointmentModel(
      id: 'appt-new-99',
      patientId: 'patient-current',
      doctorId: data['doctorId'] as String,
      appointmentDate: DateTime.parse(data['appointmentDate'] as String),
      startTime: data['startTime'] as String,
      endTime: '10:30',
      status: 'CONFIRMED',
      doctorName: _sampleDoctor.fullName,
      specializationName: _sampleDoctor.specializationName,
      clinicName: _sampleDoctor.clinicName,
      consultationFee: _sampleDoctor.consultationFee,
      patientNotes: data['patientNotes'] as String?,
    );
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id, {String? reason}) async {
    return AppointmentModel(
      id: id,
      patientId: 'patient-current',
      doctorId: 'doc-1',
      appointmentDate: DateTime.now(),
      startTime: '10:30',
      endTime: '11:00',
      status: 'CANCELLED',
      cancellationReason: reason,
      doctorName: 'Dr. Sarah Jenkins',
      specializationName: 'Cardiology',
      clinicName: 'City Heart Hospital',
      consultationFee: 75.0,
    );
  }
}

void main() {
  group('AppointmentListScreen Widget Tests', () {
    testWidgets('renders tabs, appointments list, and handles cancellation dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appointmentRepositoryProvider.overrideWithValue(_FakeAppointmentRepository()),
          ],
          child: const MaterialApp(
            home: AppointmentListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('My Appointments'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);

      // Check informational disclaimer banner
      expect(find.textContaining('Informational Tool: MediCare Connect'), findsOneWidget);

      // Check upcoming appointment card
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      expect(find.text('City Heart Hospital'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);

      // Tap Cancel button to trigger cancellation modal dialog
      final cancelButton = find.byKey(const Key('cancel_appointment_appt-1'));
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Check cancellation dialog content
      expect(find.text('Cancel Appointment'), findsOneWidget);
      expect(find.text('Keep Appointment'), findsOneWidget);
      expect(find.text('Confirm Cancel'), findsOneWidget);

      // Confirm cancellation
      await tester.tap(find.text('Confirm Cancel'));
      await tester.pumpAndSettle();

      // Switch to Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Marcus Vance'), findsOneWidget);
      expect(find.text('Skin & Glow Clinic'), findsOneWidget);

      // Switch to Cancelled tab
      await tester.tap(find.text('Cancelled'));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Robert Hayes'), findsOneWidget);
      expect(find.textContaining('Rescheduled due to travel conflict'), findsOneWidget);
    });
  });

  group('BookAppointmentScreen Widget Tests', () {
    testWidgets('renders doctor info, allows slot selection and confirms booking', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            doctorRepositoryProvider.overrideWithValue(_FakeDoctorRepository()),
            appointmentRepositoryProvider.overrideWithValue(_FakeAppointmentRepository()),
          ],
          child: const MaterialApp(
            home: BookAppointmentScreen(doctor: _sampleDoctor),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Doctor details header
      expect(find.text('Book Appointment'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins'), findsWidgets);
      expect(find.text('Cardiology'), findsWidgets);
      expect(find.text('City Heart Hospital'), findsWidgets);
      expect(find.text('\$75'), findsWidgets);

      // Available slots rendered from fake repo
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);

      // Tap a slot chip
      final slotChip = find.byKey(const Key('slot_chip_10_00'));
      expect(slotChip, findsOneWidget);
      await tester.tap(slotChip);
      await tester.pumpAndSettle();

      // Check selected slot in overview
      expect(find.text('Selected: 10:00'), findsOneWidget);
      expect(find.text('10:00 - 10:30'), findsOneWidget);

      // Enter symptoms / notes
      final notesInput = find.byKey(const Key('patient_notes_input'));
      expect(notesInput, findsOneWidget);
      await tester.enterText(notesInput, 'Routine blood pressure review');
      await tester.pumpAndSettle();

      // Informational medical boundary notice
      expect(find.textContaining('Informational Boundary: MediCare Connect'), findsOneWidget);

      // Tap Confirm Booking button
      final confirmBtn = find.byKey(const Key('confirm_booking_button'));
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Verifies successful booking feedback
      expect(find.textContaining('Appointment booked successfully with Dr. Sarah Jenkins!'), findsOneWidget);
    });
  });
}
