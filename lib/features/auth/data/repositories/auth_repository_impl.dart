import 'package:dio/dio.dart';
import 'package:power_tool_tracking/core/constants/api_constants.dart';
import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/features/auth/domain/repositories/auth_repository.dart';
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.localDataSource});

  final AuthLocalDataSource localDataSource;

  static const _baseUrl = ApiConstants.mobileBaseUrl;

  Dio get _dio => Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (_) => true,
      ));

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.mobileAuthLogin,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300 && data != null) {
        final accessToken = data['access_token'] as String? ?? '';
        final refreshToken = data['refresh_token'] as String? ?? '';
        final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 86400;

        // Extract user — handle nested object or flat fields
        final userRaw = data['user'];
        final String userId;
        final String userEmail;
        final String userName;
        final String userRole;

        final String userPhone;
        final String userDesignation;
        final String? userSiteName;

        if (userRaw is Map<String, dynamic>) {
          userId = userRaw['id']?.toString() ?? 'usr-001';
          userEmail = userRaw['email']?.toString() ?? email;
          userName = userRaw['name']?.toString() ??
              userRaw['full_name']?.toString() ??
              email.split('@').first;
          userRole = userRaw['role']?.toString() ?? 'user';
          userPhone = userRaw['phone']?.toString() ?? '';
          userDesignation = userRaw['designation']?.toString() ?? '';
          userSiteName = userRaw['site_name']?.toString();
        } else {
          userId = data['id']?.toString() ?? 'usr-001';
          userEmail = data['email']?.toString() ?? email;
          userName = data['name']?.toString() ?? email.split('@').first;
          userRole = data['role']?.toString() ?? 'user';
          userPhone = data['phone']?.toString() ?? '';
          userDesignation = data['designation']?.toString() ?? '';
          userSiteName = data['site_name']?.toString();
        }

        await localDataSource.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
        );
        await localDataSource.saveUserId(userId);
        await localDataSource.saveUserEmail(userEmail);
        await localDataSource.saveUserName(userName);
        await localDataSource.saveUserRole(userRole);
        if (userPhone.isNotEmpty) await localDataSource.saveUserPhone(userPhone);
        if (userDesignation.isNotEmpty) {
          await localDataSource.saveUserDesignation(userDesignation);
        }
        if (userSiteName != null) {
          await localDataSource.saveUserSiteName(userSiteName);
        }

        return Success(UserEntity(
          id: userId,
          email: userEmail,
          name: userName,
          role: userRole,
          phone: userPhone.isNotEmpty ? userPhone : null,
          designation: userDesignation.isNotEmpty ? userDesignation : null,
          siteName: userSiteName,
        ));
      }

      // Extract error message — FastAPI uses "detail"
      final message = _errorMessage(data, statusCode);
      if (statusCode == 401 || statusCode == 403) {
        return ResultFailure(UnauthorizedFailure(message: message));
      }
      return ResultFailure(ServerFailure(message: message, statusCode: statusCode));
    } on DioException catch (e) {
      AppLogger.error('Login network error', e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const ResultFailure(TimeoutFailure());
      }
      return const ResultFailure(NoInternetFailure());
    } catch (e, st) {
      AppLogger.error('Login failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  String _errorMessage(Map<String, dynamic>? data, int statusCode) {
    if (data == null) return 'Login failed. Please try again.';
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map) return first['msg']?.toString() ?? 'Validation error';
    }
    return data['message']?.toString() ??
        data['error']?.toString() ??
        'Login failed. Please try again.';
  }

  @override
  Future<Result<bool>> logout() async {
    try {
      // Best-effort API call — revoke refresh token on server
      final accessToken = await localDataSource.getAccessToken();
      final refreshToken = await localDataSource.getRefreshToken();
      if (accessToken != null && refreshToken != null) {
        try {
          final dio = _dio;
          await dio.post<void>(
            ApiConstants.mobileAuthLogout,
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );
        } catch (e) {
          AppLogger.warning('Logout API call failed (ignored): $e');
        }
      }
    } finally {
      await localDataSource.clearAll();
    }
    return const Success(true);
  }

  @override
  Future<Result<bool>> checkAuthentication() async {
    try {
      final isAuthenticated = await localDataSource.isAuthenticated();
      return Success(isAuthenticated);
    } catch (e, st) {
      AppLogger.error('Auth check failed', e, st);
      return const Success(false);
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final userId = await localDataSource.getUserId();
      final email = await localDataSource.getUserEmail();
      final role = await localDataSource.getUserRole();
      if (userId == null || email == null) return const Success(null);
      final name = await localDataSource.getUserName();
      final phone = await localDataSource.getUserPhone();
      final designation = await localDataSource.getUserDesignation();
      final siteName = await localDataSource.getUserSiteName();
      return Success(UserEntity(
        id: userId,
        email: email,
        name: name ?? email.split('@').first,
        role: role ?? 'user',
        phone: phone,
        designation: designation,
        siteName: siteName,
      ));
    } catch (e, st) {
      AppLogger.error('Get current user failed', e, st);
      return const Success(null);
    }
  }

  @override
  Future<Result<bool>> refreshToken() async => const Success(true);

  @override
  Future<Result<bool>> forgotPassword({required String email}) async =>
      const Success(true);

  @override
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      const Success(true);
}
