library;

import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/repositories/rfid_repository.dart';

class GetPower extends UseCase<int, NoParams> {
  GetPower(this.repository);
  final RfidRepository repository;

  @override
  Future<Result<int>> call(NoParams params) => repository.getPower();
}
