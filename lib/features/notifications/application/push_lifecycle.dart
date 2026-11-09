import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../auth/application/auth_controller.dart';
import 'push_service.dart';

/// Connects the push transport to the signed-in session and the router.
///
/// The service itself knows nothing about auth or navigation: it can be tested
/// with a fake API and a captured tap stream. This coordinator is the single
/// place that decides when a token is registered, and where a tap lands.
class PushLifecycle {
  PushLifecycle(this._ref, this._service);

  final Ref _ref;
  final PushService _service;

  ProviderSubscription<AuthState>? _auth;
  StreamSubscription<String>? _taps;
  int? _userId;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;

    _taps = _service.taps.listen(_navigate);

    _auth = _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final user = next.session?.user;

      if (next.isAuthenticated && user != null) {
        if (_userId != user.id) {
          _userId = user.id;
          unawaited(_service.syncDeviceToken());
        }
        return;
      }

      if (_userId != null && !next.isAuthenticated) {
        // Logout already revoked the token before the session moved to
        // unauthenticated; clearing here covers a 401 expiry as well.
        _userId = null;
        unawaited(_service.unregisterToken());
      }
    });

    final initial = _ref.read(authControllerProvider);
    if (initial.isAuthenticated && initial.session != null) {
      _userId = initial.session!.user.id;
      unawaited(_service.syncDeviceToken());
    } else {
      // Warm Firebase even when signed out so the first login does not wait
      // for SDK initialisation on the critical path.
      unawaited(_service.initialize());
    }
  }

  void _navigate(String path) {
    if (path.isEmpty) return;
    _ref.read(appRouterProvider).go(path);
  }

  void dispose() {
    _auth?.close();
    _taps?.cancel();
  }
}

final pushLifecycleProvider = Provider<PushLifecycle>((ref) {
  final lifecycle = PushLifecycle(ref, ref.watch(pushServiceProvider));

  ref.onDispose(lifecycle.dispose);
  lifecycle.start();

  return lifecycle;
});
