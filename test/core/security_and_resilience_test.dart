import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediconnect/core/errors/error_boundary.dart';
import 'package:mediconnect/core/errors/exceptions.dart';
import 'package:mediconnect/core/network/api_client.dart';
import 'package:mediconnect/core/storage/secure_storage_service.dart';

class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _data = {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _data['accessToken'] = accessToken;
    _data['refreshToken'] = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _data['accessToken'];

  @override
  Future<String?> getRefreshToken() async => _data['refreshToken'];

  @override
  Future<void> clearAuth() async => _data.clear();
}

void main() {
  group('Security, Resilience & Error Boundary Tests', () {
    late ApiClient apiClient;
    late MockSecureStorageService storage;

    setUp(() {
      storage = MockSecureStorageService();
      apiClient = ApiClient(storage: storage);
    });

    test('Maps HTTP 429 to RateLimitException with parsed Retry-After header', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 429,
          headers: Headers.fromMap({
            'retry-after': ['60'],
          }),
          data: {
            'message': 'Rate limit exceeded. Try again in 60s.',
            'code': 'RATE_LIMIT_EXCEEDED',
          },
        ),
      );

      final exception = apiClient.handleDioError(dioException);

      expect(exception, isA<RateLimitException>());
      final rateLimitEx = exception as RateLimitException;
      expect(rateLimitEx.statusCode, 429);
      expect(rateLimitEx.code, 'RATE_LIMIT_EXCEEDED');
      expect(rateLimitEx.retryAfterSeconds, 60);
      expect(rateLimitEx.message, contains('60s'));
    });

    test('Maps HTTP 401, 403, and 404 to appropriate domain exceptions', () {
      // 401 Unauthorized
      final ex401 = apiClient.handleDioError(DioException(
        requestOptions: RequestOptions(path: '/api/v1/profile/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/profile/me'),
          statusCode: 401,
          data: {'message': 'Session expired', 'code': 'UNAUTHORIZED'},
        ),
      ));
      expect(ex401, isA<UnauthorizedException>());
      expect(ex401.statusCode, 401);

      // 403 Forbidden
      final ex403 = apiClient.handleDioError(DioException(
        requestOptions: RequestOptions(path: '/api/v1/doctors/schedule'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/doctors/schedule'),
          statusCode: 403,
          data: {'message': 'Doctor role required', 'code': 'FORBIDDEN'},
        ),
      ));
      expect(ex403, isA<ForbiddenException>());
      expect(ex403.statusCode, 403);

      // 404 Not Found
      final ex404 = apiClient.handleDioError(DioException(
        requestOptions: RequestOptions(path: '/api/v1/appointments/999'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/appointments/999'),
          statusCode: 404,
          data: {'message': 'Appointment missing', 'code': 'NOT_FOUND'},
        ),
      ));
      expect(ex404, isA<NotFoundException>());
      expect(ex404.statusCode, 404);
    });

    test('Maps socket / connectivity failures to NetworkException', () {
      final networkError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/medicines'),
        type: DioExceptionType.connectionError,
      );

      final exception = apiClient.handleDioError(networkError);
      expect(exception, isA<NetworkException>());
      expect(exception.message, contains('server unreachable'));
    });

    testWidgets('ErrorWidget.builder safely renders clinical fallback card without red screen',
        (tester) async {
      final originalBuilder = ErrorWidget.builder;
      addTearDown(() => ErrorWidget.builder = originalBuilder);
      setupGlobalErrorBoundaries();

      final details = FlutterErrorDetails(
        exception: Exception('Simulated test layout render crash'),
        stack: StackTrace.current,
      );

      final fallbackWidget = ErrorWidget.builder(details);

      await tester.pumpWidget(MaterialApp(home: fallbackWidget));
      await tester.pumpAndSettle();

      expect(find.text('Clinical Screen Display Notice'), findsOneWidget);
      expect(find.textContaining('Your stored clinical records'), findsOneWidget);
      expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);
    });
  });
}
