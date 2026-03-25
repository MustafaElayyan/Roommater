/// Typed exceptions thrown by data-layer datasources.
///
/// The repository implementations catch these and map them to [Failure] objects
/// before returning them to the domain/presentation layers.
class AppException implements Exception {
  const AppException(this.message, [this.original]);

  final String message;
  final Object? original;

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when authentication operations fail.
class AuthException extends AppException {
  const AuthException(super.message, [super.original]);
}

/// Thrown when API request operations fail.
class ApiException extends AppException {
  const ApiException(super.message, [super.original]);
}

/// Thrown when local secure token storage operations fail.
class TokenStorageException extends AppException {
  const TokenStorageException(super.message, [super.original]);
}
