import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/profile_repository.dart';

class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final String? successMessage;
  final bool notificationsEnabled;
  final bool isDarkMode;
  final String preferredLanguage;
  final bool biometricsEnabled;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.successMessage,
    this.notificationsEnabled = true,
    this.isDarkMode = false,
    this.preferredLanguage = 'English',
    this.biometricsEnabled = false,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    bool? notificationsEnabled,
    bool? isDarkMode,
    String? preferredLanguage,
    bool? biometricsEnabled,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repository;

  @override
  ProfileState build() {
    _repository = ref.watch(profileRepositoryProvider);
    // Initialize user from authController if already signed in
    final authUser = ref.watch(authControllerProvider).user;
    return ProfileState(user: authUser);
  }

  /// Fetch full fresh user profile from backend
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(
        user: user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update patient profile
  Future<bool> updatePatientProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);
    try {
      final updated = await _repository.updatePatientProfile(
        fullName: fullName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodGroup: bloodGroup,
        allergies: allergies,
        chronicDiseases: chronicDiseases,
      );
      state = state.copyWith(
        user: updated,
        isUpdating: false,
        successMessage: 'Profile details updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update doctor profile
  Future<bool> updateDoctorProfile({
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
    state = state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);
    try {
      final updated = await _repository.updateDoctorProfile(
        fullName: fullName,
        phone: phone,
        qualification: qualification,
        experienceYears: experienceYears,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        consultationFee: consultationFee,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(
        user: updated,
        isUpdating: false,
        successMessage: 'Professional profile updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Password changed successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Deactivate account
  Future<bool> deactivateAccount({
    required String password,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);
    try {
      await _repository.deactivateAccount(password: password);
      state = state.copyWith(
        isUpdating: false,
        successMessage: 'Account deactivated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Toggle notification preference
  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  /// Toggle dark mode
  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
  }

  /// Set preferred application language
  void setLanguage(String lang) {
    state = state.copyWith(preferredLanguage: lang);
  }

  /// Toggle biometric authentication
  void toggleBiometrics(bool value) {
    state = state.copyWith(biometricsEnabled: value);
  }

  /// Clear any error or success alerts
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

/// Provider for ProfileController
final profileControllerProvider = NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

/// Provider exposing ThemeMode based on ProfileState
final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(profileControllerProvider.select((s) => s.isDarkMode));
  return isDark ? ThemeMode.dark : ThemeMode.light;
});
