import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/features/auth/domain/user_model.dart';
import 'package:mediconnect/features/auth/presentation/auth_state.dart';

void main() {
  group('UserModel & Profiles JSON Tests', () {
    test('Patient UserModel deserializes correctly from backend JSON', () {
      final json = {
        'id': 'usr-101',
        'email': 'sarah@test.com',
        'role': 'PATIENT',
        'phone': '+1234567890',
        'isActive': true,
        'patientProfile': {
          'id': 'pat-202',
          'fullName': 'Sarah Jenkins',
          'dateOfBirth': '1998-05-12T00:00:00.000Z',
          'gender': 'FEMALE',
          'bloodGroup': 'O+',
          'allergies': 'Penicillin',
          'chronicDiseases': null,
        },
        'doctorProfile': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'usr-101');
      expect(user.email, 'sarah@test.com');
      expect(user.role, UserRole.patient);
      expect(user.displayName, 'Sarah Jenkins');
      expect(user.patientProfile?.bloodGroup, 'O+');
      expect(user.patientProfile?.allergies, 'Penicillin');
      expect(user.doctorProfile, isNull);
    });

    test('Doctor UserModel deserializes correctly from backend JSON', () {
      final json = {
        'id': 'usr-501',
        'email': 'dr.smith@clinic.org',
        'role': 'DOCTOR',
        'phone': '+1987654321',
        'isActive': true,
        'patientProfile': null,
        'doctorProfile': {
          'id': 'doc-707',
          'fullName': 'Dr. Marcus Smith',
          'qualification': 'MD Cardiology',
          'licenseNumber': 'MED-8910-US',
          'experienceYears': 12,
          'clinicName': 'Heart Wellness Clinic',
          'clinicAddress': '123 Medical Way',
          'specialization': {
            'name': 'Cardiologist',
          },
          'isVerified': true,
          'bio': 'Cardiovascular specialist with 12+ years experience',
        },
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'usr-501');
      expect(user.role, UserRole.doctor);
      expect(user.displayName, 'Dr. Marcus Smith');
      expect(user.doctorProfile?.specializationName, 'Cardiologist');
      expect(user.doctorProfile?.isVerified, isTrue);
      expect(user.doctorProfile?.experienceYears, 12);
    });

    test('AuthTokensModel serializes and deserializes correctly', () {
      final json = {
        'accessToken': 'jwt-access-token-xyz',
        'refreshToken': 'jwt-refresh-token-abc',
      };

      final tokens = AuthTokensModel.fromJson(json);
      expect(tokens.accessToken, 'jwt-access-token-xyz');
      expect(tokens.refreshToken, 'jwt-refresh-token-abc');

      final serialized = tokens.toJson();
      expect(serialized['accessToken'], 'jwt-access-token-xyz');
      expect(serialized['refreshToken'], 'jwt-refresh-token-abc');
    });
  });

  group('AuthState Tests', () {
    test('AuthState initial state has correct defaults', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
    });

    test('AuthState computed getters correctly identify roles', () {
      const patient = UserModel(
        id: '1',
        email: 'p@test.com',
        role: UserRole.patient,
        patientProfile: PatientProfileModel(id: 'p1', fullName: 'Patient Pat'),
      );

      const doctor = UserModel(
        id: '2',
        email: 'd@test.com',
        role: UserRole.doctor,
        doctorProfile: DoctorProfileModel(
          id: 'd1',
          fullName: 'Dr. Dave',
          qualification: 'MBBS',
          licenseNumber: 'LIC-1',
          experienceYears: 5,
          clinicName: 'Clinic',
        ),
      );

      final patientState = const AuthState().copyWith(
        status: AuthStatus.authenticated,
        user: patient,
      );
      expect(patientState.isAuthenticated, isTrue);
      expect(patientState.isPatient, isTrue);
      expect(patientState.isDoctor, isFalse);

      final doctorState = const AuthState().copyWith(
        status: AuthStatus.authenticated,
        user: doctor,
      );
      expect(doctorState.isAuthenticated, isTrue);
      expect(doctorState.isDoctor, isTrue);
      expect(doctorState.isPatient, isFalse);
    });
  });
}
