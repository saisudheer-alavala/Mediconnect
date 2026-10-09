/// Domain level Failure object mapped for UI presentation
class Failure {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Please check your internet connection and try again.',
    super.code = 'NETWORK_FAILURE',
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = 'SERVER_FAILURE',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_FAILURE',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_FAILURE',
  });
}
