import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/errors/app_exception.dart';

class ConnectivityInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await Connectivity().checkConnectivity();
    final hasConnection = !result.contains(ConnectivityResult.none);

    if (!hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NoInternetException(),
          message: 'No internet connection',
        ),
      );
    }

    super.onRequest(options, handler);
  }
}
