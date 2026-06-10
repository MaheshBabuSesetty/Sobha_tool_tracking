import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';

class LoggingInterceptor extends Interceptor {
  final _stopwatch = <String, Stopwatch>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!EnvironmentConfig.isProduction) {
      final key = '${options.method}:${options.path}:${DateTime.now().millisecondsSinceEpoch}';
      options.extra['_logKey'] = key;
      _stopwatch[key] = Stopwatch()..start();

      AppLogger.apiRequest(
        method: options.method,
        url: options.uri.toString(),
        headers: _sanitizeHeaders(options.headers),
        body: options.data,
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!EnvironmentConfig.isProduction) {
      final key = response.requestOptions.extra['_logKey'] as String?;
      final durationMs = key != null ? (_stopwatch.remove(key)?..stop())?.elapsedMilliseconds : null;

      AppLogger.apiResponse(
        url: response.requestOptions.uri.toString(),
        statusCode: response.statusCode ?? 0,
        body: response.data,
        durationMs: durationMs,
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!EnvironmentConfig.isProduction) {
      AppLogger.error(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri}',
        err,
        err.stackTrace,
      );
    }
    super.onError(err, handler);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '*** REDACTED ***';
    }
    return sanitized;
  }
}
