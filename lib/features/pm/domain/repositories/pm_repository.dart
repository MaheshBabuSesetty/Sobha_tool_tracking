import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';

abstract class PmRepository {
  Future<Result<List<PmRequestEntity>>> getRequests();

  Future<Result<PmRequestDetailEntity>> getRequestDetail(int id);

  Future<Result<ActionResponseEntity>> issueTool({
    required int requestId,
    required int toolId,
    String? remarks,
  });
}
