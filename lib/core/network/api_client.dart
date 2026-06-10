import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/errors/app_exception.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/network/interceptors/auth_interceptor.dart';
import 'package:power_tool_tracking/core/network/interceptors/connectivity_interceptor.dart';
import 'package:power_tool_tracking/core/network/interceptors/logging_interceptor.dart';
import 'package:power_tool_tracking/core/network/interceptors/retry_interceptor.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';

class ApiClient {
  ApiClient({
    required AuthInterceptor authInterceptor,
    required LoggingInterceptor loggingInterceptor,
    required RetryInterceptor retryInterceptor,
  }) : _dio = _createDio(authInterceptor, loggingInterceptor, retryInterceptor);

  final Dio _dio;

  static Dio _createDio(
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
    RetryInterceptor retryInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: EnvironmentConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: EnvironmentConfig.apiTimeout),
        sendTimeout: Duration(milliseconds: EnvironmentConfig.apiTimeout),
        headers: {
          ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
          ApiConstants.acceptHeader: ApiConstants.applicationJson,
          ApiConstants.xFlavorHeader: EnvironmentConfig.flavorName,
        },
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      ConnectivityInterceptor(),
      retryInterceptor,
      authInterceptor,
      loggingInterceptor,
    ]);

    return dio;
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParams,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Future<Result<bool>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      final isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
      return isSuccess ? const Success(true) : ResultFailure(const UnexpectedFailure());
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Future<Result<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    T Function(dynamic json)? fromJson,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Future<Result<String>> downloadFile(
    String url, {
    required String savePath,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      return Success(savePath);
    } on DioException catch (e) {
      return ResultFailure(_mapDioError(e));
    }
  }

  Result<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(dynamic json)? fromJson,
  ) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        if (fromJson != null && response.data != null) {
          return Success(fromJson(response.data));
        }
        return Success(response.data as T);
      } catch (e, st) {
        AppLogger.error('Response parsing error', e, st);
        return ResultFailure(const CacheFailure(message: 'Failed to parse server response'));
      }
    }

    switch (statusCode) {
      case 401:
        return ResultFailure(const UnauthorizedFailure());
      case 403:
        return ResultFailure(const ForbiddenFailure());
      case 404:
        return ResultFailure(NotFoundFailure(
          message: _extractErrorMessage(response.data) ?? 'Resource not found',
        ));
      case 422:
        return ResultFailure(ValidationFailure(
          message: _extractErrorMessage(response.data) ?? 'Validation failed',
        ));
      case 429:
        return ResultFailure(const ServerFailure(message: 'Too many requests. Please try again later.'));
      default:
        return ResultFailure(ServerFailure(
          message: _extractErrorMessage(response.data) ?? 'Server error occurred',
          statusCode: statusCode,
        ));
    }
  }

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        if (e.error is NoInternetException) return const NoInternetFailure();
        return NetworkFailure(message: e.message ?? 'Connection error');
      case DioExceptionType.badResponse:
        return ServerFailure(
          message: _extractErrorMessage(e.response?.data) ?? 'Bad response from server',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled');
      default:
        return const UnexpectedFailure();
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    if (data is String) return data;
    return null;
  }
}
