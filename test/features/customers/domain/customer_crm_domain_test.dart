import 'package:dukavo_mobile/features/customers/domain/customer_crm_domain.dart';
import 'package:dukavo_mobile/features/customers/domain/customer_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the CRM overview, stats and AI summary', () {
    final overview = CustomerCrmOverview.fromJson(
      const {
        'stats': {
          'orders_count': 12,
          'paid_orders_count': 9,
          'total_spent': 5400.5,
          'average_order_value': 600.06,
          'currency': 'EGP',
          'last_order_at': '2026-11-01T12:00:00+00:00',
          'last_interaction_at': '2026-11-02T09:30:00+00:00',
        },
        'summary': {
          'id': 3,
          'summary': 'Loyal customer who prefers evening delivery.',
          'highlights': ['Repeat buyer', 'Prefers WhatsApp'],
          'risks': ['Late payment once'],
          'opportunities': ['Bundle upsell'],
          'model': 'gpt-test',
          'is_edited': true,
          'generated_by': {'id': 1, 'name': 'Sara'},
          'edited_by': {'id': 2, 'name': 'Omar'},
          'refreshed_at': '2026-11-03T08:00:00+00:00',
        },
        'last_interaction_at': '2026-11-02T09:30:00+00:00',
      },
      const Customer(id: 7, name: 'Nada', status: 'active'),
    );

    expect(overview.customer.name, 'Nada');
    expect(overview.stats.ordersCount, 12);
    expect(overview.stats.paidOrdersCount, 9);
    expect(overview.stats.totalSpent, 5400.5);
    expect(overview.stats.currency, 'EGP');
    expect(overview.summary.summary, contains('evening delivery'));
    expect(overview.summary.highlights, hasLength(2));
    expect(overview.summary.risks.single, 'Late payment once');
    expect(overview.summary.opportunities.single, 'Bundle upsell');
    expect(overview.summary.generatedBy, 'Sara');
    expect(overview.summary.editedBy, 'Omar');
    expect(overview.summary.isEdited, isTrue);
    expect(overview.summary.isEmpty, isFalse);
  });

  test('parses timeline entries and memory confidence', () {
    final order = CustomerTimelineEntry.fromJson(const {
      'id': 'order_1',
      'type': 'order',
      'timestamp': '2026-11-01T12:00:00+00:00',
      'data': {
        'order_number': 'ORD-000123',
        'status': 'completed',
        'currency': 'EGP',
        'grand_total': 1200,
        'item_count': 3,
      },
    });
    final conversation = CustomerTimelineEntry.fromJson(const {
      'id': 'conversation_2',
      'type': 'conversation',
      'timestamp': '2026-11-02T09:30:00+00:00',
      'data': {
        'conversation_id': 22,
        'channel': 'whatsapp',
        'status': 'open',
        'subject': 'Delivery question',
      },
    });

    expect(order.isOrder, isTrue);
    expect(order.orderNumber, 'ORD-000123');
    expect(order.grandTotal, 1200);
    expect(order.itemCount, 3);
    expect(order.timestamp, isNotNull);

    expect(conversation.isConversation, isTrue);
    expect(conversation.conversationId, 22);
    expect(conversation.conversationSubject, 'Delivery question');
    expect(conversation.conversationChannel, 'whatsapp');

    final memory = CustomerMemory.fromJson(const {
      'id': 5,
      'key': 'preferred_size',
      'value': 'M',
      'category': 'preferences',
      'source': 'manual',
      'confidence': 80,
      'created_by': {'id': 1, 'name': 'Sara'},
    });

    expect(memory.key, 'preferred_size');
    expect(memory.value, 'M');
    expect(memory.confidence, 80);
    expect(memory.createdBy, 'Sara');
  });

  test('treats missing CRM payloads as empty', () {
    final summary = CustomerSummary.fromJson(const {});
    final stats = CustomerStats.fromJson(const {});
    final overview = CustomerCrmOverview.fromJson(
      const {},
      const Customer(id: 1, name: 'Empty', status: 'active'),
    );

    expect(summary.isEmpty, isTrue);
    expect(stats.ordersCount, 0);
    expect(overview.summary.isEmpty, isTrue);
    expect(overview.stats.totalSpent, 0);
  });
}
