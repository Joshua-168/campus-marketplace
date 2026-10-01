/// Custom exceptions thrown at Data/Service layer.
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException(this.message, {this.code});
}

class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);
}
