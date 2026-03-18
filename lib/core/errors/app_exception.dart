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

/// Thrown when Firebase Auth operations fail.
class AuthException extends AppException {
  const AuthException(super.message, [super.original]);
}

/// Thrown when Firestore operations fail.
class FirestoreException extends AppException {
  const FirestoreException(super.message, [super.original]);
}

/// Thrown when Firebase Storage operations fail.
class StorageException extends AppException {
  const StorageException(super.message, [super.original]);
}
