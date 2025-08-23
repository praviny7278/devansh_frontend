import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  void startMonitoring(void Function(ConnectivityResult result) onChanged) {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      onChanged(result); // Callback with the latest result
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
