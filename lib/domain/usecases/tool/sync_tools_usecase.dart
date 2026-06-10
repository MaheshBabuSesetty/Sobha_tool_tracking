import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class SyncToolsUseCase extends NoParamUseCase<int> {
  const SyncToolsUseCase(this._repository);
  final ToolRepository _repository;

  @override
  Future<Result<int>> call() => _repository.syncTools();
}
