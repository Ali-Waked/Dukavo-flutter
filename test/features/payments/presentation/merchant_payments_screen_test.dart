import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/payments/presentation/merchant_payments_screen.dart';
import 'package:dukavo_mobile/features/stores/application/store_controller.dart';
import 'package:dukavo_mobile/features/stores/domain/store_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/offline/support.dart';
import '../../../helpers/test_app.dart';

const _store = Store(
  id: 4,
  name: 'Maadi shop',
  slug: 'maadi-shop',
  status: 'active',
  isDefault: true,
  currency: 'EGP',
  timezone: 'Africa/Cairo',
);

Map<String, dynamic> _connections() => <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'connections': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 11,
            'store_id': 4,
            'provider': <String, dynamic>{
              'code': 'paymob',
              'name': 'Paymob',
            },
            'status': 'active',
            'status_label': 'Active',
            'environment': 'sandbox',
            'merchant_reference': 'maadi',
            'has_credentials': true,
            'has_webhook_secret': true,
            'last_error': null,
          },
        ],
        'providers': <Map<String, dynamic>>[
          <String, dynamic>{'code': 'paymob', 'name': 'Paymob'},
        ],
      },
    };

Map<String, dynamic> _payments() => <String, dynamic>{
      'success': true,
      'data': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 21,
          'order_id': 5,
          'order_number': 'ORD-1001',
          'store_id': 4,
          'status': 'succeeded',
          'status_label': 'Succeeded',
          'method_code': 'card',
          'amount': 100.0,
          'currency': 'EGP',
          'provider': <String, dynamic>{
            'code': 'paymob',
            'name': 'Paymob',
          },
          'reference': '•••• 1234',
          'failure_reason': null,
          'paid_at': '2026-11-10T10:00:00Z',
          'created_at': '2026-11-10T09:59:00Z',
        },
      ],
      'meta': <String, dynamic>{
        'current_page': 1,
        'per_page': 50,
        'total': 1,
        'last_page': 1,
      },
    };

Future<void> _pump(WidgetTester tester, Set<String> permissions) async {
  final api = await buildTestApi(
    adapter: FakeHttpAdapter((options) async {
      if (options.path.contains('/payment-connections')) {
        return jsonBody(_connections());
      }
      if (options.path.contains('/tenant/payments')) {
        return jsonBody(_payments());
      }
      return jsonBody(<String, dynamic>{
        'success': true,
        'data': <String, dynamic>{'data': <dynamic>[]},
      });
    }),
    cache: CacheManager(memoryStore()),
  );

  await pumpTestApp(
    tester,
    const MerchantPaymentsScreen(),
    overrides: <Override>[
      apiClientProvider.overrideWithValue(api),
      permissionsProvider.overrideWithValue(Permissions(permissions)),
      storeOptionsProvider.overrideWith((ref) async => const [_store]),
    ],
  );
}

Future<void> _goHistory(WidgetTester tester) async {
  await tester.tap(find.text('Payment history'));
  await tester.pumpAndSettle();
}

Future<void> _openPayment(WidgetTester tester) async {
  await tester.tap(find.textContaining('ORD-1001').last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('shows connections and payment history from the server',
      (tester) async {
    await _pump(tester, <String>{PermissionSlugs.paymentsView});

    expect(find.text('Paymob'), findsOneWidget);
    expect(find.text('Sandbox'), findsOneWidget);
    expect(find.text('Yes'), findsWidgets);

    await _goHistory(tester);

    expect(find.textContaining('ORD-1001'), findsOneWidget);

    await _openPayment(tester);
    expect(find.text('Succeeded'), findsWidgets);
  });

  testWidgets('a view-only role gets no sync or refund action', (tester) async {
    await _pump(tester, <String>{PermissionSlugs.paymentsView});
    await _goHistory(tester);
    await _openPayment(tester);

    expect(find.text('Sync payment'), findsNothing);
    expect(find.text('Refund payment'), findsNothing);
  });

  testWidgets('the refund action follows the server refund grant',
      (tester) async {
    await _pump(tester, <String>{
      PermissionSlugs.paymentsView,
      PermissionSlugs.paymentsRefund,
    });
    await _goHistory(tester);
    await _openPayment(tester);

    expect(find.text('Refund payment'), findsOneWidget);
    expect(find.text('Sync payment'), findsNothing);
  });
}
