import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, this.statusCode});
  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please login again.',
    super.code = 'UNAUTHORIZED',
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Access denied.',
    super.code = 'FORBIDDEN',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code = 'NOT_FOUND'});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code = 'SERVER_ERROR', this.statusCode});
  final int? statusCode;
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out. Please check your connection.',
    super.code = 'TIMEOUT',
  });
}

class NoInternetFailure extends Failure {
  const NoInternetFailure({
    super.message = 'No internet connection. Showing cached data.',
    super.code = 'NO_INTERNET',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code = 'CACHE_ERROR'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
  final Map<String, List<String>>? fieldErrors;
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code = 'STORAGE_ERROR'});
}

class ConflictFailure extends Failure {
  const ConflictFailure({required super.message, super.code = 'CONFLICT'});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNEXPECTED',
  });
}

class RfidInitializationFailure extends Failure {
  const RfidInitializationFailure({required super.message, super.code = 'RFID_INIT_ERROR'});
}

class RfidConnectionFailure extends Failure {
  const RfidConnectionFailure({required super.message, super.code = 'RFID_CONNECTION_ERROR'});
}

class RfidScanFailure extends Failure {
  const RfidScanFailure({required super.message, super.code = 'RFID_SCAN_ERROR'});
}

class RfidPowerFailure extends Failure {
  const RfidPowerFailure({required super.message, super.code = 'RFID_POWER_ERROR'});
}
