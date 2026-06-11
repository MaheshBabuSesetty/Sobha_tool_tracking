library;

import 'package:get_it/get_it.dart';
import 'package:power_tool_tracking/features/rfid_scan/data/datasources/rfid_local_datasource.dart';
import 'package:power_tool_tracking/features/rfid_scan/data/repositories/rfid_repository_impl.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/repositories/rfid_repository.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/dispose_rfid.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/get_power.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/initialize_rfid.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/set_power.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/start_scan.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/stop_scan.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/watch_connection_state.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/watch_tags.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_bloc.dart';

class RfidModule {
  RfidModule._();

  static void register(GetIt sl) {
    sl.registerFactory<RfidBloc>(
      () => RfidBloc(
        initializeRfid: sl(),
        startScan: sl(),
        stopScan: sl(),
        watchTags: sl(),
        watchConnectionState: sl(),
        setPower: sl(),
        getPower: sl(),
        disposeRfid: sl(),
        prefs: sl(),
      ),
    );

    sl.registerLazySingleton<InitializeRfid>(() => InitializeRfid(sl()));
    sl.registerLazySingleton<StartScan>(() => StartScan(sl()));
    sl.registerLazySingleton<StopScan>(() => StopScan(sl()));
    sl.registerLazySingleton<WatchTags>(() => WatchTags(sl()));
    sl.registerLazySingleton<WatchConnectionState>(() => WatchConnectionState(sl()));
    sl.registerLazySingleton<SetPower>(() => SetPower(sl()));
    sl.registerLazySingleton<GetPower>(() => GetPower(sl()));
    sl.registerLazySingleton<DisposeRfid>(() => DisposeRfid(sl()));

    sl.registerLazySingleton<RfidRepository>(
      () => RfidRepositoryImpl(datasource: sl()),
    );

    sl.registerLazySingleton<RfidLocalDatasource>(
      () => RfidLocalDatasourceImpl(),
    );
  }
}
