import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

enum ConnectivityStatus {
  /// No probe has answered yet. Reads may still try the network.
  unknown,

  /// The API answered, or a request completed successfully.
  online,

  /// A probe or an API call failed to reach the server.
  offline,
}

/// Watches reachability without a platform connectivity plugin.
///
/// The app already has one HTTP client, so reachability is derived from the
/// same source of truth: a small public probe and the success/failure of real
/// API calls. This works in every build variant and cannot disagree with the
/// requests it is describing.
class ConnectivityController extends ChangeNotifier
    with WidgetsBindingObserver {
  ConnectivityController({
    Future<bool> Function()? probe,
    DateTime Function()? clock,
    this.probeInterval = const Duration(seconds: 30),
  })  : _probe = probe,
        _clock = clock ?? DateTime.now;

  Future<bool> Function()? _probe;
  final DateTime Function() _clock;
  final Duration probeInterval;

  ConnectivityStatus _status = ConnectivityStatus.unknown;
  DateTime? _lastProbeAt;
  DateTime? _lastOnlineAt;
  DateTime? _lastOfflineAt;
  Timer? _timer;
  bool _probing = false;
  bool _started = false;

  ConnectivityStatus get status => _status;
  bool get isOnline => _status == ConnectivityStatus.online;
  bool get isOffline => _status == ConnectivityStatus.offline;
  bool get isUnknown => _status == ConnectivityStatus.unknown;
  DateTime? get lastOnlineAt => _lastOnlineAt;
  DateTime? get lastOfflineAt => _lastOfflineAt;

  void start({
    Future<bool> Function()? probe,
    WidgetsBinding? binding,
  }) {
    if (probe != null) _probe = probe;
    if (_started) return;
    _started = true;

    final target = binding ?? WidgetsBinding.instance;
    target.addObserver(this);
    unawaited(check(force: true));

    _timer?.cancel();
    _timer = Timer.periodic(probeInterval, (_) {
      // Online state is refreshed lazily by real API calls; when offline or
      // still unknown we actively look for a return.
      if (!isOnline) {
        unawaited(check(force: true));
      }
    });
  }

  /// Probe now. Concurrent callers share the in-flight probe, and repeated
  /// checks are throttled unless [force] is set.
  Future<void> check({bool force = false}) async {
    if (_probing) return;
    final probe = _probe;
    if (probe == null) return;
    if (!force) {
      final last = _lastProbeAt;
      if (last != null &&
          _clock().difference(last) < const Duration(seconds: 5)) {
        return;
      }
    }

    _probing = true;
    _lastProbeAt = _clock();
    try {
      final reachable = await probe();
      _setStatus(
        reachable ? ConnectivityStatus.online : ConnectivityStatus.offline,
      );
    } catch (_) {
      _setStatus(ConnectivityStatus.offline);
    } finally {
      _probing = false;
    }
  }

  /// A real API call completed, which is stronger evidence than a probe.
  void reportSuccess() {
    _lastOnlineAt = _clock();
    _setStatus(ConnectivityStatus.online);
  }

  /// A real API call could not reach the server.
  void reportNetworkFailure() {
    _lastOfflineAt = _clock();
    _setStatus(ConnectivityStatus.offline);
  }

  void _setStatus(ConnectivityStatus next) {
    if (next == ConnectivityStatus.online) _lastOnlineAt = _clock();
    if (next == ConnectivityStatus.offline) _lastOfflineAt = _clock();
    if (_status == next) return;
    _status = next;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning to the foreground is a natural moment to check; requests are
    // also about to resume.
    if (state == AppLifecycleState.resumed && !isOnline) {
      unawaited(check(force: true));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
      _started = false;
    }
    super.dispose();
  }
}

/// A tiny GET against a public endpoint. Any HTTP response proves the server is
/// reachable; only a transport failure counts as offline.
class HttpConnectivityProbe {
  HttpConnectivityProbe({
    required String baseUrl,
    Dio? dio,
    this.path = '/public/faq',
    this.timeout = const Duration(seconds: 4),
  })  : _baseUrl = baseUrl,
        _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
                validateStatus: (_) => true,
                headers: const {'Accept': 'application/json'},
              ),
            );

  final String _baseUrl;
  final Dio _dio;
  final String path;
  final Duration timeout;

  Future<bool> call() async {
    try {
      final response = await _dio.get<dynamic>(
        '$_baseUrl$path',
        options: Options(
          validateStatus: (_) => true,
          receiveTimeout: timeout,
          sendTimeout: timeout,
        ),
      );
      return response.statusCode != null;
    } catch (_) {
      return false;
    }
  }
}
