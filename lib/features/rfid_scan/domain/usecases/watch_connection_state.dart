library;

import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/repositories/rfid_repository.dart';

class WatchConnectionState {
  WatchConnectionState(this.repository);
  final RfidRepository repository;

  Stream<String> call(NoParams params) => repository.watchConnectionState();
}
