import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    // Initial check
    _checkConnectivity();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      final List<ConnectivityResult> results = [result];
      connectionStatusController.add(_getStatusFromResults(results));
    } catch (e) {
      connectionStatusController.add(false);
    }
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    final List<ConnectivityResult> results = [result];
    return _getStatusFromResults(results);
  }

  bool _getStatusFromResults(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    connectionStatusController.close();
  }
}
