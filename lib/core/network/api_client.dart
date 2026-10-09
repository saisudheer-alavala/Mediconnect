import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';

/// Centralized Dio Network Client with Auth Interceptors and Token Refresh
class ApiClient {
  final Dio dio;
  final SecureStorageService storage;

  ApiClient({
    required this.storage,
    Dio? customDio,
  }) : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: ApiEndpoints.connectTimeout,
                receiveTimeout: ApiEndpoints.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Token expired handling (401)
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/login') &&
              !error.requestOptions.path.contains('/auth/refresh-token')) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              // Retry original request with newly saved access token
              final newToken = await storage.getAccessToken();
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(error);
              }
            } else {
              await storage.clearAuth();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final newAccessToken = response.data['data']['accessToken'] as String;
        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
        );
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Parses and wraps Dio errors into standard domain AppExceptions
  AppException handleDioError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        String message = 'An unexpected server error occurred.';
        String? code;

        if (data is Map<String, dynamic>) {
          message = data['message'] as String? ?? message;
          code = data['code'] as String?;
        }

        switch (error.response?.statusCode) {
          case 401:
            return UnauthorizedException(message: message, code: code);
          case 403:
            return ForbiddenException(message: message, code: code);
          case 404:
            return NotFoundException(message: message, code: code);
          case 429:
            final retryHeader = error.response?.headers.value('retry-after');
            final retrySeconds = retryHeader != null ? int.tryParse(retryHeader) : null;
            return RateLimitException(
              message: message,
              code: code ?? 'RATE_LIMIT_EXCEEDED',
              retryAfterSeconds: retrySeconds,
            );
          default:
            return ServerException(
              message: message,
              code: code,
              statusCode: error.response?.statusCode,
            );
        }
      }
      return const NetworkException();
    }
    return AppException(message: error.toString());
  }
}

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return ApiClient(storage: storage);
});
