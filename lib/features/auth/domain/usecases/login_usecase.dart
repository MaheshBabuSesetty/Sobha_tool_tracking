import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/features/auth/domain/repositories/auth_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

class LoginUseCase extends UseCase<UserEntity, LoginParams> {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<UserEntity>> call(LoginParams params) => _repository.login(
        email: params.email,
        password: params.password,
      );
}
