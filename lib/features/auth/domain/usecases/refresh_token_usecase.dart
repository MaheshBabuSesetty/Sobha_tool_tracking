import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/auth/domain/repositories/auth_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class RefreshTokenUseCase extends NoParamUseCase<bool> {
  const RefreshTokenUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Result<bool>> call() => _repository.refreshToken();
}
