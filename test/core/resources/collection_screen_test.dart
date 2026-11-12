import 'package:dukavo_mobile/core/api/api_client.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/core/resources/collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/offline/support.dart';
import '../../helpers/test_app.dart';

void main() {
  setUpAll(preloadLocalizations);

  Future<ApiClient> apiReturning(Object body, {int statusCode = 200}) {
    return buildTestApi(
      adapter: FakeHttpAdapter(
        (options) async => jsonBody(body, statusCode: statusCode),
      ),
      cache: CacheManager(memoryStore()),
    );
  }

  testWidgets('renders a wrapped collection and its detail sheet',
      (tester) async {
    final api = await apiReturning(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'countries': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'code': 'EG',
            'name': 'Egypt',
            'name_ar': 'مصر',
            'currency': 'EGP',
            'is_active': true,
            'sort_order': 1,
          },
        ],
      },
    });

    await pumpTestApp(
      tester,
      CollectionScreen(
        titleKey: 'countries',
        path: '/platform/payments/countries',
        itemsKey: 'countries',
        icon: Icons.public_outlined,
        title: (resource) => resource.text('name'),
        subtitle: (resource) => resource.text('currency'),
        status: (resource) =>
            resource.flag('is_active') ? 'active' : 'inactive',
        fields: const <CollectionFieldSpec>[
          CollectionFieldSpec(key: 'code', labelKey: 'countryCode'),
          CollectionFieldSpec(key: 'currency', labelKey: 'currency'),
          CollectionFieldSpec(
            key: 'is_active',
            labelKey: 'active',
            type: CollectionFieldType.boolean,
          ),
        ],
        actions: <CollectionActionSpec>[
          CollectionActionSpec(
            labelKey: 'toggleCountry',
            path: (resource) => '/platform/payments/countries/EG',
            body: (resource) => <String, dynamic>{
              'is_active': !resource.flag('is_active'),
            },
          ),
        ],
      ),
      overrides: <Override>[apiClientProvider.overrideWithValue(api)],
    );

    expect(find.text('Egypt'), findsOneWidget);
    expect(find.text('EGP'), findsOneWidget);

    await tester.tap(find.text('Egypt'));
    await tester.pumpAndSettle();

    expect(find.text('Country code'), findsOneWidget);
    expect(find.text('EG'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('Toggle country'), findsOneWidget);
  });

  testWidgets('shows the empty state when the wrapped list is empty',
      (tester) async {
    final api = await apiReturning(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{'countries': <dynamic>[]},
    });

    await pumpTestApp(
      tester,
      CollectionScreen(
        titleKey: 'countries',
        path: '/platform/payments/countries',
        itemsKey: 'countries',
        icon: Icons.public_outlined,
        title: (resource) => resource.text('name'),
        emptyTitleKey: 'noCountries',
      ),
      overrides: <Override>[apiClientProvider.overrideWithValue(api)],
    );

    expect(find.text('No countries'), findsOneWidget);
  });

  testWidgets('shows the server error and retries the request', (tester) async {
    var calls = 0;
    final api = await buildTestApi(
      adapter: FakeHttpAdapter((options) async {
        calls += 1;
        return jsonBody(<String, dynamic>{
          'success': false,
          'message': 'Server unavailable',
        }, statusCode: 503);
      }),
      cache: CacheManager(memoryStore()),
    );

    await pumpTestApp(
      tester,
      CollectionScreen(
        titleKey: 'countries',
        path: '/platform/payments/countries',
        itemsKey: 'countries',
        icon: Icons.public_outlined,
        title: (resource) => resource.text('name'),
      ),
      overrides: <Override>[apiClientProvider.overrideWithValue(api)],
    );

    expect(find.text('Server unavailable'), findsOneWidget);
    expect(calls, 1);

    await tester.tap(find.byIcon(Icons.refresh).first);
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets('renders a paginated resource through the same card list',
      (tester) async {
    final api = await apiReturning(<String, dynamic>{
      'success': true,
      'data': <Map<String, dynamic>>[
        <String, dynamic>{'id': 7, 'title': 'Launch campaign'},
      ],
      'meta': <String, dynamic>{
        'current_page': 1,
        'per_page': 100,
        'total': 1,
        'last_page': 1,
      },
    });

    await pumpTestApp(
      tester,
      CollectionScreen(
        titleKey: 'campaigns',
        path: '/platform/notification-campaigns',
        paginated: true,
        icon: Icons.campaign_outlined,
        title: (resource) => resource.text('title'),
      ),
      overrides: <Override>[apiClientProvider.overrideWithValue(api)],
    );

    expect(find.text('Launch campaign'), findsOneWidget);
  });
}
