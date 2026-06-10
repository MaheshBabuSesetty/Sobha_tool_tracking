import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio});

  final Dio dio;

  static const _retryCountKey = '_retry_count';
  static const _retryableStatuses = {408, 429, 500, 502, 503, 504};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    final shouldRetry = _shouldRetry(err) && retryCount < ApiConstants.maxRetryAttempts;

    if (shouldRetry) {
      final nextRetry = retryCount + 1;
      AppLogger.warning(
        'Retrying request (attempt $nextRetry/${ApiConstants.maxRetryAttempts}): '
        '${err.requestOptions.method} ${err.requestOptions.path}',
      );

      await Future<void>.delayed(
        Duration(milliseconds: ApiConstants.retryDelayMs * nextRetry),
      );

      final retryOptions = err.requestOptions
        ..extra[_retryCountKey] = nextRetry;

      try {
        final response = await dio.fetch<dynamic>(retryOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return super.onError(e, handler);
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout) return true;
    if (err.type == DioExceptionType.receiveTimeout) return true;
    if (err.type == DioExceptionType.connectionError) return true;

    final statusCode = err.response?.statusCode;
    return statusCode != null && _retryableStatuses.contains(statusCode);
  }
}
