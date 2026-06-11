import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/core/utils/result.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<bool>> logout();

  Future<Result<bool>> checkAuthentication();

  Future<Result<UserEntity?>> getCurrentUser();

  Future<Result<bool>> refreshToken();

  Future<Result<bool>> forgotPassword({required String email});

  Future<Result<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
