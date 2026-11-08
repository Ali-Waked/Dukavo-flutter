import 'package:dukavo_mobile/core/currency/currency_catalogue.dart';
import 'package:dukavo_mobile/core/widgets/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

const _currencies = <CurrencyOption>[
  CurrencyOption(
    code: 'EGP',
    name: 'Egyptian pound',
    nameEn: 'Egyptian pound',
    nameAr: 'جنيه مصري',
    symbol: 'E£',
    decimals: 2,
  ),
  CurrencyOption(
    code: 'KWD',
    name: 'Kuwaiti dinar',
    nameEn: 'Kuwaiti dinar',
    nameAr: 'دينار كويتي',
    symbol: 'KWD',
    decimals: 3,
  ),
];

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String? _value = 'EGP';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CurrencyPickerField(
          currencies: _currencies,
          value: _value,
          label: 'Currency',
          onChanged: (currency) => setState(() => _value = currency.code),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(preloadLocalizations);

  testWidgets('searches by code and selects a currency', (tester) async {
    await pumpTestApp(tester, const _Harness());

    expect(find.text('EGP · Egyptian pound'), findsOneWidget);

    await tester.tap(find.byType(CurrencyPickerField));
    await tester.pumpAndSettle();

    expect(find.text('Kuwaiti dinar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'kw');
    await tester.pumpAndSettle();

    expect(find.text('Egyptian pound'), findsNothing);
    await tester.tap(find.text('Kuwaiti dinar'));
    await tester.pumpAndSettle();

    expect(find.text('KWD · Kuwaiti dinar'), findsOneWidget);
  });

  testWidgets('shows a clear empty state when nothing matches', (tester) async {
    await pumpTestApp(tester, const _Harness());

    await tester.tap(find.byType(CurrencyPickerField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('No currencies match your search.'), findsOneWidget);
  });
}
