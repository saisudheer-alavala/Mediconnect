import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../auth/domain/user_model.dart';

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  /// Fetch authenticated user's full profile
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.userProfile);
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Update patient personal & clinical details
  Future<UserModel> updatePatientProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? allergies,
    String? chronicDiseases,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (fullName != null) payload['fullName'] = fullName;
      if (phone != null) payload['phone'] = phone;
      if (dateOfBirth != null) payload['dateOfBirth'] = dateOfBirth;
      if (gender != null) payload['gender'] = gender;
      if (bloodGroup != null) payload['bloodGroup'] = bloodGroup;
      if (allergies != null) payload['allergies'] = allergies;
      if (chronicDiseases != null) payload['chronicDiseases'] = chronicDiseases;

      final response = await apiClient.dio.put(
        ApiEndpoints.updatePatientProfile,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Update doctor professional profile
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
    try {
      final payload = <String, dynamic>{};
      if (fullName != null) payload['fullName'] = fullName;
      if (phone != null) payload['phone'] = phone;
      if (qualification != null) payload['qualification'] = qualification;
      if (experienceYears != null) payload['experienceYears'] = experienceYears;
      if (clinicName != null) payload['clinicName'] = clinicName;
      if (clinicAddress != null) payload['clinicAddress'] = clinicAddress;
      if (consultationFee != null) payload['consultationFee'] = consultationFee;
      if (bio != null) payload['bio'] = bio;
      if (avatarUrl != null) payload['avatarUrl'] = avatarUrl;

      final response = await apiClient.dio.put(
        ApiEndpoints.updateDoctorProfile,
        data: payload,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Deactivate account (soft delete)
  Future<void> deactivateAccount({
    required String password,
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.deactivateAccount,
        data: {
          'password': password,
          'confirm': true,
        },
      );
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }
}

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});
