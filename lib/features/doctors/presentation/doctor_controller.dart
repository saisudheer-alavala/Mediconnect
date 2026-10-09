import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/doctor_repository.dart';
import '../domain/doctor_model.dart';

class DoctorDirectoryState {
  final List<DoctorModel> doctors;
  final List<SpecializationModel> specializations;
  final String? selectedSpecializationId;
  final String searchQuery;
  final bool isLoading;
  final DoctorModel? selectedDoctor;
  final List<DoctorSlotModel> availableSlots;
  final String? errorMessage;

  const DoctorDirectoryState({
    this.doctors = const [],
    this.specializations = const [],
    this.selectedSpecializationId,
    this.searchQuery = '',
    this.isLoading = false,
    this.selectedDoctor,
    this.availableSlots = const [],
    this.errorMessage,
  });

  DoctorDirectoryState copyWith({
    List<DoctorModel>? doctors,
    List<SpecializationModel>? specializations,
    String? selectedSpecializationId,
    String? searchQuery,
    bool? isLoading,
    DoctorModel? selectedDoctor,
    List<DoctorSlotModel>? availableSlots,
    String? errorMessage,
    bool clearSpecialization = false,
    bool clearError = false,
  }) {
    return DoctorDirectoryState(
      doctors: doctors ?? this.doctors,
      specializations: specializations ?? this.specializations,
      selectedSpecializationId: clearSpecialization
          ? null
          : (selectedSpecializationId ?? this.selectedSpecializationId),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      availableSlots: availableSlots ?? this.availableSlots,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DoctorDirectoryController extends Notifier<DoctorDirectoryState> {
  late final DoctorRepository _repository;

  @override
  DoctorDirectoryState build() {
    _repository = ref.watch(doctorRepositoryProvider);
    // Initial state populated with fallback for zero-latency offline viewing
    return DoctorDirectoryState(
      specializations: _getFallbackSpecializations(),
      doctors: _getFallbackDoctors(),
    );
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final specs = await _repository.getSpecializations();
      final docs = await _repository.getDoctors(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        specializationId: state.selectedSpecializationId,
      );
      state = state.copyWith(
        specializations: specs.isNotEmpty ? specs : state.specializations,
        doctors: docs.isNotEmpty ? docs : state.doctors,
        isLoading: false,
      );
    } catch (_) {
      // In offline/demo mode, preserve fallback
      state = state.copyWith(isLoading: false);
    }
  }

  void filterBySpecialization(String? specializationId) {
    if (state.selectedSpecializationId == specializationId) {
      state = state.copyWith(clearSpecialization: true);
    } else {
      state = state.copyWith(selectedSpecializationId: specializationId);
    }
    _applyLocalFilter();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyLocalFilter();
  }

  void _applyLocalFilter() {
    final all = _getFallbackDoctors();
    final query = state.searchQuery.toLowerCase().trim();
    final specId = state.selectedSpecializationId;

    final filtered = all.where((d) {
      final matchesQuery = query.isEmpty ||
          d.fullName.toLowerCase().contains(query) ||
          d.clinicName.toLowerCase().contains(query) ||
          d.specializationName.toLowerCase().contains(query);

      final matchesSpec = specId == null ||
          d.specialization?.id == specId ||
          d.specializationName.toLowerCase() == specId.toLowerCase();

      return matchesQuery && matchesSpec;
    }).toList();

    state = state.copyWith(doctors: filtered);
  }

  Future<void> loadDoctorDetails(String id) async {
    final cached = state.doctors.where((d) => d.id == id).firstOrNull;
    if (cached != null) {
      state = state.copyWith(selectedDoctor: cached);
    }

    try {
      final doc = await _repository.getDoctorById(id);
      state = state.copyWith(selectedDoctor: doc);
    } catch (_) {
      // Keep cached if network fails
    }
  }

  Future<void> loadAvailableSlots(String doctorId, String date) async {
    try {
      final slots = await _repository.getAvailableSlots(doctorId, date);
      state = state.copyWith(availableSlots: slots);
    } catch (_) {
      // Fallback demo slots
      state = state.copyWith(
        availableSlots: const [
          DoctorSlotModel(startTime: '09:00', endTime: '09:30', isAvailable: true),
          DoctorSlotModel(startTime: '09:30', endTime: '10:00', isAvailable: true),
          DoctorSlotModel(startTime: '10:00', endTime: '10:30', isAvailable: false),
          DoctorSlotModel(startTime: '10:30', endTime: '11:00', isAvailable: true),
          DoctorSlotModel(startTime: '11:00', endTime: '11:30', isAvailable: true),
          DoctorSlotModel(startTime: '14:00', endTime: '14:30', isAvailable: true),
          DoctorSlotModel(startTime: '14:30', endTime: '15:00', isAvailable: true),
        ],
      );
    }
  }

  List<SpecializationModel> _getFallbackSpecializations() {
    return const [
      SpecializationModel(id: 'spec-cardio', name: 'Cardiology', doctorCount: 4),
      SpecializationModel(id: 'spec-derm', name: 'Dermatology', doctorCount: 6),
      SpecializationModel(id: 'spec-ped', name: 'Pediatrics', doctorCount: 5),
      SpecializationModel(id: 'spec-gen', name: 'General Medicine', doctorCount: 8),
      SpecializationModel(id: 'spec-neuro', name: 'Neurology', doctorCount: 3),
      SpecializationModel(id: 'spec-ortho', name: 'Orthopedics', doctorCount: 4),
    ];
  }

  List<DoctorModel> _getFallbackDoctors() {
    return [
      const DoctorModel(
        id: 'doc-1',
        userId: 'u-doc-1',
        fullName: 'Dr. Sarah Jenkins',
        qualification: 'MBBS, MD (Cardiology)',
        licenseNumber: 'MD-CARD-88321',
        experienceYears: 12,
        clinicName: 'City Heart Hospital',
        clinicAddress: '424 Health Park Blvd, Suite 300',
        consultationFee: 75.0,
        isVerified: true,
        bio: 'Senior consultant cardiologist specializing in preventative cardiology, hypertension, and advanced heart health management.',
        specialization: SpecializationModel(id: 'spec-cardio', name: 'Cardiology'),
        availabilities: [
          DoctorAvailabilityModel(id: 'av-1', doctorId: 'doc-1', dayOfWeek: 1, startTime: '09:00', endTime: '17:00'),
          DoctorAvailabilityModel(id: 'av-2', doctorId: 'doc-1', dayOfWeek: 2, startTime: '09:00', endTime: '17:00'),
          DoctorAvailabilityModel(id: 'av-3', doctorId: 'doc-1', dayOfWeek: 3, startTime: '09:00', endTime: '17:00'),
          DoctorAvailabilityModel(id: 'av-4', doctorId: 'doc-1', dayOfWeek: 4, startTime: '09:00', endTime: '17:00'),
          DoctorAvailabilityModel(id: 'av-5', doctorId: 'doc-1', dayOfWeek: 5, startTime: '09:00', endTime: '14:00'),
        ],
      ),
      const DoctorModel(
        id: 'doc-2',
        userId: 'u-doc-2',
        fullName: 'Dr. Marcus Vance',
        qualification: 'MBBS, MD (Dermatology)',
        licenseNumber: 'MD-DERM-44102',
        experienceYears: 8,
        clinicName: 'Skin & Glow Clinic',
        clinicAddress: '180 Broadway Medical Center',
        consultationFee: 60.0,
        isVerified: true,
        bio: 'Board-certified dermatologist experienced in clinical skin treatments, eczema, acne, and allergy patch diagnostics.',
        specialization: SpecializationModel(id: 'spec-derm', name: 'Dermatology'),
        availabilities: [
          DoctorAvailabilityModel(id: 'av-6', doctorId: 'doc-2', dayOfWeek: 1, startTime: '10:00', endTime: '18:00'),
          DoctorAvailabilityModel(id: 'av-7', doctorId: 'doc-2', dayOfWeek: 3, startTime: '10:00', endTime: '18:00'),
          DoctorAvailabilityModel(id: 'av-8', doctorId: 'doc-2', dayOfWeek: 5, startTime: '10:00', endTime: '18:00'),
        ],
      ),
      const DoctorModel(
        id: 'doc-3',
        userId: 'u-doc-3',
        fullName: 'Dr. Emily Chen',
        qualification: 'MBBS, DCH, DNB (Pediatrics)',
        licenseNumber: 'MD-PED-99014',
        experienceYears: 10,
        clinicName: 'Children Care Hospital',
        clinicAddress: '12 Sunshine Way, Pediatric Wing',
        consultationFee: 65.0,
        isVerified: true,
        bio: 'Dedicated pediatrician providing comprehensive infant and child healthcare, developmental screenings, and vaccination plans.',
        specialization: SpecializationModel(id: 'spec-ped', name: 'Pediatrics'),
        availabilities: [
          DoctorAvailabilityModel(id: 'av-9', doctorId: 'doc-3', dayOfWeek: 2, startTime: '08:30', endTime: '16:00'),
          DoctorAvailabilityModel(id: 'av-10', doctorId: 'doc-3', dayOfWeek: 4, startTime: '08:30', endTime: '16:00'),
          DoctorAvailabilityModel(id: 'av-11', doctorId: 'doc-3', dayOfWeek: 6, startTime: '09:00', endTime: '13:00'),
        ],
      ),
      const DoctorModel(
        id: 'doc-4',
        userId: 'u-doc-4',
        fullName: 'Dr. Robert Hayes',
        qualification: 'MBBS, MD, DM (Neurology)',
        licenseNumber: 'MD-NEUR-77215',
        experienceYears: 15,
        clinicName: 'Neuro Healthcare Center',
        clinicAddress: '55 University Avenue, Suite 10',
        consultationFee: 90.0,
        isVerified: true,
        bio: 'Consultant neurologist with 15+ years experience treating migraines, neuropathies, epilepsy, and neurological disorders.',
        specialization: SpecializationModel(id: 'spec-neuro', name: 'Neurology'),
        availabilities: [
          DoctorAvailabilityModel(id: 'av-12', doctorId: 'doc-4', dayOfWeek: 1, startTime: '11:00', endTime: '17:00'),
          DoctorAvailabilityModel(id: 'av-13', doctorId: 'doc-4', dayOfWeek: 4, startTime: '11:00', endTime: '17:00'),
        ],
      ),
    ];
  }
}

final doctorDirectoryControllerProvider =
    NotifierProvider<DoctorDirectoryController, DoctorDirectoryState>(
  DoctorDirectoryController.new,
);
