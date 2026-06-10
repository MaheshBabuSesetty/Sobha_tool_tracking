import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:power_tool_tracking/core/utils/app_logger.dart';

enum ConnectionStatus { online, offline }

class ConnectivityService {
  ConnectivityService() {
    _connectivity = Connectivity();
    _initConnectivity();
  }

  late final Connectivity _connectivity;
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  ConnectionStatus _currentStatus = ConnectionStatus.online;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  ConnectionStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus == ConnectionStatus.online;
  bool get isOffline => _currentStatus == ConnectionStatus.offline;

  Future<void> _initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = !results.contains(ConnectivityResult.none);
    final newStatus = hasConnection ? ConnectionStatus.online : ConnectionStatus.offline;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      AppLogger.info('Connectivity changed: $newStatus');
    }
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
