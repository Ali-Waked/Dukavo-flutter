import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../currency/currency_catalogue.dart';
import '../../app/localization/app_localizations.dart';

/// A searchable currency chooser shared by every mobile surface.
///
/// The list comes from the server, so names, symbols and minor-unit precision
/// are never guessed on the device. The control is a modal rather than a
/// dropdown because ISO 4217 has 165 entries: a scrolling, filterable list is
/// usable on a phone and with a screen reader, while a menu of 165 rows is not.
Future<CurrencyOption?> showCurrencyPicker(
  BuildContext context, {
  required List<CurrencyOption> currencies,
  String? selected,
  String? title,
}) {
  return showModalBottomSheet<CurrencyOption>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _CurrencyPickerSheet(
      currencies: currencies,
      selected: selected,
      title: title ?? sheetContext.tr('selectCurrency'),
    ),
  );
}

/// A read-only-looking form field that opens [showCurrencyPicker].
class CurrencyPickerField extends StatelessWidget {
  const CurrencyPickerField({
    super.key,
    required this.currencies,
    required this.value,
    required this.onChanged,
    required this.label,
    this.helperText,
    this.enabled = true,
    this.placeholder,
  });

  final List<CurrencyOption> currencies;
  final String? value;
  final ValueChanged<CurrencyOption> onChanged;
  final String label;
  final String? helperText;
  final bool enabled;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final selected = _find(currencies, value);
    final theme = Theme.of(context);
    final canOpen = enabled && currencies.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: canOpen
          ? () async {
              final choice = await showCurrencyPicker(
                context,
                currencies: currencies,
                selected: selected?.code,
                title: label,
              );
              if (choice != null) onChanged(choice);
            }
          : null,
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperMaxLines: 3,
          suffixIcon: const Icon(Icons.expand_more),
          enabled: enabled,
        ),
        child: Text(
          selected?.label ?? placeholder ?? context.tr('selectCurrency'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: selected == null
              ? theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  static CurrencyOption? _find(
    List<CurrencyOption> currencies,
    String? code,
  ) {
    final wanted = (code ?? '').toUpperCase();
    for (final currency in currencies) {
      if (currency.code == wanted) return currency;
    }
    return null;
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selected,
    required this.title,
  });

  final List<CurrencyOption> currencies;
  final String? selected;
  final String title;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final TextEditingController _search = TextEditingController();
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final index = widget.currencies.indexWhere(
      (currency) => currency.code == widget.selected,
    );
    // Put the current choice near the top without an exact per-row measurement.
    // The list is virtualised, so this only affects the first paint.
    _scroll = ScrollController(
      initialScrollOffset: index <= 0 ? 0 : math.max(0, index * 64.0 - 160),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _search.text;
    final matches = widget.currencies
        .where((currency) => currency.matches(query))
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: math.min(MediaQuery.sizeOf(context).height * 0.8, 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                widget.title,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: context.tr('searchCurrencies'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: context.tr('clear'),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr('noCurrenciesMatch'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final currency = matches[index];
                        final isSelected = currency.code == widget.selected;

                        return ListTile(
                          title: Text(currency.name.isEmpty
                              ? currency.code
                              : currency.name),
                          subtitle: Text(
                            '${currency.code} · ${currency.symbol} · '
                            '${context.tr('decimalPlaces', args: {
                                  'count': currency.decimals
                                })}',
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          selected: isSelected,
                          onTap: () => Navigator.of(context).pop(currency),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
