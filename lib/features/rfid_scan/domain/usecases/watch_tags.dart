library;

import 'package:power_tool_tracking/core/utils/result.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/repositories/rfid_repository.dart';

class WatchTags {
  WatchTags(this.repository);
  final RfidRepository repository;

  Stream<Result<RfidTag>> call(NoParams params) => repository.watchTags();
}
