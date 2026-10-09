import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/emergency_repository.dart';
import '../domain/emergency_model.dart';

class EmergencyState {
  final MedicalIdModel profile;
  final List<EmergencyContactModel> contacts;
  final List<FirstAidProtocolModel> protocols;
  final bool isLoading;
  final String? errorMessage;
  final String? statusNotice;

  const EmergencyState({
    required this.profile,
    required this.contacts,
    required this.protocols,
    this.isLoading = false,
    this.errorMessage,
    this.statusNotice,
  });

  EmergencyContactModel? get primaryContact {
    try {
      return contacts.firstWhere((c) => c.isPrimary);
    } catch (_) {
      return contacts.isNotEmpty ? contacts.first : null;
    }
  }

  EmergencyState copyWith({
    MedicalIdModel? profile,
    List<EmergencyContactModel>? contacts,
    List<FirstAidProtocolModel>? protocols,
    bool? isLoading,
    String? errorMessage,
    String? statusNotice,
  }) {
    return EmergencyState(
      profile: profile ?? this.profile,
      contacts: contacts ?? this.contacts,
      protocols: protocols ?? this.protocols,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusNotice: statusNotice,
    );
  }
}

class EmergencyController extends Notifier<EmergencyState> {
  @override
  EmergencyState build() {
    final fallbackContacts = [
      EmergencyContactModel(
        id: 'cnt-1',
        name: 'Sarah Mercer',
        relationship: 'Spouse',
        phone: '+1 555-019-2834',
        isPrimary: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      EmergencyContactModel(
        id: 'cnt-2',
        name: 'Robert Mercer',
        relationship: 'Father',
        phone: '+1 555-014-9921',
        isPrimary: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      EmergencyContactModel(
        id: 'cnt-3',
        name: 'Dr. Sarah Jenkins',
        relationship: 'Primary Cardiologist',
        phone: '+1 555-018-7712',
        isPrimary: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    final fallbackProfile = MedicalIdModel(
      id: 'patient-ice-001',
      fullName: 'John Doe',
      bloodGroup: 'O+',
      allergies: 'Penicillin, Peanuts, Sulfa Drugs',
      chronicDiseases: 'Mild Asthma, Type 2 Diabetes',
      emergencyContacts: fallbackContacts,
    );

    Future.microtask(() => loadEmergencyData());

    return EmergencyState(
      profile: fallbackProfile,
      contacts: fallbackContacts,
      protocols: FirstAidProtocolModel.standardProtocols,
    );
  }

  Future<void> loadEmergencyData() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final profile = await repo.getEmergencyProfile();
      final contacts = await repo.getContacts();

      state = state.copyWith(
        isLoading: false,
        profile: profile,
        contacts: contacts.isNotEmpty ? contacts : profile.emergencyContacts,
      );
    } catch (_) {
      // Offline fallback preserved
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateMedicalProfile({
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final updated = await repo.updateMedicalProfile(
        bloodGroup: bloodGroup,
        allergies: allergies,
        chronicDiseases: chronicDiseases,
      );
      state = state.copyWith(
        isLoading: false,
        profile: updated,
        statusNotice: 'Medical ID updated successfully.',
      );
    } catch (_) {
      // Optimistic local update
      final current = state.profile;
      final localUpdated = current.copyWith(
        bloodGroup: bloodGroup ?? current.bloodGroup,
        allergies: allergies ?? current.allergies,
        chronicDiseases: chronicDiseases ?? current.chronicDiseases,
      );
      state = state.copyWith(
        isLoading: false,
        profile: localUpdated,
        statusNotice: 'Medical ID updated locally (offline mode).',
      );
    }
  }

  Future<void> addEmergencyContact({
    required String name,
    required String relationship,
    required String phone,
    bool isPrimary = false,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final newContact = await repo.addContact(
        name: name,
        relationship: relationship,
        phone: phone,
        isPrimary: isPrimary,
      );

      var updatedList = List<EmergencyContactModel>.from(state.contacts);
      if (isPrimary) {
        updatedList = updatedList.map((c) => c.copyWith(isPrimary: false)).toList();
      }
      updatedList.add(newContact);

      state = state.copyWith(
        isLoading: false,
        contacts: updatedList,
        statusNotice: 'Emergency contact added.',
      );
    } catch (_) {
      final newContact = EmergencyContactModel(
        id: 'cnt-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        relationship: relationship,
        phone: phone,
        isPrimary: isPrimary,
        createdAt: DateTime.now(),
      );

      var updatedList = List<EmergencyContactModel>.from(state.contacts);
      if (isPrimary) {
        updatedList = updatedList.map((c) => c.copyWith(isPrimary: false)).toList();
      }
      updatedList.add(newContact);

      state = state.copyWith(
        isLoading: false,
        contacts: updatedList,
        statusNotice: 'Contact added locally (offline mode).',
      );
    }
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      await repo.deleteContact(contactId);

      final updatedList = state.contacts.where((c) => c.id != contactId).toList();
      state = state.copyWith(
        isLoading: false,
        contacts: updatedList,
        statusNotice: 'Emergency contact removed.',
      );
    } catch (_) {
      final updatedList = state.contacts.where((c) => c.id != contactId).toList();
      state = state.copyWith(
        isLoading: false,
        contacts: updatedList,
        statusNotice: 'Contact removed locally.',
      );
    }
  }

  Future<void> setPrimaryContact(String contactId) async {
    final target = state.contacts.firstWhere((c) => c.id == contactId);
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      await repo.updateContact(
        contactId: contactId,
        isPrimary: true,
      );

      final updated = state.contacts.map((c) {
        return c.copyWith(isPrimary: c.id == contactId);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        contacts: updated,
        statusNotice: '${target.name} set as primary emergency contact.',
      );
    } catch (_) {
      final updated = state.contacts.map((c) {
        return c.copyWith(isPrimary: c.id == contactId);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        contacts: updated,
        statusNotice: '${target.name} set as primary contact.',
      );
    }
  }

  void clearNotice() {
    state = state.copyWith(statusNotice: null, errorMessage: null);
  }
}

final emergencyControllerProvider =
    NotifierProvider<EmergencyController, EmergencyState>(() {
  return EmergencyController();
});
