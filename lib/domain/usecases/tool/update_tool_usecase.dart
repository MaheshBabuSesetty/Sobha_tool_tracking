import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class UpdateToolUseCase extends UseCase<ToolEntity, ToolEntity> {
  const UpdateToolUseCase(this._repository);
  final ToolRepository _repository;

  @override
  Future<Result<ToolEntity>> call(ToolEntity params) =>
      _repository.updateTool(params);
}
