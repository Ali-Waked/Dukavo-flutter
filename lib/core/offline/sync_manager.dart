import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import 'connectivity.dart';
import 'offline_queue.dart';

/// Coordinates the work that must happen when the connection returns.
///
/// It never navigates. The router keeps owning auth and permissions; this class
/// only flushes the safe queue and publishes a refresh epoch that list screens
/// listen to.
class SyncManager extends ChangeNotifier {
  SyncManager({
    required ConnectivityController connectivity,
    required OfflineMutationQueue queue,
    required ApiClient api,
    DateTime Function()? clock,
    this.reconnectDelay = const Duration(milliseconds: 600),
  })  : _connectivity = connectivity,
        _queue = queue,
        _api = api,
        _clock = clock ?? DateTime.now;

  final ConnectivityController _connectivity;
  final OfflineMutationQueue _queue;
  final ApiClient _api;
  final DateTime Function() _clock;

  /// The pause before replaying after the connection returns, so the probe's
  /// own request can settle first.
  final Duration reconnectDelay;

  ConnectivityStatus _previous = ConnectivityStatus.unknown;
  Timer? _onlineTimer;
  bool _started = false;
  bool _syncing = false;
  int _epoch = 0;
  DateTime? _lastSyncedAt;

  int get epoch => _epoch;
  bool get isSyncing => _syncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  int get pendingMutations => _queue.length;

  void start() {
    if (_started) return;
    _started = true;
    _previous = _connectivity.status;
    _connectivity.addListener(_onConnectivity);
    _queue.addListener(_onQueue);
    if (_connectivity.isOnline) {
      unawaited(syncNow());
    }
  }

  void _onConnectivity() {
    final current = _connectivity.status;
    final detectedOnline = current == ConnectivityStatus.online &&
        _previous != ConnectivityStatus.online;

    if (current == ConnectivityStatus.offline) {
      _cancelOnlineTimer();
    }

    _previous = current;

    if (!detectedOnline) return;

    // Let the probe's request settle before flooding the connection with
    // queued work and refreshes.
    _cancelOnlineTimer();
    _onlineTimer = Timer(reconnectDelay, () {
      unawaited(syncNow());
    });
  }

  /// Flush queued safe mutations and publish a refresh epoch.
  ///
  /// Refresh-only callers (for example a manual "try again") can pass
  /// [flushQueue] false.
  Future<void> syncNow({bool flushQueue = true}) async {
    if (_syncing) return;
    _syncing = true;
    notifyListeners();

    try {
      if (flushQueue && _connectivity.isOnline) {
        await _queue.flush(
          execute: (mutation) => _api.replayMutation(
            mutation.method,
            mutation.path,
            body: mutation.body,
            csrf: mutation.csrf,
          ),
          isOnline: () => _connectivity.isOnline,
        );
      }
      _lastSyncedAt = _clock();
      _epoch += 1;
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  void _onQueue() => notifyListeners();

  @override
  void dispose() {
    _cancelOnlineTimer();
    _connectivity.removeListener(_onConnectivity);
    _queue.removeListener(_onQueue);
    super.dispose();
  }

  void _cancelOnlineTimer() {
    _onlineTimer?.cancel();
    _onlineTimer = null;
  }
}
