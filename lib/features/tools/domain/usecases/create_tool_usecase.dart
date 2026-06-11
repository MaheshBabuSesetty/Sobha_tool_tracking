import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/features/tools/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class CreateToolUseCase extends UseCase<ToolEntity, ToolEntity> {
  const CreateToolUseCase(this._repository);
  final ToolRepository _repository;

  @override
  Future<Result<ToolEntity>> call(ToolEntity params) =>
      _repository.createTool(params);
}
