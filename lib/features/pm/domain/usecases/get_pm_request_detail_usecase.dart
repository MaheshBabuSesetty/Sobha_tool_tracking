import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/features/pm/domain/entities/pm_request_entity.dart';
import 'package:power_tool_tracking/features/pm/domain/repositories/pm_repository.dart';

class GetPmRequestDetailUseCase {
  const GetPmRequestDetailUseCase(this._repository);
  final PmRepository _repository;

  Future<Result<PmRequestDetailEntity>> call(int id) =>
      _repository.getRequestDetail(id);
}
