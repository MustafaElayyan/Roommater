/// Base class for all domain-layer failures.
///
/// Failures are typed error objects returned through the domain layer instead
/// of throwing exceptions directly into the UI.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A failure originating from authentication operations.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// A failure originating from local data-store read/write operations.
final class DataStoreFailure extends Failure {
  const DataStoreFailure(super.message);
}

/// A failure indicating there is no internet connection.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// A catch-all failure for unexpected errors.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
