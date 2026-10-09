import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/auth/domain/user_model.dart';
import 'package:mediconnect/features/auth/presentation/auth_controller.dart';
import 'package:mediconnect/features/auth/presentation/auth_state.dart';
import 'package:mediconnect/features/profile/data/profile_repository.dart';
import 'package:mediconnect/features/profile/presentation/profile_screen.dart';

class MockTestProfileRepository implements ProfileRepository {
  UserModel? mockUser;

  MockTestProfileRepository({this.mockUser});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel> getProfile() async {
    return mockUser ??
        const UserModel(
          id: 'test-pat-1',
          email: 'patient@hospital.org',
          role: UserRole.patient,
          phone: '+1 555-0101',
          patientProfile: PatientProfileModel(
            id: 'pat-1',
            fullName: 'Eleanor Vance',
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
    return mockUser!;
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
    return mockUser!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> deactivateAccount({
    required String password,
  }) async {}
}

class FakeAuthController extends AuthController {
  final UserModel _mockUser;
  FakeAuthController(this._mockUser);

  @override
  AuthState build() => AuthState(status: AuthStatus.authenticated, user: _mockUser);
}

void main() {
  const patientUser = UserModel(
    id: 'user-pat-10',
    email: 'eleanor@example.com',
    role: UserRole.patient,
    phone: '+1 (555) 234-5678',
    patientProfile: PatientProfileModel(
      id: 'prof-pat-10',
      fullName: 'Eleanor Vance',
      bloodGroup: 'O+',
      allergies: 'Penicillin',
      chronicDiseases: 'Asthma',
    ),
  );

  const doctorUser = UserModel(
    id: 'user-doc-20',
    email: 'dr.marcus@hospital.org',
    role: UserRole.doctor,
    phone: '+1 (555) 987-6543',
    doctorProfile: DoctorProfileModel(
      id: 'prof-doc-20',
      fullName: 'Dr. Marcus Welby',
      qualification: 'MD, FACC',
      licenseNumber: 'MED-12345',
      experienceYears: 15,
      clinicName: 'St. Jude Cardiac Center',
      clinicAddress: '500 Health Blvd',
      isVerified: true,
      bio: 'Leading cardiologist specializing in heart failure prevention.',
    ),
  );

  Widget createTestWidget({required UserModel user}) {
    final mockRepo = MockTestProfileRepository(mockUser: user);
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(mockRepo),
        authControllerProvider.overrideWith(() => FakeAuthController(user)),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('renders Patient Profile screen with patient clinical details card', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(user: patientUser));
      await tester.pumpAndSettle();

      expect(find.text('Account & Settings'), findsOneWidget);
      expect(find.text('Eleanor Vance'), findsOneWidget);
      expect(find.text('eleanor@example.com'), findsOneWidget);
      expect(find.text('PATIENT'), findsOneWidget);

      // Clinical quick stats
      expect(find.text('Blood Group'), findsOneWidget);
      expect(find.text('O+'), findsOneWidget);
      expect(find.text('Known Allergies'), findsOneWidget);
      expect(find.text('Penicillin'), findsOneWidget);
      expect(find.text('Chronic Diseases'), findsOneWidget);
      expect(find.text('Asthma'), findsOneWidget);

      // Section titles
      expect(find.text('ACCOUNT DETAILS'), findsOneWidget);
      expect(find.text('APP PREFERENCES'), findsOneWidget);
      expect(find.text('CLINICAL GOVERNANCE & LEGAL'), findsOneWidget);
      expect(find.text('ACCOUNT ACTIONS'), findsOneWidget);
    });

    testWidgets('renders Doctor Profile screen with doctor qualifications and verified badge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(user: doctorUser));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Marcus Welby'), findsOneWidget);
      expect(find.text('dr.marcus@hospital.org'), findsOneWidget);
      expect(find.text('DOCTOR'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      // Doctor quick stats
      expect(find.text('Qualification'), findsOneWidget);
      expect(find.text('MD, FACC'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('15 Years'), findsOneWidget);
      expect(find.text('Clinic'), findsOneWidget);
      expect(find.text('St. Jude Cardiac Center'), findsOneWidget);
    });

    testWidgets('interacts with App Preference switches (alerts & dark mode)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(user: patientUser));
      await tester.pumpAndSettle();

      final alertSwitch = find.widgetWithText(SwitchListTile, 'Medication & Appointment Alerts');
      expect(alertSwitch, findsOneWidget);
      await tester.tap(alertSwitch);
      await tester.pumpAndSettle();

      final darkSwitch = find.widgetWithText(SwitchListTile, 'Dark Theme');
      expect(darkSwitch, findsOneWidget);
      await tester.tap(darkSwitch);
      await tester.pumpAndSettle();
    });

    testWidgets('opens Medical Boundaries & Safety Notice sheet on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(user: patientUser));
      await tester.pumpAndSettle();

      final disclaimerTile = find.text('Medical Boundaries & Safety Notice');
      await tester.ensureVisible(disclaimerTile);
      await tester.tap(disclaimerTile);
      await tester.pumpAndSettle();

      expect(find.text('Healthcare Boundaries & Legal'), findsOneWidget);
      expect(find.text('1. Regimen Coordination Aid Only'), findsOneWidget);
      expect(find.text('3. Life-Threatening Emergencies'), findsOneWidget);
      expect(find.text('I Understand & Acknowledge'), findsOneWidget);

      await tester.tap(find.text('I Understand & Acknowledge'));
      await tester.pumpAndSettle();
      expect(find.text('Healthcare Boundaries & Legal'), findsNothing);
    });

    testWidgets('opens Change Password modal sheet on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(user: patientUser));
      await tester.pumpAndSettle();

      final pwTile = find.text('Security & Password');
      await tester.ensureVisible(pwTile);
      await tester.tap(pwTile);
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Update Password'), findsNothing);
    });

    testWidgets('triggers Log Out confirm dialog on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestWidget(user: patientUser));
      await tester.pumpAndSettle();

      final logoutTile = find.text('Log Out');
      await tester.ensureVisible(logoutTile);
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(find.text('Are you sure you want to log out of MediCare Connect?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Logout'), findsNothing);
    });
  });
}
