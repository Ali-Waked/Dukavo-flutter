import 'package:dukavo_mobile/core/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('StatusChip localises a known status', (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: Center(child: StatusChip(status: 'partially_paid')),
      ),
    );

    expect(find.text('Partially paid'), findsOneWidget);
  });

  testWidgets('StatusChip prefers an explicit label', (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: Center(
          child: StatusChip(status: 'paid', label: 'Settled'),
        ),
      ),
    );

    expect(find.text('Settled'), findsOneWidget);
    expect(find.text('Paid'), findsNothing);
  });

  testWidgets('StatusChip shows the raw key when no translation exists',
      (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: Center(child: StatusChip(status: 'some_new_status')),
      ),
    );

    expect(find.text('some_new_status'), findsOneWidget);
  });

  testWidgets('EmptyState renders its copy and action', (tester) async {
    var tapped = 0;

    await pumpTestApp(
      tester,
      Scaffold(
        body: EmptyState(
          title: 'No orders',
          message: 'Create the first order to get started.',
          actionLabel: 'New order',
          onAction: () => tapped++,
        ),
      ),
    );

    expect(find.text('No orders'), findsOneWidget);
    expect(
      find.text('Create the first order to get started.'),
      findsOneWidget,
    );

    await tester.tap(find.text('New order'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
  });

  testWidgets('EmptyState hides the action when no callback is given',
      (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: EmptyState(title: 'Nothing here', actionLabel: 'Ignored'),
      ),
    );

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.text('Ignored'), findsNothing);
  });

  testWidgets('KeyValueRow aligns the label and value', (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: KeyValueRow(label: 'Grand total', value: 'AED 195.00'),
      ),
    );

    expect(find.text('Grand total'), findsOneWidget);
    expect(find.text('AED 195.00'), findsOneWidget);
  });

  testWidgets('KeyValueRow technical values stay LTR in RTL layouts',
      (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: KeyValueRow(
            label: 'Phone number ID',
            value: 'DEMO_PHONE_NUMBER_ID',
            technical: true,
          ),
        ),
      ),
    );

    final value = tester.widget<Text>(find.text('DEMO_PHONE_NUMBER_ID'));
    expect(value.textDirection, TextDirection.ltr);
  });

  testWidgets('StatusBanner renders its message and tone icon', (tester) async {
    await pumpTestApp(
      tester,
      const Scaffold(
        body: StatusBanner(
          message: 'Could not load the account.',
          tone: StatusBannerTone.error,
        ),
      ),
    );

    expect(find.text('Could not load the account.'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('StatusBanner invokes its action', (tester) async {
    var tapped = 0;

    await pumpTestApp(
      tester,
      Scaffold(
        body: StatusBanner(
          message: 'You are offline.',
          tone: StatusBannerTone.warning,
          actionLabel: 'Retry',
          onAction: () => tapped++,
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(tapped, 1);
  });

  testWidgets('NotificationBellButton keeps a 48dp target and unread dot',
      (tester) async {
    var tapped = 0;

    await pumpTestApp(
      tester,
      Scaffold(
        body: Center(
          child: NotificationBellButton(
            onPressed: () => tapped++,
            tooltip: 'Notifications',
            unreadCount: 2,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('notificationUnreadDot')), findsOneWidget);
    expect(
      tester.getSize(find.byType(NotificationBellButton)),
      const Size(48, 48),
    );

    await tester.tap(find.byType(NotificationBellButton));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('NotificationBellButton hides the dot when nothing is unread',
      (tester) async {
    await pumpTestApp(
      tester,
      Scaffold(
        body: Center(child: NotificationBellButton(onPressed: () {})),
      ),
    );

    expect(find.byKey(const ValueKey('notificationUnreadDot')), findsNothing);
  });
}
