import 'package:dukavo_mobile/core/offline/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('probe results become online/offline without duplicate notifications',
      () async {
    var reachable = false;
    var now = DateTime(2026, 1, 1, 12);
    final connectivity = ConnectivityController(
      probe: () async => reachable,
      clock: () => now,
    );
    addTearDown(connectivity.dispose);

    var notifications = 0;
    connectivity.addListener(() => notifications += 1);

    await connectivity.check(force: true);
    expect(connectivity.isOffline, isTrue);
    expect(notifications, 1);
    expect(connectivity.lastOfflineAt, isNotNull);

    // A repeated probe with the same answer must not rebuild the app.
    await connectivity.check(force: true);
    expect(notifications, 1);

    reachable = true;
    now = now.add(const Duration(seconds: 1));
    await connectivity.check();
    expect(connectivity.isOffline, isTrue,
        reason: 'non-forced checks are throttled');

    now = now.add(const Duration(seconds: 6));
    await connectivity.check();
    expect(connectivity.isOnline, isTrue);
    expect(notifications, 2);
    expect(connectivity.lastOnlineAt, isNotNull);

    await connectivity.check(force: true);
    expect(notifications, 2);
  });

  test('API signals override a stale probe result', () async {
    final connectivity = ConnectivityController(
      probe: () async => false,
    );
    addTearDown(connectivity.dispose);

    connectivity.reportSuccess();
    expect(connectivity.isOnline, isTrue);

    connectivity.reportNetworkFailure();
    expect(connectivity.isOffline, isTrue);
    expect(connectivity.lastOfflineAt, isNotNull);
  });

  test('a throwing probe is treated as offline', () async {
    final connectivity = ConnectivityController(
      probe: () async => throw StateError('no network'),
    );
    addTearDown(connectivity.dispose);

    await connectivity.check(force: true);
    expect(connectivity.isOffline, isTrue);
  });
}
