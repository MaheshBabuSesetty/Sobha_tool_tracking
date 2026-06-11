import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/features/auth/domain/repositories/auth_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class CheckAuthUseCase extends NoParamUseCase<UserEntity?> {
  const CheckAuthUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<UserEntity?>> call() async {
    final authResult = await _repository.checkAuthentication();
    if (authResult.isFailure) return ResultFailure(authResult.error!);
    if (authResult.data == false) return const Success(null);
    return _repository.getCurrentUser();
  }
}