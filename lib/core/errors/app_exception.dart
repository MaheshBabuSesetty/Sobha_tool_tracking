abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.stackTrace,
    this.statusCode,
  });

  final int? statusCode;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized. Please login again.',
    super.code = 'UNAUTHORIZED',
    super.stackTrace,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'FORBIDDEN',
    super.stackTrace,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.stackTrace,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    super.stackTrace,
    this.statusCode,
  });

  final int? statusCode;
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out. Please try again.',
    super.code = 'TIMEOUT',
    super.stackTrace,
  });
}

class NoInternetException extends AppException {
  const NoInternetException({
    super.message = 'No internet connection. Working in offline mode.',
    super.code = 'NO_INTERNET',
    super.stackTrace,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.stackTrace,
    this.fieldErrors,
  });

  final Map<String, List<String>>? fieldErrors;
}

class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code = 'PARSE_ERROR',
    super.stackTrace,
  });
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.stackTrace,
  });
}

class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.code = 'CONFLICT',
    super.stackTrace,
  });
}

class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNEXPECTED',
    super.stackTrace,
  });
}
