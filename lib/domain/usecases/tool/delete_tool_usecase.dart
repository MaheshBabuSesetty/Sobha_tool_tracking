import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/repositories/tool_repository.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';

class DeleteToolUseCase extends UseCase<bool, String> {
  const DeleteToolUseCase(this._repository);
  final ToolRepository _repository;

  @override
  Future<Result<bool>> call(String params) => _repository.deleteTool(params);
}
