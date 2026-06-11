import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/domain/repositories/pm_repository.dart';

class PmIssueToolUseCase {
  const PmIssueToolUseCase(this._repository);
  final PmRepository _repository;

  Future<Result<ActionResponseEntity>> call({
    required int requestId,
    required int toolId,
    String? remarks,
  }) =>
      _repository.issueTool(
        requestId: requestId,
        toolId: toolId,
        remarks: remarks,
      );
}
