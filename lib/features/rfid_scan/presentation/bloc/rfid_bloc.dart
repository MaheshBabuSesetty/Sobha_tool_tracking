library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:power_tool_tracking/domain/usecases/base_usecase.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/entities/rfid_tag.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/dispose_rfid.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/get_power.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/initialize_rfid.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/set_power.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/start_scan.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/stop_scan.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/watch_connection_state.dart';
import 'package:power_tool_tracking/features/rfid_scan/domain/usecases/watch_tags.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_event.dart';
import 'package:power_tool_tracking/features/rfid_scan/presentation/bloc/rfid_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _powerPrefKey = 'rfid_power_level';
const int _defaultPower = 2700;
const int _minPower = 700;
const int _maxPower = 3300;
const Duration _debounceDuration = Duration(milliseconds: 500);

class RfidBloc extends Bloc<RfidEvent, RfidState> {
  final InitializeRfid _initializeRfid;
  final StartScan _startScan;
  final StopScan _stopScan;
  final WatchTags _watchTags;
  final WatchConnectionState _watchConnectionState;
  final SetPower _setPower;
  final GetPower _getPower;
  final DisposeRfid _disposeRfid;
  final SharedPreferences _prefs;

  StreamSubscription<dynamic>? _tagSubscription;
  StreamSubscription<String>? _connectionSubscription;

  final Map<String, RfidTag> _tagMap = {};
  final Map<String, RfidTag> _pendingTags = {};
  Timer? _debounceTimer;
  bool _wasScanningBeforeDisconnect = false;

  RfidBloc({
    required InitializeRfid initializeRfid,
    required StartScan startScan,
    required StopScan stopScan,
    required WatchTags watchTags,
    required WatchConnectionState watchConnectionState,
    required SetPower setPower,
    required GetPower getPower,
    required DisposeRfid disposeRfid,
    required SharedPreferences prefs,
  })  : _initializeRfid = initializeRfid,
        _startScan = startScan,
        _stopScan = stopScan,
        _watchTags = watchTags,
        _watchConnectionState = watchConnectionState,
        _setPower = setPower,
        _getPower = getPower,
        _disposeRfid = disposeRfid,
        _prefs = prefs,
        super(RfidState(currentPower: _loadSavedPower(prefs))) {
    on<RfidInitializeEvent>(_onInitialize);
    on<RfidStartScanEvent>(_onStartScan);
    on<RfidStopScanEvent>(_onStopScan);
    on<RfidTagReceivedEvent>(_onTagReceived);
    on<RfidFlushTagsEvent>(_onFlushTags);
    on<RfidSetPowerEvent>(_onSetPower);
    on<RfidClearTagsEvent>(_onClearTags);
    on<RfidErrorEvent>(_onError);
    on<RfidConnectionStateChangedEvent>(_onConnectionStateChanged);
    on<RfidDisposeEvent>(_onDispose);
  }

  static int _loadSavedPower(SharedPreferences prefs) {
    final saved = prefs.getInt(_powerPrefKey);
    if (saved == null) return _defaultPower;
    if (saved >= _minPower && saved <= _maxPower) return saved;
    if (saved >= 0 && saved <= 33) return (saved * 100).clamp(_minPower, _maxPower);
    return _defaultPower;
  }

  Future<void> _savePower(int power) => _prefs.setInt(_powerPrefKey, power);

  Future<void> _onInitialize(
    RfidInitializeEvent event,
    Emitter<RfidState> emit,
  ) async {
    emit(state.copyWith(
      connectionState: RfidConnectionState.connecting,
      isError: false,
      errorMessage: null,
    ));

    _setupConnectionStream();

    final result = await _initializeRfid(const NoParams());

    await result.fold(
      onFailure: (failure) async {
        emit(state.copyWith(
          connectionState: RfidConnectionState.failed,
          isError: true,
          errorMessage: failure.message,
        ));
      },
      onSuccess: (success) async {
        if (success) {
          _setupTagStream();

          final savedPower = _prefs.getInt(_powerPrefKey) ?? _defaultPower;
          await _setPower(IntParams(savedPower));

          final powerResult = await _getPower(const NoParams());
          final currentPower = powerResult.fold(
            onFailure: (_) => savedPower,
            onSuccess: (power) => power,
          );

          emit(state.copyWith(
            connectionState: RfidConnectionState.connected,
            currentPower: currentPower,
            isError: false,
            errorMessage: null,
          ));
        } else {
          emit(state.copyWith(
            connectionState: RfidConnectionState.failed,
            isError: true,
            errorMessage: 'RFID initialization returned false',
          ));
        }
      },
    );
  }

  void _setupConnectionStream() {
    _connectionSubscription?.cancel();
    _connectionSubscription = _watchConnectionState(const NoParams()).listen(
      (stateString) => add(RfidConnectionStateChangedEvent(stateString)),
      onError: (Object error) => add(RfidErrorEvent('Connection error: $error')),
    );
  }

  void _setupTagStream() {
    _tagSubscription?.cancel();
    _tagSubscription = _watchTags(const NoParams()).listen(
      (result) {
        result.fold(
          onFailure: (failure) => add(RfidErrorEvent(failure.message)),
          onSuccess: (tag) => add(RfidTagReceivedEvent(tag)),
        );
      },
      onError: (Object error) => add(RfidErrorEvent(error.toString())),
    );
  }

  Future<void> _onConnectionStateChanged(
    RfidConnectionStateChangedEvent event,
    Emitter<RfidState> emit,
  ) async {
    final newState = RfidConnectionStateX.fromString(event.state);

    if (newState == RfidConnectionState.disconnected && state.isScanning) {
      _wasScanningBeforeDisconnect = true;
    }

    emit(state.copyWith(
      connectionState: newState,
      isScanning: newState.isReady ? state.isScanning : false,
    ));

    if (newState == RfidConnectionState.connected && _wasScanningBeforeDisconnect) {
      _wasScanningBeforeDisconnect = false;
      add(const RfidStartScanEvent());
    }
  }

  Future<void> _onStartScan(
    RfidStartScanEvent event,
    Emitter<RfidState> emit,
  ) async {
    if (!state.isReady) {
      emit(state.withError('RFID not connected'));
      return;
    }

    final result = await _startScan(const NoParams());

    result.fold(
      onFailure: (failure) => emit(state.withError(failure.message)),
      onSuccess: (success) {
        if (success) {
          emit(state.copyWith(isScanning: true, isError: false, errorMessage: null));
        } else {
          emit(state.withError('Failed to start scan'));
        }
      },
    );
  }

  Future<void> _onStopScan(
    RfidStopScanEvent event,
    Emitter<RfidState> emit,
  ) async {
    _wasScanningBeforeDisconnect = false;

    final result = await _stopScan(const NoParams());

    result.fold(
      onFailure: (failure) => emit(state.withError(failure.message)),
      onSuccess: (_) {
        _flushPendingTags(emit);
        emit(state.copyWith(isScanning: false, isError: false, errorMessage: null));
      },
    );
  }

  void _onTagReceived(RfidTagReceivedEvent event, Emitter<RfidState> emit) {
    if (!state.isScanning) return;

    final tag = event.tag;
    final existing = _tagMap[tag.epc];

    _tagMap[tag.epc] = existing != null
        ? RfidTag(
            epc: tag.epc,
            rssi: tag.rssi,
            antennaId: tag.antennaId,
            readCount: existing.readCount + tag.readCount,
            scannedAt: existing.scannedAt,
            lastSeenMs: tag.lastSeenMs,
          )
        : tag;

    _pendingTags[tag.epc] = _tagMap[tag.epc]!;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () => add(const RfidFlushTagsEvent()));
  }

  void _onFlushTags(RfidFlushTagsEvent event, Emitter<RfidState> emit) =>
      _flushPendingTags(emit);

  void _flushPendingTags(Emitter<RfidState> emit) {
    if (_pendingTags.isEmpty) return;

    final allTags = _tagMap.values.toList();
    final totalReadCount = allTags.fold<int>(0, (sum, tag) => sum + tag.readCount);

    emit(state.copyWith(tags: allTags, totalTagCount: totalReadCount));
    _pendingTags.clear();
  }

  Future<void> _onSetPower(RfidSetPowerEvent event, Emitter<RfidState> emit) async {
    final power = event.power.clamp(0, 3300);

    final result = await _setPower(IntParams(power));

    await result.fold(
      onFailure: (failure) async => emit(state.withError(failure.message)),
      onSuccess: (success) async {
        if (success) {
          await _savePower(power);
          emit(state.copyWith(
            currentPower: power,
            isError: false,
            errorMessage: null,
          ));
        }
      },
    );
  }

  void _onClearTags(RfidClearTagsEvent event, Emitter<RfidState> emit) {
    _tagMap.clear();
    _pendingTags.clear();
    _debounceTimer?.cancel();
    emit(state.copyWith(tags: [], totalTagCount: 0));
  }

  void _onError(RfidErrorEvent event, Emitter<RfidState> emit) =>
      emit(state.withError(event.message));

  Future<void> _onDispose(RfidDisposeEvent event, Emitter<RfidState> emit) async {
    _debounceTimer?.cancel();
    await _tagSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _tagSubscription = null;
    _connectionSubscription = null;
    _tagMap.clear();
    _pendingTags.clear();
    _wasScanningBeforeDisconnect = false;

    await _disposeRfid(const NoParams());
    emit(const RfidState());
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _tagSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _tagSubscription = null;
    _connectionSubscription = null;
    _tagMap.clear();
    _pendingTags.clear();
    return super.close();
  }
}
