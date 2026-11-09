import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/shipping/application/shipping_controller.dart';
import 'package:dukavo_mobile/features/shipping/domain/shipping_domain.dart';
import 'package:dukavo_mobile/features/shipping/presentation/shipping_zones_screen.dart';
import 'package:dukavo_mobile/features/stores/application/store_controller.dart';
import 'package:dukavo_mobile/features/stores/domain/store_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

class _FakeShippingRepository implements ShippingRepository {
  _FakeShippingRepository({this.zones = const []});

  final List<ShippingZone> zones;

  @override
  Future<List<ShippingZone>> list(int storeId) async => zones;

  @override
  Future<ShippingZone> create(int storeId, ShippingZoneDraft draft) async {
    throw UnimplementedError();
  }

  @override
  Future<ShippingZone> update(
    int storeId,
    int zoneId,
    ShippingZoneDraft draft,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int storeId, int zoneId) async {}
}

const _zone = ShippingZone(
  id: 9,
  name: 'Cairo delivery',
  city: 'Cairo',
  fee: 15,
  isActive: true,
  sortOrder: 0,
);

const _store = Store(
  id: 4,
  name: 'Maadi shop',
  slug: 'maadi-shop',
  status: 'active',
  isDefault: true,
  currency: 'EGP',
  timezone: 'Africa/Cairo',
);

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('shows the empty state and hides management for view-only roles',
      (tester) async {
    await pumpTestApp(
      tester,
      const ShippingZonesScreen(),
      overrides: [
        storeOptionsProvider.overrideWith((ref) async => [_store]),
        shippingRepositoryProvider.overrideWithValue(_FakeShippingRepository()),
        permissionsProvider.overrideWithValue(
          const Permissions({PermissionSlugs.shippingView}),
        ),
      ],
    );

    expect(find.text('No shipping zones yet'), findsOneWidget);
    expect(find.text('Add shipping zone'), findsNothing);
  });

  testWidgets('the editor switches to Arabic without losing English fields',
      (tester) async {
    await pumpTestApp(
      tester,
      const ShippingZonesScreen(),
      overrides: [
        storeOptionsProvider.overrideWith((ref) async => [_store]),
        shippingRepositoryProvider.overrideWithValue(
          _FakeShippingRepository(zones: const [_zone]),
        ),
        permissionsProvider.overrideWithValue(
          const Permissions({PermissionSlugs.shippingManage}),
        ),
      ],
    );

    expect(find.text('Cairo delivery'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Cairo delivery'), findsWidgets);

    await tester.tap(find.text('العربية').last);
    await tester.pumpAndSettle();

    expect(find.text('Arabic missing'), findsOneWidget);

    // Switching back keeps the English copy the form started with.
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(find.text('Cairo delivery'), findsWidgets);
    expect(find.text('Arabic missing'), findsNothing);
  });
}
