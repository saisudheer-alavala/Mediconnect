/// Base application exception
class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const AppException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() => 'AppException(message: $message, code: $code, statusCode: $statusCode)';
}

/// Network connectivity exception
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection or server unreachable.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Server responded with 4xx or 5xx
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.statusCode,
  });
}

/// Unauthorized / Session expired (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired. Please log in again.',
    super.code = 'UNAUTHORIZED',
    super.statusCode = 401,
  });
}

/// Access forbidden (403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'FORBIDDEN',
    super.statusCode = 403,
  });
}

/// Not found (404)
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Requested resource was not found.',
    super.code = 'NOT_FOUND',
    super.statusCode = 404,
  });
}

/// Cache / local storage exception
class CacheException extends AppException {
  const CacheException({
    super.message = 'Failed to read or write local data.',
    super.code = 'CACHE_ERROR',
  });
}

/// Rate limit exceeded (429)
class RateLimitException extends AppException {
  final int? retryAfterSeconds;

  const RateLimitException({
    super.message = 'Too many requests. Please try again shortly.',
    super.code = 'RATE_LIMIT_EXCEEDED',
    super.statusCode = 429,
    this.retryAfterSeconds,
  });
}
