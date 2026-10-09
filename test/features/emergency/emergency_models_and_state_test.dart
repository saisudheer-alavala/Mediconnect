import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';
import 'package:mediconnect/features/emergency/data/emergency_repository.dart';
import 'package:mediconnect/features/emergency/domain/emergency_model.dart';
import 'package:mediconnect/features/emergency/presentation/emergency_controller.dart';

class _FakeEmergencyRepository extends EmergencyRepository {
  _FakeEmergencyRepository() : super(client: ApiClient(storage: SecureStorageService()));

  MedicalIdModel _profile = const MedicalIdModel(
    id: 'patient-test-id',
    fullName: 'Johnathan Mercer',
    bloodGroup: 'AB+',
    allergies: 'Latex, Aspirin',
    chronicDiseases: 'Hypertension',
  );

  final List<EmergencyContactModel> _contacts = [
    const EmergencyContactModel(
      id: 'contact-test-1',
      name: 'Sarah Mercer',
      relationship: 'Spouse',
      phone: '+1 555-019-2834',
      isPrimary: true,
    ),
    const EmergencyContactModel(
      id: 'contact-test-2',
      name: 'Robert Mercer',
      relationship: 'Father',
      phone: '+1 555-014-9921',
      isPrimary: false,
    ),
  ];

  @override
  Future<MedicalIdModel> getEmergencyProfile() async => _profile.copyWith(emergencyContacts: _contacts);

  @override
  Future<List<EmergencyContactModel>> getContacts() async => List.from(_contacts);

  @override
  Future<EmergencyContactModel> addContact({
    required String name,
    required String relationship,
    required String phone,
    bool isPrimary = false,
  }) async {
    final c = EmergencyContactModel(
      id: 'contact-test-${_contacts.length + 1}',
      name: name,
      relationship: relationship,
      phone: phone,
      isPrimary: isPrimary,
    );
    _contacts.add(c);
    return c;
  }

  @override
  Future<EmergencyContactModel> updateContact({
    required String contactId,
    String? name,
    String? relationship,
    String? phone,
    bool? isPrimary,
  }) async {
    final index = _contacts.indexWhere((c) => c.id == contactId);
    if (index != -1) {
      final updated = _contacts[index].copyWith(
        name: name,
        relationship: relationship,
        phone: phone,
        isPrimary: isPrimary,
      );
      _contacts[index] = updated;
      return updated;
    }
    return EmergencyContactModel(
      id: contactId,
      name: name ?? '',
      relationship: relationship ?? '',
      phone: phone ?? '',
    );
  }

  @override
  Future<void> deleteContact(String contactId) async {
    _contacts.removeWhere((c) => c.id == contactId);
  }

  @override
  Future<MedicalIdModel> updateMedicalProfile({
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) async {
    _profile = _profile.copyWith(
      bloodGroup: bloodGroup,
      allergies: allergies,
      chronicDiseases: chronicDiseases,
    );
    return _profile;
  }
}

void main() {
  group('EmergencyDomainModels Unit Tests', () {
    test('EmergencyContactModel serialization and copyWith', () {
      final contact = EmergencyContactModel(
        id: 'c-101',
        name: 'Jane Doe',
        relationship: 'Sister',
        phone: '+1 555-123-4567',
        isPrimary: false,
        createdAt: DateTime(2026, 10, 8),
      );

      final json = contact.toJson();
      expect(json['id'], 'c-101');
      expect(json['name'], 'Jane Doe');
      expect(json['relationship'], 'Sister');
      expect(json['phone'], '+1 555-123-4567');
      expect(json['isPrimary'], false);

      final parsed = EmergencyContactModel.fromJson(json);
      expect(parsed.id, 'c-101');
      expect(parsed.name, 'Jane Doe');
      expect(parsed.isPrimary, false);

      final updated = parsed.copyWith(isPrimary: true, phone: '+1 555-999-0000');
      expect(updated.isPrimary, true);
      expect(updated.phone, '+1 555-999-0000');
      expect(updated.name, 'Jane Doe');
    });

    test('MedicalIdModel serialization and copyWith', () {
      final model = const MedicalIdModel(
        id: 'med-id-01',
        fullName: 'Alex Mercer',
        bloodGroup: 'O-',
        allergies: 'Penicillin, Peanuts',
        chronicDiseases: 'Asthma',
        emergencyContacts: [
          EmergencyContactModel(
            id: 'c-1',
            name: 'Sarah Mercer',
            relationship: 'Spouse',
            phone: '+1 555-019-2834',
            isPrimary: true,
          ),
        ],
      );

      final json = model.toJson();
      expect(json['fullName'], 'Alex Mercer');
      expect(json['bloodGroup'], 'O-');
      expect((json['emergencyContacts'] as List).length, 1);

      final parsed = MedicalIdModel.fromJson(json);
      expect(parsed.fullName, 'Alex Mercer');
      expect(parsed.bloodGroup, 'O-');
      expect(parsed.emergencyContacts.first.name, 'Sarah Mercer');

      final updated = parsed.copyWith(bloodGroup: 'O+');
      expect(updated.bloodGroup, 'O+');
      expect(updated.fullName, 'Alex Mercer');
    });

    test('FirstAidProtocolModel contains certified emergency guides', () {
      final protocols = FirstAidProtocolModel.standardProtocols;
      expect(protocols.length, 4);

      final ids = protocols.map((p) => p.id).toList();
      expect(ids, containsAll(['cpr', 'stroke', 'anaphylaxis', 'choking']));

      final cpr = protocols.firstWhere((p) => p.id == 'cpr');
      expect(cpr.steps.isNotEmpty, true);
      expect(cpr.steps.first, contains('911/112'));
    });
  });

  group('EmergencyController State Management Tests', () {
    test('initializes with fallback ICE profile and protocols', () {
      final stateContainer = ProviderContainer(
        overrides: [
          emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
        ],
      );

      final state = stateContainer.read(emergencyControllerProvider);
      expect(state.profile.fullName.isNotEmpty, true);
      expect(state.profile.bloodGroup, 'O+');
      expect(state.contacts.isNotEmpty, true);
      expect(state.primaryContact, isNotNull);
      expect(state.primaryContact!.isPrimary, true);
      expect(state.protocols.length, 4);
    });

    test('addEmergencyContact adds contact and preserves state', () async {
      final container = ProviderContainer(
        overrides: [
          emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
        ],
      );

      final notifier = container.read(emergencyControllerProvider.notifier);
      await notifier.loadEmergencyData();
      final initialCount = container.read(emergencyControllerProvider).contacts.length;

      await notifier.addEmergencyContact(
        name: 'Dr. Gregory House',
        relationship: 'Diagnostician',
        phone: '+1 555-888-9999',
        isPrimary: false,
      );

      final updatedState = container.read(emergencyControllerProvider);
      expect(updatedState.contacts.length, initialCount + 1);
      expect(updatedState.contacts.any((c) => c.name == 'Dr. Gregory House'), true);
    });

    test('setPrimaryContact updates primary flag and demotes previous', () async {
      final container = ProviderContainer(
        overrides: [
          emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
        ],
      );

      final notifier = container.read(emergencyControllerProvider.notifier);
      await notifier.loadEmergencyData();
      final secondary = container.read(emergencyControllerProvider).contacts.firstWhere((c) => !c.isPrimary);

      await notifier.setPrimaryContact(secondary.id);

      final updatedState = container.read(emergencyControllerProvider);
      expect(updatedState.primaryContact?.id, secondary.id);
    });

    test('deleteEmergencyContact removes target contact', () async {
      final container = ProviderContainer(
        overrides: [
          emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
        ],
      );

      final notifier = container.read(emergencyControllerProvider.notifier);
      await notifier.loadEmergencyData();
      final target = container.read(emergencyControllerProvider).contacts.last;

      await notifier.deleteEmergencyContact(target.id);

      final updatedState = container.read(emergencyControllerProvider);
      expect(updatedState.contacts.any((c) => c.id == target.id), false);
    });

    test('updateMedicalProfile updates blood group and conditions', () async {
      final container = ProviderContainer(
        overrides: [
          emergencyRepositoryProvider.overrideWithValue(_FakeEmergencyRepository()),
        ],
      );

      final notifier = container.read(emergencyControllerProvider.notifier);
      await notifier.updateMedicalProfile(
        bloodGroup: 'B+',
        allergies: 'Penicillin, Shellfish',
        chronicDiseases: 'Controlled Hypertension',
      );

      final updatedState = container.read(emergencyControllerProvider);
      expect(updatedState.profile.bloodGroup, 'B+');
      expect(updatedState.profile.allergies, contains('Shellfish'));
    });
  });
}
