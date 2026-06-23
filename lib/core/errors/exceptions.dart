class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => message;
}
