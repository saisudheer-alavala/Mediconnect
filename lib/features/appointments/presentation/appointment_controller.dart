import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appointment_repository.dart';
import '../domain/appointment_model.dart';

class AppointmentState {
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final bool isBooking;
  final String? errorMessage;
  final String? successMessage;

  const AppointmentState({
    this.appointments = const [],
    this.isLoading = false,
    this.isBooking = false,
    this.errorMessage,
    this.successMessage,
  });

  List<AppointmentModel> get upcomingAppointments =>
      appointments.where((a) => a.isUpcoming).toList();

  List<AppointmentModel> get completedAppointments =>
      appointments.where((a) => a.isCompleted).toList();

  List<AppointmentModel> get cancelledAppointments =>
      appointments.where((a) => a.isCancelled).toList();

  AppointmentState copyWith({
    List<AppointmentModel>? appointments,
    bool? isLoading,
    bool? isBooking,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      isBooking: isBooking ?? this.isBooking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AppointmentController extends Notifier<AppointmentState> {
  late final AppointmentRepository _repository;

  @override
  AppointmentState build() {
    _repository = ref.watch(appointmentRepositoryProvider);
    // Initial state with sample appointments for offline / zero-latency experience
    return AppointmentState(
      appointments: _getFallbackAppointments(),
    );
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final appts = await _repository.getAppointments();
      state = state.copyWith(
        appointments: appts.isNotEmpty ? appts : state.appointments,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required DateTime date,
    required String startTime,
    String? patientNotes,
  }) async {
    state = state.copyWith(isBooking: true, clearError: true);
    try {
      final dateStr =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final payload = {
        'doctorId': doctorId,
        'appointmentDate': dateStr,
        'startTime': startTime,
        if (patientNotes != null && patientNotes.isNotEmpty) 'patientNotes': patientNotes,
      };

      final newAppt = await _repository.bookAppointment(payload);
      state = state.copyWith(
        appointments: [newAppt, ...state.appointments],
        isBooking: false,
        successMessage: 'Appointment booked successfully with ${newAppt.doctorName}!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBooking: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelAppointment(String id, {String? reason}) async {
    try {
      await _repository.cancelAppointment(id, reason: reason);
      final updatedList = state.appointments.map((a) {
        if (a.id == id) {
          return a.copyWith(status: 'CANCELLED', cancellationReason: reason);
        }
        return a;
      }).toList();

      state = state.copyWith(
        appointments: updatedList,
        successMessage: 'Appointment cancelled.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(String id, String newStatus, {String? reason}) async {
    try {
      if (newStatus == 'CANCELLED') {
        await _repository.cancelAppointment(id, reason: reason);
      } else {
        await _repository.updateStatus(id, newStatus);
      }
      final updatedList = state.appointments.map((a) {
        if (a.id == id) {
          return a.copyWith(status: newStatus, cancellationReason: reason);
        }
        return a;
      }).toList();

      state = state.copyWith(
        appointments: updatedList,
        successMessage: 'Appointment status updated to $newStatus.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  List<AppointmentModel> _getFallbackAppointments() {
    final now = DateTime.now();
    return [
      AppointmentModel(
        id: 'appt-1',
        patientId: 'patient-current',
        doctorId: 'doc-1',
        appointmentDate: now.add(const Duration(days: 1)),
        startTime: '10:30',
        endTime: '11:00',
        status: 'CONFIRMED',
        doctorName: 'Dr. Sarah Jenkins',
        specializationName: 'Cardiology',
        clinicName: 'City Heart Hospital',
        clinicAddress: '424 Health Park Blvd, Suite 300',
        consultationFee: 75.0,
        patientName: 'Michael Chang',
        patientPhone: '+1 (555) 321-7654',
        patientGender: 'MALE',
        patientDob: '1982-04-12',
        patientBloodGroup: 'O+',
        patientAllergies: 'Penicillin',
        patientChronicDiseases: 'Hypertension, Regular BP checks',
        patientNotes: 'Annual check-up and blood pressure monitoring',
      ),
      AppointmentModel(
        id: 'appt-2',
        patientId: 'patient-current',
        doctorId: 'doc-2',
        appointmentDate: now.subtract(const Duration(days: 10)),
        startTime: '14:00',
        endTime: '14:30',
        status: 'COMPLETED',
        doctorName: 'Dr. Marcus Vance',
        specializationName: 'Dermatology',
        clinicName: 'Skin & Glow Clinic',
        clinicAddress: '180 Broadway Medical Center',
        consultationFee: 60.0,
        patientName: 'Emma Watson',
        patientPhone: '+1 (555) 789-0123',
        patientGender: 'FEMALE',
        patientDob: '1990-07-25',
        patientBloodGroup: 'A+',
        patientAllergies: 'None',
        patientChronicDiseases: 'Eczema flare-up',
        patientNotes: 'Skin irritation and routine allergy test',
      ),
      AppointmentModel(
        id: 'appt-3',
        patientId: 'patient-current',
        doctorId: 'doc-4',
        appointmentDate: now.subtract(const Duration(days: 25)),
        startTime: '11:30',
        endTime: '12:00',
        status: 'CANCELLED',
        cancellationReason: 'Rescheduled due to travel conflict',
        doctorName: 'Dr. Robert Hayes',
        specializationName: 'Neurology',
        clinicName: 'Neuro Healthcare Center',
        clinicAddress: '55 University Avenue',
        consultationFee: 90.0,
        patientName: 'David Miller',
        patientPhone: '+1 (555) 456-7890',
        patientGender: 'MALE',
        patientDob: '1975-11-03',
        patientBloodGroup: 'B+',
        patientNotes: 'Migraine assessment follow-up',
      ),
    ];
  }
}

final appointmentControllerProvider =
    NotifierProvider<AppointmentController, AppointmentState>(
  AppointmentController.new,
);
