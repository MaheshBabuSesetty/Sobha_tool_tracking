import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/tools/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/features/tools/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class GetToolsUseCase extends UseCase<List<ToolEntity>, ToolFilter?> {
  const GetToolsUseCase(this._repository);
  final ToolRepository _repository;

  @override
  Future<Result<List<ToolEntity>>> call(ToolFilter? params) =>
      _repository.getTools(filter: params);
}
