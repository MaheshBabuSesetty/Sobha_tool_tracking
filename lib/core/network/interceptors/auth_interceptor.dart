import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/storage/secure_storage_service.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.secureStorage, required this.dio});

  final SecureStorageService secureStorage;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers[ApiConstants.authorizationHeader] =
          '${ApiConstants.bearerPrefix}$token';
    }
    options.headers[ApiConstants.xApiVersionHeader] = ApiConstants.apiVersion;
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final retryOptions = err.requestOptions;
          final newToken = await secureStorage.getAccessToken();
          retryOptions.headers[ApiConstants.authorizationHeader] =
              '${ApiConstants.bearerPrefix}$newToken';
          final response = await dio.fetch<dynamic>(retryOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e);
        await secureStorage.clearTokens();
      }
    }
    super.onError(err, handler);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {ApiConstants.authorizationHeader: null},
        ),
      );

      final data = response.data;
      if (data != null) {
        await secureStorage.saveAccessToken(data['access_token'] as String);
        if (data['refresh_token'] != null) {
          await secureStorage.saveRefreshToken(data['refresh_token'] as String);
        }
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Refresh token request failed', e);
      return false;
    }
  }
}
