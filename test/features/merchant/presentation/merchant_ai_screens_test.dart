import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/core/offline/cache_manager.dart';
import 'package:dukavo_mobile/core/providers.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/merchant/presentation/merchant_ai_screens.dart';
import 'package:dukavo_mobile/features/stores/application/store_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/offline/support.dart';
import '../../../helpers/test_app.dart';

const _aiPermissions = Permissions({PermissionSlugs.aiUse});

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('the copilot asks the server and renders string recommendations',
      (tester) async {
    final api = await buildTestApi(
      adapter: FakeHttpAdapter((options) async {
        if (options.path.contains('merchant-copilot')) {
          return jsonBody(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'answer': 'Focus on the three low-stock variants.',
              'period': <String, dynamic>{
                'from': '2026-10-14',
                'until': '2026-11-12',
                'timezone': 'UTC',
              },
              'scope': <String, dynamic>{
                'store_id': null,
                'store_name': null,
                'currency': 'EGP',
              },
              'facts_used': <String>['low_stock_count = 3'],
              'missing_or_insufficient': <dynamic>[],
              'estimates_and_recommendations': <String>[
                'Restock the three variants before the weekend.',
              ],
              'metric_explanations': <dynamic>[],
              'action_previews': <dynamic>[],
              'data_gaps': <String>['No sales history for the last 7 days.'],
            },
          });
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
      const MerchantCopilotScreen(),
      overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        permissionsProvider.overrideWithValue(_aiPermissions),
        storeOptionsProvider.overrideWith((ref) async => const []),
      ],
    );

    await tester.enterText(
      find.byType(EditableText).first,
      'What should I focus on?',
    );
    await tester.tap(find.text('Ask copilot'));
    await tester.pumpAndSettle();

    expect(find.text('Focus on the three low-stock variants.'), findsOneWidget);
    expect(
      find.text('Restock the three variants before the weekend.'),
      findsOneWidget,
    );
    expect(
      find.text('No sales history for the last 7 days.'),
      findsOneWidget,
    );
  });

  testWidgets('the copilot is locked without ai.use', (tester) async {
    final api = await buildTestApi(
      adapter: FakeHttpAdapter(
        (options) async =>
            jsonBody(<String, dynamic>{'success': true, 'data': {}}),
      ),
      cache: CacheManager(memoryStore()),
    );

    await pumpTestApp(
      tester,
      const MerchantCopilotScreen(),
      overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        permissionsProvider.overrideWithValue(const Permissions({})),
        storeOptionsProvider.overrideWith((ref) async => const []),
      ],
    );

    expect(find.text('Access restricted'), findsOneWidget);
  });

  testWidgets('insights render the server briefing without inventing data',
      (tester) async {
    final api = await buildTestApi(
      adapter: FakeHttpAdapter((options) async {
        if (options.path.contains('ai/insights')) {
          return jsonBody(<String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'summary': 'Revenue is up and two products are out of stock.',
              'highlights': <Map<String, dynamic>>[
                <String, dynamic>{
                  'title': 'Revenue grew',
                  'detail': 'Paid revenue rose 12%.',
                  'severity': 'positive',
                },
              ],
              'recommendations': <Map<String, dynamic>>[
                <String, dynamic>{
                  'title': 'Restock the best seller',
                  'detail': 'It is down to zero available units.',
                },
              ],
              'data_gaps': <String>['No returns recorded.'],
            },
          });
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
      const MerchantInsightsScreen(),
      overrides: <Override>[
        apiClientProvider.overrideWithValue(api),
        permissionsProvider.overrideWithValue(_aiPermissions),
        storeOptionsProvider.overrideWith((ref) async => const []),
      ],
    );

    expect(
      find.text('Revenue is up and two products are out of stock.'),
      findsOneWidget,
    );
    expect(find.text('Revenue grew'), findsOneWidget);
    expect(find.text('Restock the best seller'), findsOneWidget);
    expect(find.text('No returns recorded.'), findsOneWidget);
  });
}
