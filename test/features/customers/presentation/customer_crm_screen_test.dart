import 'package:dukavo_mobile/core/auth/permissions.dart';
import 'package:dukavo_mobile/features/auth/application/auth_controller.dart';
import 'package:dukavo_mobile/features/customers/application/customer_crm_controller.dart';
import 'package:dukavo_mobile/features/customers/data/customer_crm_data.dart';
import 'package:dukavo_mobile/features/customers/domain/customer_crm_domain.dart';
import 'package:dukavo_mobile/features/customers/domain/customer_domain.dart';
import 'package:dukavo_mobile/features/customers/presentation/customer_crm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

class _FakeCrmRepository implements CustomerCrmRepository {
  int refreshCount = 0;

  static const _customer = Customer(
    id: 7,
    name: 'Nada Hassan',
    status: 'active',
    phone: '+201000000000',
  );

  CustomerSummary get _summary => refreshCount == 0
      ? const CustomerSummary(
          id: 1,
          summary: 'Loyal customer who prefers evening delivery.',
          highlights: ['Repeat buyer'],
          risks: ['Late payment once'],
          opportunities: ['Bundle upsell'],
          model: 'gpt-test',
          refreshedAt: '2026-11-03T08:00:00+00:00',
        )
      : const CustomerSummary(
          id: 1,
          summary: 'Refreshed summary text.',
          refreshedAt: '2026-11-04T08:00:00+00:00',
        );

  @override
  Future<CustomerCrmOverview> overview(int customerId) async =>
      CustomerCrmOverview(
        customer: _customer,
        stats: const CustomerStats(
          ordersCount: 12,
          paidOrdersCount: 9,
          totalSpent: 5400.5,
          averageOrderValue: 600.06,
          currency: 'EGP',
          lastInteractionAt: '2026-11-02T09:30:00+00:00',
        ),
        summary: _summary,
      );

  @override
  Future<List<CustomerTimelineEntry>> timeline(int customerId) async => [
        CustomerTimelineEntry(
          id: 'order_1',
          type: 'order',
          timestamp: DateTime.utc(2026, 11, 1, 12),
          data: const {
            'order_number': 'ORD-000123',
            'status': 'completed',
            'currency': 'EGP',
            'grand_total': 1200,
            'item_count': 3,
          },
        ),
      ];

  @override
  Future<List<CustomerMemory>> memories(int customerId) async => const [
        CustomerMemory(
          id: 5,
          key: 'preferred_size',
          value: 'M',
          category: 'preferences',
          source: 'manual',
          confidence: 80,
        ),
      ];

  @override
  Future<CustomerSummary> summary(int customerId) async => _summary;

  @override
  Future<CustomerSummary> refreshSummary(int customerId) async {
    refreshCount += 1;
    return _summary;
  }

  @override
  Future<CustomerSummary> updateSummary(int customerId, String summary) async =>
      CustomerSummary(id: 1, summary: summary, isEdited: true);

  @override
  Future<CustomerMemory> createMemory(
    int customerId,
    CustomerMemoryDraft draft,
  ) async =>
      CustomerMemory(
        id: 6,
        key: draft.key,
        value: draft.value,
        category: draft.category,
        source: draft.source,
        confidence: draft.confidence,
      );

  @override
  Future<CustomerMemory> updateMemory(
    int customerId,
    int memoryId,
    CustomerMemoryDraft draft,
  ) async =>
      CustomerMemory(
        id: memoryId,
        key: draft.key,
        value: draft.value,
        category: draft.category,
        source: draft.source,
        confidence: draft.confidence,
      );

  @override
  Future<void> deleteMemory(int customerId, int memoryId) async {}
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('renders the CRM overview and refreshes the AI summary',
      (tester) async {
    final repository = _FakeCrmRepository();
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpTestApp(
      tester,
      const CustomerCrmScreen(id: 7),
      overrides: [
        customerCrmRepositoryProvider.overrideWithValue(repository),
        currentSessionProvider.overrideWithValue(null),
        permissionsProvider.overrideWithValue(
          const Permissions({
            PermissionSlugs.customersView,
            PermissionSlugs.customersUpdate,
            PermissionSlugs.customersDelete,
            PermissionSlugs.aiUse,
          }),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Nada Hassan'), findsOneWidget);
    expect(
      find.text('Loyal customer who prefers evening delivery.'),
      findsOneWidget,
    );
    expect(find.textContaining('Repeat buyer'), findsOneWidget);
    expect(find.textContaining('Late payment once'), findsOneWidget);
    expect(find.text('preferred_size'), findsOneWidget);
    expect(find.text('ORD-000123'), findsOneWidget);

    await tester.tap(find.text('Refresh summary'));
    await tester.pumpAndSettle();

    expect(repository.refreshCount, 1);
    expect(find.text('Refreshed summary text.'), findsOneWidget);
    expect(find.text('Summary refreshed.'), findsOneWidget);
  });
}
