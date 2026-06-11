import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/auth/data/datasources/auth_local_datasource.dart';

class MobileApiClient {
  MobileApiClient({required this.localDataSource});

  final AuthLocalDataSource localDataSource;

  static const _baseUrl = ApiConstants.mobileBaseUrl;
  static const _prefix = '/api/v1';
  bool _refreshing = false;

  Dio _buildDio() => Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
          validateStatus: (_) => true,
        ),
      );

  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await localDataSource.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJson,
  }) =>
      _execute('GET', path, queryParams: queryParams, fromJson: fromJson);

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) =>
      _execute('POST', path, data: data, fromJson: fromJson);

  Future<Result<T>> _execute<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      var headers = await _authHeaders();
      final dio = _buildDio();
      var response = await _request(
        dio, method, '$_prefix$path',
        data: data, queryParams: queryParams, headers: headers,
      );

      if (response.statusCode == 401 && !_refreshing) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          headers = await _authHeaders();
          response = await _request(
            dio, method, '$_prefix$path',
            data: data, queryParams: queryParams, headers: headers,
          );
        }
      }

      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      AppLogger.error('Network error: $method $path', e);
      return ResultFailure(_mapError(e));
    } catch (e, st) {
      AppLogger.error('Unexpected error: $method $path', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Response<dynamic>> _request(
    Dio dio,
    String method,
    String fullPath, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    required Map<String, dynamic> headers,
  }) {
    final options = Options(headers: headers);
    return switch (method) {
      'GET' => dio.get<dynamic>(
          fullPath, queryParameters: queryParams, options: options),
      'POST' => dio.post<dynamic>(fullPath, data: data, options: options),
      _ => throw UnsupportedError('Unsupported method: $method'),
    };
  }

  Future<bool> _tryRefresh() async {
    _refreshing = true;
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) return false;

      final dio = _buildDio();
      final response = await dio.post<dynamic>(
        '$_prefix${ApiConstants.mobileAuthRefresh}',
        data: {'refresh_token': refreshToken},
      );

      if ((response.statusCode ?? 0) == 200 && response.data is Map) {
        final d = response.data as Map<String, dynamic>;
        await localDataSource.saveTokens(
          accessToken: d['access_token'] as String,
          refreshToken: d['refresh_token'] as String,
          expiresIn: (d['expires_in'] as num).toInt(),
        );
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
      return false;
    } finally {
      _refreshing = false;
    }
  }

  Result<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic) fromJson,
  ) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      try {
        return Success(fromJson(response.data));
      } catch (e, st) {
        AppLogger.error('Parse error', e, st);
        return ResultFailure(
            const CacheFailure(message: 'Failed to parse response'));
      }
    }
    final msg = _errorMsg(response.data);
    return switch (status) {
      401 => ResultFailure(UnauthorizedFailure(message: msg ?? 'Session expired')),
      403 => ResultFailure(ForbiddenFailure(message: msg ?? 'Access denied')),
      404 => ResultFailure(NotFoundFailure(message: msg ?? 'Not found')),
      _ => ResultFailure(
          ServerFailure(message: msg ?? 'Server error', statusCode: status)),
    };
  }

  String? _errorMsg(dynamic data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map) return first['msg']?.toString();
    }
    return data['message']?.toString() ?? data['error']?.toString();
  }

  Failure _mapError(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          const TimeoutFailure(),
        _ => const NoInternetFailure(),
      };
}
