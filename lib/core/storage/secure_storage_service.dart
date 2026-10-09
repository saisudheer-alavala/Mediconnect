import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Secure local storage service for sensitive tokens and user identity
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: AppConstants.tokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConstants.userRoleKey, value: role);
  }

  Future<void> saveUserId(String id) async {
    await _storage.write(key: AppConstants.userIdKey, value: id);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<String?> getUserRole() async {
    return _storage.read(key: AppConstants.userRoleKey);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: AppConstants.userIdKey);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userRoleKey);
    await _storage.delete(key: AppConstants.userIdKey);
  }
}

/// Provider for accessing SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
