abstract class AppException implements Exception {
  final String message;
  final Exception? originalException;

  const AppException({required this.message, this.originalException});
}

class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.originalException});
}

class ValidationException extends AppException {
  const ValidationException({required super.message});
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message});
}

class CacheException extends AppException {
  const CacheException({required super.message, super.originalException});
}
