class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AccessTokenExpiredException extends AuthException {
  const AccessTokenExpiredException(super.message);
}

class RefreshTokenExpiredException extends AuthException {
  const RefreshTokenExpiredException(super.message);
}
