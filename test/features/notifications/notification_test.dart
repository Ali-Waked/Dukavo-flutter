import 'package:dukavo_mobile/features/notifications/application/push_service.dart';
import 'package:dukavo_mobile/features/notifications/data/notification_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationModel', () {
    test('parses the Laravel resource and treats missing read as unread', () {
      final model = NotificationModel.fromJson(const {
        'id': '8c1e',
        'event_key': 'order_created',
        'category': 'orders',
        'title': 'New order',
        'body': 'Order #1042 was placed.',
        'action_url': '/orders/1042',
        'params': {'order_id': '1042'},
        'created_at': '2026-11-09T08:00:00Z',
      });

      expect(model.id, '8c1e');
      expect(model.eventKey, 'order_created');
      expect(model.category, 'orders');
      expect(model.severity, 'info');
      expect(model.read, isFalse);
      expect(model.actionUrl, '/orders/1042');
      expect(model.params['order_id'], '1042');
      expect(model.createdAt, '2026-11-09T08:00:00Z');

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.read, isFalse);
    });

    test('keeps an explicit read timestamp', () {
      final model = NotificationModel.fromJson(const {
        'id': 'x',
        'read': true,
        'read_at': '2026-11-09T09:00:00Z',
      });

      expect(model.read, isTrue);
      expect(model.readAt, '2026-11-09T09:00:00Z');
    });
  });

  group('resolveNotificationPath', () {
    test('falls back to the notification detail screen', () {
      expect(
        resolveNotificationPath(null, notificationId: 'abc 123'),
        '/notifications/abc%20123',
      );
      expect(resolveNotificationPath(''), '/notifications');
    });

    test('accepts an in-app path and normalises a relative one', () {
      expect(resolveNotificationPath('/orders/42?tab=items'),
          '/orders/42?tab=items');
      expect(resolveNotificationPath('orders/42'), '/orders/42');
    });

    test('accepts same-origin links only', () {
      expect(
        resolveNotificationPath(
            'https://dukavo-backend.ethiodeploy.app/orders/9'),
        '/orders/9',
      );
      expect(
        resolveNotificationPath('https://evil.example/orders/9'),
        '/notifications',
      );
      expect(
        resolveNotificationPath(
            'https://user:pass@dukavo-backend.ethiodeploy.app/x'),
        '/notifications',
      );
    });

    test('rejects executable and protocol-relative payloads', () {
      expect(resolveNotificationPath('javascript:alert(1)'), '/notifications');
      expect(resolveNotificationPath('//evil.example/path'), '/notifications');
      expect(resolveNotificationPath('ftp://dukavo-backend.ethiodeploy.app/x'),
          '/notifications');
    });
  });
}
