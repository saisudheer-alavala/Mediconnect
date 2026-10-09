import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/auth/domain/user_model.dart';
import 'package:mediconnect/features/profile/data/profile_repository.dart';
import 'package:mediconnect/features/profile/presentation/profile_controller.dart';

class MockProfileRepository implements ProfileRepository {
  UserModel? mockUser;
  bool shouldThrow = false;
  bool passwordChanged = false;
  bool accountDeactivated = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel> getProfile() async {
    if (shouldThrow) throw Exception('Network connection failure');
    return mockUser ??
        const UserModel(
          id: 'user-001',
          email: 'test@example.com',
          role: UserRole.patient,
          phone: '+15551234567',
          patientProfile: PatientProfileModel(
            id: 'pat-001',
            fullName: 'John Doe',
            bloodGroup: 'O+',
            allergies: 'Penicillin',
            chronicDiseases: 'Asthma',
          ),
        );
  }

  @override
  Future<UserModel> updatePatientProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) async {
    if (shouldThrow) throw Exception('Update patient failed');
    return UserModel(
      id: 'user-001',
      email: 'test@example.com',
      role: UserRole.patient,
      phone: phone ?? '+15551234567',
      patientProfile: PatientProfileModel(
        id: 'pat-001',
        fullName: fullName ?? 'John Doe',
        bloodGroup: bloodGroup ?? 'O+',
        allergies: allergies ?? 'Penicillin',
        chronicDiseases: chronicDiseases ?? 'Asthma',
      ),
    );
  }

  @override
  Future<UserModel> updateDoctorProfile({
    String? fullName,
    String? phone,
    String? qualification,
    int? experienceYears,
    String? clinicName,
    String? clinicAddress,
    double? consultationFee,
    String? bio,
    String? avatarUrl,
  }) async {
    if (shouldThrow) throw Exception('Update doctor failed');
    return UserModel(
      id: 'doc-user-001',
      email: 'doctor@example.com',
      role: UserRole.doctor,
      phone: phone ?? '+15559876543',
      doctorProfile: DoctorProfileModel(
        id: 'doc-001',
        fullName: fullName ?? 'Dr. Smith',
        qualification: qualification ?? 'MD Cardiology',
        licenseNumber: 'LIC-12345',
        experienceYears: experienceYears ?? 12,
        clinicName: clinicName ?? 'Heart Clinic',
        clinicAddress: clinicAddress ?? '123 Medical Way',
        bio: bio,
        isVerified: true,
      ),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (shouldThrow) throw Exception('Incorrect current password');
    passwordChanged = true;
  }

  @override
  Future<void> deactivateAccount({
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Deactivation failed');
    accountDeactivated = true;
  }
}

void main() {
  group('Profile Models & State Unit Tests', () {
    test('UserModel and Profile JSON serialization works accurately', () {
      final json = {
        'id': 'pat-uuid-1',
        'email': 'alice@healthcare.org',
        'role': 'PATIENT',
        'phone': '+15553334444',
        'isActive': true,
        'patientProfile': {
          'id': 'pat-prof-1',
          'fullName': 'Alice Wonderland',
          'dateOfBirth': '1990-05-15',
          'gender': 'FEMALE',
          'bloodGroup': 'A+',
          'allergies': 'Latex',
          'chronicDiseases': 'None',
        },
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'pat-uuid-1');
      expect(user.role, UserRole.patient);
      expect(user.displayName, 'Alice Wonderland');
      expect(user.patientProfile?.bloodGroup, 'A+');
      expect(user.patientProfile?.allergies, 'Latex');

      final serialized = user.toJson();
      expect(serialized['id'], 'pat-uuid-1');
      expect(serialized['role'], 'PATIENT');
    });

    test('Doctor UserModel displayName uses doctorProfile fullName', () {
      final json = {
        'id': 'doc-uuid-1',
        'email': 'doctor@clinic.com',
        'role': 'DOCTOR',
        'doctorProfile': {
          'id': 'doc-prof-1',
          'fullName': 'Dr. Marcus Welby',
          'qualification': 'MD, Internal Medicine',
          'licenseNumber': 'MD-998877',
          'experienceYears': 20,
          'clinicName': 'City Hospital',
          'isVerified': true,
        },
      };

      final user = UserModel.fromJson(json);
      expect(user.role, UserRole.doctor);
      expect(user.displayName, 'Dr. Marcus Welby');
      expect(user.doctorProfile?.isVerified, isTrue);
      expect(user.doctorProfile?.experienceYears, 20);
    });

    test('ProfileState copyWith updates preferences and flags correctly', () {
      const state = ProfileState();
      expect(state.notificationsEnabled, isTrue);
      expect(state.isDarkMode, isFalse);
      expect(state.preferredLanguage, 'English');
      expect(state.biometricsEnabled, isFalse);

      final updated = state.copyWith(
        isDarkMode: true,
        preferredLanguage: 'Spanish',
        biometricsEnabled: true,
        notificationsEnabled: false,
      );

      expect(updated.isDarkMode, isTrue);
      expect(updated.preferredLanguage, 'Spanish');
      expect(updated.biometricsEnabled, isTrue);
      expect(updated.notificationsEnabled, isFalse);
    });

    test('ProfileController loads profile from repository successfully', () async {
      final mockRepo = MockProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(profileControllerProvider.notifier);
      await controller.loadProfile();

      final state = container.read(profileControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.user, isNotNull);
      expect(state.user?.displayName, 'John Doe');
      expect(state.error, isNull);
    });

    test('ProfileController handles loadProfile failure gracefully', () async {
      final mockRepo = MockProfileRepository()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(profileControllerProvider.notifier);
      await controller.loadProfile();

      final state = container.read(profileControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, contains('Network connection failure'));
    });

    test('ProfileController updates patient profile successfully', () async {
      final mockRepo = MockProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(profileControllerProvider.notifier);
      final success = await controller.updatePatientProfile(
        fullName: 'Jane Doe Updated',
        bloodGroup: 'B+',
      );

      expect(success, isTrue);
      final state = container.read(profileControllerProvider);
      expect(state.user?.displayName, 'Jane Doe Updated');
      expect(state.user?.patientProfile?.bloodGroup, 'B+');
      expect(state.successMessage, 'Profile details updated successfully');
    });

    test('ProfileController updates doctor profile successfully', () async {
      final mockRepo = MockProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(profileControllerProvider.notifier);
      final success = await controller.updateDoctorProfile(
        fullName: 'Dr. Gregory House',
        qualification: 'MD Diagnostics',
        clinicName: 'Princeton-Plainsboro',
        experienceYears: 18,
      );

      expect(success, isTrue);
      final state = container.read(profileControllerProvider);
      expect(state.user?.displayName, 'Dr. Gregory House');
      expect(state.user?.doctorProfile?.qualification, 'MD Diagnostics');
    });

    test('ProfileController changes password and handles deactivation', () async {
      final mockRepo = MockProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(profileControllerProvider.notifier);

      final pwSuccess = await controller.changePassword(
        currentPassword: 'OldPassword123',
        newPassword: 'NewPassword2026!',
      );
      expect(pwSuccess, isTrue);
      expect(mockRepo.passwordChanged, isTrue);

      final deactSuccess = await controller.deactivateAccount(password: 'MyPassword123');
      expect(deactSuccess, isTrue);
      expect(mockRepo.accountDeactivated, isTrue);
    });

    test('themeModeProvider updates reactively when isDarkMode changes', () {
      final mockRepo = MockProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(profileControllerProvider.notifier).toggleDarkMode(true);
      expect(container.read(themeModeProvider), ThemeMode.dark);

      container.read(profileControllerProvider.notifier).toggleDarkMode(false);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('Preference toggles update state values immediately', () {
      final mockRepo = MockProfileRepository();
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(profileControllerProvider.notifier);
      controller.toggleNotifications(false);
      controller.toggleBiometrics(true);
      controller.setLanguage('French');

      final state = container.read(profileControllerProvider);
      expect(state.notificationsEnabled, isFalse);
      expect(state.biometricsEnabled, isTrue);
      expect(state.preferredLanguage, 'French');

      controller.clearMessages();
      expect(container.read(profileControllerProvider).error, isNull);
    });
  });
}
