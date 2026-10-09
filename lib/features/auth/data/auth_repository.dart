import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storage;

  AuthRepository({
    required this.apiClient,
    required this.storage,
  });

  /// Authenticate with email & password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>);

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await storage.saveUserRole(user.role.toServerString());
      await storage.saveUserId(user.id);

      return user;
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Register patient account
  Future<UserModel> registerPatient({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.registerPatient,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
          'gender': gender?.toUpperCase(),
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>);

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await storage.saveUserRole(user.role.toServerString());
      await storage.saveUserId(user.id);

      return user;
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Register doctor account
  Future<UserModel> registerDoctor({
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
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.registerDoctor,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phone': phone,
          'specializationName': specializationName,
          'qualification': qualification,
          'licenseNumber': licenseNumber,
          'experienceYears': experienceYears,
          'clinicName': clinicName,
          'clinicAddress': clinicAddress,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = AuthTokensModel.fromJson(data['tokens'] as Map<String, dynamic>);

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await storage.saveUserRole(user.role.toServerString());
      await storage.saveUserId(user.id);

      return user;
    } catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  /// Retrieve current authenticated user profile
  Future<UserModel?> getCurrentUser() async {
    final token = await storage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await apiClient.dio.get(ApiEndpoints.currentUser);
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      await storage.clearAuth();
      return null;
    }
  }

  /// Log out and purge tokens
  Future<void> logout() async {
    await storage.clearAuth();
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(apiClient: apiClient, storage: storage);
});
