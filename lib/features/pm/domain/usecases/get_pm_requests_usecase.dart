import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/domain/repositories/pm_repository.dart';

class GetPmRequestsUseCase {
  const GetPmRequestsUseCase(this._repository);
  final PmRepository _repository;

  Future<Result<List<PmRequestEntity>>> call() => _repository.getRequests();
}
