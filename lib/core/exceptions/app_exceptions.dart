class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message);
}

class DatabaseException extends AppException {
  DatabaseException(super.message);
}
