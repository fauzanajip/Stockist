abstract class AppException implements Exception {
  final String message;
  final Exception? originalException;

  const AppException({required this.message, this.originalException});

  @override
  String toString() {
    if (originalException != null) {
      return '$message: $originalException';
    }
    return message;
  }
}

class AppDatabaseException extends AppException {
  const AppDatabaseException({required super.message, super.originalException});
}

class AppValidationException extends AppException {
  const AppValidationException({required super.message});
}

class AppNotFoundException extends AppException {
  const AppNotFoundException({required super.message});
}

class AppCacheException extends AppException {
  const AppCacheException({required super.message, super.originalException});
}
