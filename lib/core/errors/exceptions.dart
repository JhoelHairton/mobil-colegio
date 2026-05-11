/// Excepciones personalizadas de la capa de datos.
class ServerException implements Exception {
  // El constructor va arriba
  ServerException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  CacheException(this.message); // Constructor arriba

  final String message;
}

class NetworkException implements Exception {
  NetworkException(this.message); // Constructor arriba

  final String message;
}

class AuthException implements Exception {
  AuthException(this.message, {this.code}); // Constructor arriba

  final String message;
  final String? code;
}