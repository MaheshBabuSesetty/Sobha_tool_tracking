library;

import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/repositories/rfid_repository.dart';

class InitializeRfid extends UseCase<bool, NoParams> {
  InitializeRfid(this.repository);
  final RfidRepository repository;

  @override
  Future<Result<bool>> call(NoParams params) => repository.initialize();
}
