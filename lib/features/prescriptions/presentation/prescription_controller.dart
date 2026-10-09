import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../medicines/presentation/medicine_controller.dart';
import '../data/prescription_repository.dart';
import '../domain/prescription_model.dart';

class PrescriptionState {
  final List<PrescriptionModel> prescriptions;
  final PrescriptionModel? selectedPrescription;
  final bool isLoading;
  final bool isIssuing;
  final String? errorMessage;
  final String? successMessage;

  const PrescriptionState({
    this.prescriptions = const [],
    this.selectedPrescription,
    this.isLoading = false,
    this.isIssuing = false,
    this.errorMessage,
    this.successMessage,
  });

  PrescriptionState copyWith({
    List<PrescriptionModel>? prescriptions,
    PrescriptionModel? selectedPrescription,
    bool? isLoading,
    bool? isIssuing,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return PrescriptionState(
      prescriptions: prescriptions ?? this.prescriptions,
      selectedPrescription: clearSelected ? null : (selectedPrescription ?? this.selectedPrescription),
      isLoading: isLoading ?? this.isLoading,
      isIssuing: isIssuing ?? this.isIssuing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class PrescriptionController extends Notifier<PrescriptionState> {
  late final PrescriptionRepository _repository;

  @override
  PrescriptionState build() {
    _repository = ref.watch(prescriptionRepositoryProvider);
    return PrescriptionState(
      prescriptions: _getFallbackPrescriptions(),
    );
  }

  Future<void> loadPrescriptions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getPrescriptions();
      state = state.copyWith(
        prescriptions: list.isNotEmpty ? list : state.prescriptions,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<PrescriptionModel?> loadPrescriptionDetails(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final item = await _repository.getPrescriptionById(id);
      state = state.copyWith(selectedPrescription: item, isLoading: false);
      return item;
    } catch (_) {
      // Find from cached state if available
      final match = state.prescriptions.where((p) => p.id == id).firstOrNull;
      state = state.copyWith(selectedPrescription: match, isLoading: false);
      return match;
    }
  }

  Future<PrescriptionModel?> loadPrescriptionForAppointment(String appointmentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final item = await _repository.getPrescriptionByAppointmentId(appointmentId);
      state = state.copyWith(selectedPrescription: item, isLoading: false);
      return item;
    } catch (_) {
      final match = state.prescriptions.where((p) => p.appointmentId == appointmentId).firstOrNull;
      state = state.copyWith(selectedPrescription: match, isLoading: false);
      return match;
    }
  }

  Future<bool> issuePrescription(Map<String, dynamic> payload) async {
    state = state.copyWith(isIssuing: true, clearError: true);
    try {
      final newRx = await _repository.issuePrescription(payload);
      state = state.copyWith(
        prescriptions: [newRx, ...state.prescriptions],
        selectedPrescription: newRx,
        isIssuing: false,
        successMessage: 'Digital prescription issued successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isIssuing: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Imports all prescribed medicines into MediTrack's active medicine schedules
  Future<int> importPrescriptionToMediTrack(PrescriptionModel prescription) async {
    int importedCount = 0;
    final now = DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    for (final med in prescription.medicines) {
      final endDate = now.add(Duration(days: med.durationDays));
      final endStr =
          "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final medPayload = {
        'name': med.medicineName,
        'dosage': med.dosage,
        'frequency': med.frequency,
        'instructions': med.instructions ?? 'Take as prescribed by ${prescription.doctorName}',
        'startDate': todayStr,
        'endDate': endStr,
        'reminderTimes': ['09:00', if (med.frequency.toLowerCase().contains('twice') || med.frequency.toLowerCase().contains('three')) '21:00'],
      };

      try {
        final success = await ref.read(medicineControllerProvider.notifier).createMedicine(medPayload);
        if (success) importedCount++;
      } catch (_) {}
    }

    state = state.copyWith(
      successMessage: 'Imported $importedCount medications to your MediTrack schedule!',
    );
    return importedCount;
  }

  List<PrescriptionModel> _getFallbackPrescriptions() {
    final now = DateTime.now();
    return [
      PrescriptionModel(
        id: 'rx-sample-1',
        appointmentId: 'appt-2',
        patientId: 'patient-current',
        doctorId: 'doc-2',
        doctorName: 'Dr. Marcus Vance',
        doctorSpecialization: 'Dermatology',
        qualification: 'MBBS, MD (Dermatology)',
        licenseNumber: 'MD-DERM-44109',
        clinicName: 'Skin & Glow Clinic',
        clinicAddress: '180 Broadway Medical Center',
        patientName: 'Alex Mercer',
        diagnosis: 'Atopic Contact Dermatitis & Allergic Urticaria',
        generalInstructions:
            'Avoid harsh soaps and chemical detergents. Keep skin hydrated with hypoallergenic moisturizer. Complete full course of antihistamines.',
        issuedAt: now.subtract(const Duration(days: 10)),
        medicines: const [
          PrescriptionMedicineModel(
            id: 'rx-med-1',
            medicineName: 'Cetirizine Hydrochloride',
            dosage: '10mg',
            frequency: 'Once daily at bedtime',
            durationDays: 14,
            instructions: 'Take with water after dinner',
          ),
          PrescriptionMedicineModel(
            id: 'rx-med-2',
            medicineName: 'Hydrocortisone 1% Topical Cream',
            dosage: 'Thin layer',
            frequency: 'Twice daily',
            durationDays: 7,
            instructions: 'Apply gently to affected rash areas only',
          ),
        ],
      ),
      PrescriptionModel(
        id: 'rx-sample-2',
        appointmentId: 'appt-old-1',
        patientId: 'patient-current',
        doctorId: 'doc-1',
        doctorName: 'Dr. Sarah Jenkins',
        doctorSpecialization: 'Cardiology',
        qualification: 'MBBS, MD (Cardiology)',
        licenseNumber: 'MD-CARD-88321',
        clinicName: 'City Heart Hospital',
        clinicAddress: '424 Health Park Blvd, Suite 300',
        patientName: 'Alex Mercer',
        diagnosis: 'Mild Hypertension (Stage 1) & Elevated Lipid Profile',
        generalInstructions:
            'Engage in 30 minutes of moderate aerobic activity daily. Limit sodium intake below 2,000mg per day. Maintain adherence to blood pressure monitoring.',
        issuedAt: now.subtract(const Duration(days: 45)),
        medicines: const [
          PrescriptionMedicineModel(
            id: 'rx-med-3',
            medicineName: 'Amlodipine Besylate',
            dosage: '5mg',
            frequency: 'Once daily in the morning',
            durationDays: 30,
            instructions: 'Take consistently every morning with breakfast',
          ),
          PrescriptionMedicineModel(
            id: 'rx-med-4',
            medicineName: 'Atorvastatin Calcium',
            dosage: '10mg',
            frequency: 'Once daily at bedtime',
            durationDays: 30,
            instructions: 'Take after dinner',
          ),
        ],
      ),
    ];
  }
}

final prescriptionControllerProvider =
    NotifierProvider<PrescriptionController, PrescriptionState>(
  PrescriptionController.new,
);
