import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/currency_picker.dart';
import '../../auth/application/auth_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../application/store_controller.dart';
import '../domain/store_currency_domain.dart';

/// Previews and applies a store's base-currency change.
///
/// The server owns the exchange rate, the rounding and the price rewrite. The
/// screen only asks for a quote, shows exactly what will change, and submits an
/// idempotency key so a retried request cannot convert the catalogue twice.
class StoreCurrencyScreen extends ConsumerStatefulWidget {
  const StoreCurrencyScreen({super.key, required this.storeId});

  final int storeId;

  @override
  ConsumerState<StoreCurrencyScreen> createState() =>
      _StoreCurrencyScreenState();
}

class _StoreCurrencyScreenState extends ConsumerState<StoreCurrencyScreen> {
  String? _selected;
  CurrencyPreview? _preview;
  bool _previewing = false;
  bool _converting = false;
  String? _error;

  String _newKey() {
    final random = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$random';
  }

  Future<void> _previewQuote(String currency) async {
    setState(() {
      _previewing = true;
      _preview = null;
      _error = null;
    });
    try {
      final preview = await ref
          .read(storeCurrencyRepositoryProvider)
          .preview(widget.storeId, currency);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _previewing = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _previewing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('errorGeneric');
        _previewing = false;
      });
    }
  }

  Future<void> _convert() async {
    final preview = _preview;
    final target = _selected;
    if (preview == null || target == null || preview.noop) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('convertCurrencyTitle'),
      message: context.tr('convertCurrencyMessage'),
      confirmLabel: context.tr('convertCurrency'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _converting = true;
      _error = null;
    });

    try {
      await ref.read(storeCurrencyRepositoryProvider).convert(
            widget.storeId,
            target,
            _newKey(),
          );
      if (!mounted) return;
      ref.invalidate(storeCurrencyProvider(widget.storeId));
      ref.invalidate(storeOptionsProvider);
      ref.invalidate(workspaceSettingsProvider);
      // The default store's currency is the workspace currency the shell and
      // reports format with, so re-read `/me` instead of trusting a stale
      // session value. The conversion already succeeded; a failed refresh must
      // not turn it into an error.
      try {
        await ref.read(authControllerProvider.notifier).refreshSession();
      } catch (_) {
        // The next app boot will read the new currency from `/me`.
      }
      if (!mounted) return;
      setState(() {
        _converting = false;
        _preview = null;
        _selected = null;
      });
      AppSnack.show(context, context.tr('currencyConverted'));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _converting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('errorGeneric');
        _converting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeCurrencyProvider(widget.storeId));
    final options = ref.watch(currencyOptionsProvider);
    final canManage = ref.watch(permissionsProvider).canManageStores;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('storeCurrency')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () =>
                ref.invalidate(storeCurrencyProvider(widget.storeId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error is ApiException
              ? error.message
              : context.tr('errorGeneric'),
          onRetry: () => ref.invalidate(storeCurrencyProvider(widget.storeId)),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            SectionCard(
              title: data.storeName,
              child: Column(
                children: [
                  KeyValueRow(
                    label: context.tr('currentCurrency'),
                    value: data.currency,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('storeCurrencyHelp'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: context.tr('targetCurrency'),
              child: options.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (error, stack) => Text(
                  error is ApiException
                      ? error.message
                      : context.tr('errorGeneric'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (currencies) {
                  final choices = currencies
                      .where((currency) => currency.code != data.currency)
                      .toList();
                  if (choices.isEmpty) {
                    return Text(
                      context.tr('sameCurrency'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CurrencyPickerField(
                        currencies: choices,
                        value: _selected,
                        label: context.tr('currency'),
                        placeholder: context.tr('selectCurrency'),
                        enabled: !_previewing && !_converting,
                        onChanged: (currency) {
                          setState(() {
                            _selected = currency.code;
                            _preview = null;
                            _error = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: context.tr('previewConversion'),
                        icon: Icons.calculate_outlined,
                        expand: true,
                        loading: _previewing,
                        onPressed: _selected == null || _converting
                            ? null
                            : () => _previewQuote(_selected!),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (_preview != null) ...[
              const SizedBox(height: 12),
              _PreviewCard(
                preview: _preview!,
                fromDecimals: _decimalsFor(
                  options.valueOrNull ?? const <CurrencyOption>[],
                  _preview!.fromCurrency,
                ),
                toDecimals: _decimalsFor(
                  options.valueOrNull ?? const <CurrencyOption>[],
                  _preview!.toCurrency,
                ),
                canConvert: canManage && !_converting,
                converting: _converting,
                onConvert: _convert,
              ),
            ],
            if (data.history.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionCard(
                title: context.tr('conversionHistory'),
                child: Column(
                  children: [
                    for (final entry in data.history)
                      _HistoryRow(conversion: entry),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

int _decimalsFor(List<CurrencyOption> options, String code) {
  for (final option in options) {
    if (option.code == code) return option.decimals;
  }
  return 2;
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.preview,
    required this.fromDecimals,
    required this.toDecimals,
    required this.canConvert,
    required this.converting,
    required this.onConvert,
  });

  final CurrencyPreview preview;
  final int fromDecimals;
  final int toDecimals;
  final bool canConvert;
  final bool converting;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: context.tr('previewConversion'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyValueRow(
            label: context.tr('conversionRate'),
            value: '1 ${preview.fromCurrency} = '
                '${Formatters.number(preview.rate)} ${preview.toCurrency}',
          ),
          KeyValueRow(
            label: context.tr('rateSource'),
            value: preview.rateSource.isEmpty ? '—' : preview.rateSource,
          ),
          if (preview.rateFetchedAt != null)
            KeyValueRow(
              label: context.tr('rateFetchedAt'),
              value:
                  Formatters.dateTime(preview.rateFetchedAt!.toIso8601String()),
            ),
          KeyValueRow(
            label: context.tr('products'),
            value: '${preview.products}',
          ),
          KeyValueRow(
            label: context.tr('variants'),
            value: '${preview.variants}',
          ),
          KeyValueRow(
            label: context.tr('bundles'),
            value: '${preview.bundles}',
          ),
          KeyValueRow(
            label: context.tr('shippingZones'),
            value: '${preview.shippingZones}',
          ),
          if (preview.noop) ...[
            const SizedBox(height: 8),
            Text(
              context.tr('sameCurrency'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (preview.sample.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              context.tr('samplePrices'),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            for (final sample in preview.sample)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sample.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${context.tr('before')}: '
                      '${Formatters.currency(sample.priceBefore, preview.fromCurrency, decimals: fromDecimals)}'
                      '  →  ${context.tr('after')}: '
                      '${Formatters.currency(sample.priceAfter, preview.toCurrency, decimals: toDecimals)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (canConvert && !preview.noop) ...[
            const SizedBox(height: 12),
            AppButton(
              label: context.tr('convertCurrency'),
              icon: Icons.currency_exchange,
              expand: true,
              loading: converting,
              onPressed: onConvert,
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.conversion});

  final CurrencyConversion conversion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final when = conversion.completedAt ?? conversion.createdAt;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${conversion.fromCurrency} → ${conversion.toCurrency}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  [
                    if (when != null)
                      Formatters.dateTime(when.toIso8601String()),
                    '${conversion.productsConverted} '
                        '${context.tr('products').toLowerCase()}',
                    '${conversion.variantsConverted} '
                        '${context.tr('variants').toLowerCase()}',
                    if (conversion.shippingZonesConverted > 0)
                      '${conversion.shippingZonesConverted} '
                          '${context.tr('shippingZones').toLowerCase()}',
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (conversion.failureReason != null)
                  Text(
                    conversion.failureReason!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          StatusChip(status: conversion.status),
        ],
      ),
    );
  }
}
