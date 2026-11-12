import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/merchant/presentation/inventory_transfer_screen.dart';
import 'package:dukavo_mobile/features/stores/application/store_controller.dart';
import 'package:dukavo_mobile/features/stores/domain/store_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/offline/support.dart';
import '../../../helpers/test_app.dart';

const _store = Store(
  id: 1,
  name: 'Maadi shop',
  slug: 'maadi-shop',
  status: 'active',
  isDefault: true,
  currency: 'EGP',
  timezone: 'Africa/Cairo',
);

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('requires a second store before a transfer can be made',
      (tester) async {
    final api = await buildTestApi(
      adapter: FakeHttpAdapter(
        (options) async =>
            jsonBody(<String, dynamic>{'success': true, 'data': <dynamic>[]}),
      ),
      cache: CacheManager(memoryStore()),
    );

    await pumpTestApp(
      tester,
      const InventoryTransferScreen(),
      overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        permissionsProvider.overrideWithValue(
          const Permissions({
            PermissionSlugs.inventoryView,
            PermissionSlugs.inventoryManage,
          }),
        ),
        storeOptionsProvider.overrideWith((ref) async => const [_store]),
      ],
    );

    expect(find.text('Two stores are required'), findsOneWidget);
  });

  testWidgets('is locked without the inventory view grant', (tester) async {
    final api = await buildTestApi(
      adapter: FakeHttpAdapter(
        (options) async =>
            jsonBody(<String, dynamic>{'success': true, 'data': <dynamic>[]}),
      ),
      cache: CacheManager(memoryStore()),
    );

    await pumpTestApp(
      tester,
      const InventoryTransferScreen(),
      overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        permissionsProvider.overrideWithValue(const Permissions({})),
        storeOptionsProvider.overrideWith((ref) async => const [_store]),
      ],
    );

    expect(find.text('Access restricted'), findsOneWidget);
  });
}
