import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    return const AuthState(status: AuthStatus.initial);
  }

  /// Check active session on app boot
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: null,
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    }
  }

  /// Sign in with email & password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Register patient
  Future<bool> registerPatient({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.registerPatient(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Register doctor
  Future<bool> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    required String specializationName,
    required String qualification,
    required String licenseNumber,
    required int experienceYears,
    required String clinicName,
    String? phone,
    String? clinicAddress,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.registerDoctor(
        email: email,
        password: password,
        fullName: fullName,
        specializationName: specializationName,
        qualification: qualification,
        licenseNumber: licenseNumber,
        experienceYears: experienceYears,
        clinicName: clinicName,
        phone: phone,
        clinicAddress: clinicAddress,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Log out
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

/// Provider for AuthController
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
