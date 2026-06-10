import 'package:power_tool_tracking/core/errors/failures.dart';
import 'package:power_tool_tracking/core/services/connectivity_service.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';
import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/data/datasources/local/auth_local_datasource.dart';
import 'package:power_tool_tracking/data/datasources/remote/auth_remote_datasource.dart';
import 'package:power_tool_tracking/data/mappers/auth_mapper.dart';
import 'package:power_tool_tracking/data/models/auth/login_request_model.dart';
import 'package:power_tool_tracking/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      final result = await remoteDataSource.login(request);

      return result.fold(
        onSuccess: (response) async {
          await localDataSource.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn,
          );
          await localDataSource.saveUserId(response.user.id);
          await localDataSource.saveUserEmail(response.user.email);
          await localDataSource.saveUserRole(response.user.role);

          return Success(response.user.toEntity());
        },
        onFailure: (failure) => ResultFailure(failure),
      );
    } catch (e, st) {
      AppLogger.error('Login failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> logout() async {
    try {
      if (connectivityService.isOnline) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearAll();
      return const Success(true);
    } catch (e, st) {
      AppLogger.error('Logout error', e, st);
      await localDataSource.clearAll();
      return const Success(true);
    }
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

      return Success(UserEntity(
        id: userId,
        email: email,
        name: email.split('@').first,
        role: role ?? 'user',
      ));
    } catch (e, st) {
      AppLogger.error('Get current user failed', e, st);
      return const Success(null);
    }
  }

  @override
  Future<Result<bool>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) return const ResultFailure(UnauthorizedFailure());

      final result = await remoteDataSource.refreshToken(refreshToken);
      return result.fold(
        onSuccess: (response) async {
          await localDataSource.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn,
          );
          return const Success(true);
        },
        onFailure: (failure) => ResultFailure(failure),
      );
    } catch (e, st) {
      AppLogger.error('Token refresh failed', e, st);
      return const ResultFailure(UnauthorizedFailure());
    }
  }

  @override
  Future<Result<bool>> forgotPassword({required String email}) async {
    try {
      return await remoteDataSource.forgotPassword(email);
    } catch (e, st) {
      AppLogger.error('Forgot password failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e, st) {
      AppLogger.error('Change password failed', e, st);
      return ResultFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
