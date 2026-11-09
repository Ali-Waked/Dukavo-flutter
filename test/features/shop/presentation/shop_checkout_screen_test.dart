import 'package:dukavo_mobile/features/shop/application/shop_providers.dart';
import 'package:dukavo_mobile/features/shop/domain/shop_models.dart';
import 'package:dukavo_mobile/features/shop/presentation/shop_checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

const _shop = ShopRef('acme', 'main');

const _cartLine = ShopCartLine(
  productSlug: 'linen-shirt',
  productName: 'Linen shirt',
  variantId: 4,
  variantName: 'Medium',
  unitPrice: 100,
  currency: 'SAR',
  quantity: 1,
  imageUrl: null,
  maxQuantity: 5,
);

const _payment = ShopPaymentMethod(
  code: 'cod',
  label: 'Cash on delivery',
  description: 'Pay the courier.',
  available: true,
  unavailableReason: null,
);

const _arabicZone = ShopShippingZone(
  id: 3,
  name: 'توصيل الرياض',
  methodName: 'التوصيل العادي',
  methodDescription: 'يتم التسليم خلال يومي عمل.',
  deliveryInstructions: 'اتصل عند الوصول.',
  terms: 'التوصيل مجاني فوق ٣٠٠.',
  locale: 'ar',
  city: 'Riyadh',
  areas: ['Olaya'],
  fee: 15,
  freeShippingThreshold: 300,
);

const _englishZone = ShopShippingZone(
  id: 3,
  name: 'Riyadh delivery',
  methodName: 'Standard delivery',
  methodDescription: 'Delivered in two working days.',
  locale: 'en',
  city: 'Riyadh',
  areas: ['Olaya'],
  fee: 15,
  freeShippingThreshold: 300,
);

Future<void> _pumpCheckout(
  WidgetTester tester, {
  required Locale locale,
  required ShopShippingZone zone,
}) async {
  await pumpTestApp(
    tester,
    const ShopCheckoutScreen(shop: _shop),
    locale: locale,
    overrides: [
      cartProvider.overrideWith((ref, shop) {
        final cart = CartNotifier()..add(_cartLine);
        return cart;
      }),
      shopPaymentsProvider.overrideWith((ref, shop) async => [_payment]),
      shopShippingProvider.overrideWith((ref, shop) async => [zone]),
    ],
  );
}

Future<void> _chooseCity(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<String>).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Riyadh').last);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('Arabic checkout shows the shipping copy right-to-left',
      (tester) async {
    await _pumpCheckout(
      tester,
      locale: const Locale('ar'),
      zone: _arabicZone,
    );

    await _chooseCity(tester);

    expect(find.text('التوصيل العادي'), findsOneWidget);
    expect(find.text('يتم التسليم خلال يومي عمل.'), findsOneWidget);
    expect(find.text('اتصل عند الوصول.'), findsOneWidget);
    expect(find.text('التوصيل مجاني فوق ٣٠٠.'), findsOneWidget);

    final directions = tester.widgetList<Directionality>(
      find.ancestor(
        of: find.text('التوصيل العادي'),
        matching: find.byType(Directionality),
      ),
    );

    expect(
      directions.any((widget) => widget.textDirection == TextDirection.rtl),
      isTrue,
    );
  });

  testWidgets('English checkout keeps the same delivery details left-to-right',
      (tester) async {
    await _pumpCheckout(
      tester,
      locale: const Locale('en'),
      zone: _englishZone,
    );

    await _chooseCity(tester);

    expect(find.text('Standard delivery'), findsOneWidget);
    expect(find.text('Delivered in two working days.'), findsOneWidget);

    final directions = tester.widgetList<Directionality>(
      find.ancestor(
        of: find.text('Standard delivery'),
        matching: find.byType(Directionality),
      ),
    );

    expect(
      directions.any((widget) => widget.textDirection == TextDirection.ltr),
      isTrue,
    );
  });
}
