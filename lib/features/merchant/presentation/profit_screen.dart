import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';

/// Profit and margin reporting, built entirely from `GET /tenant/profit`.
///
/// When the cost snapshots do not cover every line the server returns a null
/// gross profit; the screen shows that as "not measurable" rather than zero,
/// and lists the limitations the server reported.
class ProfitScreen extends ConsumerStatefulWidget {
  const ProfitScreen({super.key});

  @override
  ConsumerState<ProfitScreen> createState() => _ProfitScreenState();
}

class _ProfitScreenState extends ConsumerState<ProfitScreen> {
  JsonResource? _data;
  bool _loading = true;
  bool _exporting = false;
  String? _error;

  int? _storeId;
  String? _currency;
  DateTime? _from;
  DateTime? _until;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(apiClientProvider).get<JsonMap>(
            ApiPaths.profit,
            query: {
              if (_storeId != null) 'store_id': _storeId,
              if (_currency != null) 'currency': _currency,
              if (_from != null) 'from': _date(_from!),
              if (_until != null) 'until': _date(_until!),
            },
            decode: _asMap,
          );
      if (!mounted) return;
      setState(() {
        _data = JsonResource(data);
        _currency ??= _data?.text('currency');
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentSessionProvider);
    final stores = ref.watch(storeOptionsProvider);
    final data = _data;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profit')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: context.tr('exportCsv'),
            onPressed: _exporting ? null : _export,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _filters(
                context, stores.valueOrNull ?? const [], session?.currency),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ErrorView(message: _error!, onRetry: _load),
              ),
            if (_loading && data == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: LoadingView(),
              )
            else if (data != null) ...[
              _rangeLine(context, data),
              const SizedBox(height: 12),
              _summary(context, data),
              const SizedBox(height: 16),
              _series(context, data),
              const SizedBox(height: 16),
              _products(context, data),
              const SizedBox(height: 16),
              _stores(context, data),
              const SizedBox(height: 16),
              _limitations(context, data),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filters(
    BuildContext context,
    List<Store> stores,
    String? fallbackCurrency,
  ) {
    final currencies = (_data?.data['currencies'] as List?) ?? const [];
    final codes = currencies.whereType<String>().toList();
    if (codes.isEmpty && fallbackCurrency != null) codes.add(fallbackCurrency);
    return SectionCard(
      title: context.tr('filters'),
      child: Column(
        children: [
          if (stores.isNotEmpty) ...[
            DropdownButtonFormField<int?>(
              key: ValueKey('store-$_storeId'),
              initialValue: _storeId,
              decoration: InputDecoration(
                labelText: context.tr('storeFilter'),
              ),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(context.tr('all')),
                ),
                for (final store in stores)
                  DropdownMenuItem<int?>(
                    value: store.id,
                    child: Text(store.name),
                  ),
              ],
              onChanged: (value) {
                setState(() => _storeId = value);
                _load();
              },
            ),
            const SizedBox(height: 10),
          ],
          if (codes.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              key: ValueKey('currency-$_currency-${codes.length}'),
              initialValue: codes.contains(_currency) ? _currency : codes.first,
              decoration: InputDecoration(labelText: context.tr('currency')),
              items: [
                for (final code in codes)
                  DropdownMenuItem(value: code, child: Text(code)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _currency = value);
                _load();
              },
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(from: true),
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(
                    _from == null
                        ? context.tr('from')
                        : Formatters.date(_from!.toIso8601String()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(from: false),
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(
                    _until == null
                        ? context.tr('until')
                        : Formatters.date(_until!.toIso8601String()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangeLine(BuildContext context, JsonResource data) {
    final range = data.map('range');
    if (range == null) return const SizedBox.shrink();
    return Text(
      '${range['from'] ?? ''} — ${range['until'] ?? ''}'
      ' · ${range['days'] ?? ''} ${context.tr('days')}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _summary(BuildContext context, JsonResource data) {
    final summary = data.map('summary') ?? const <String, dynamic>{};
    final currency = data.text('currency', fallback: 'USD');
    final r = JsonResource(summary);

    final cards = <Widget>[
      _MetricCard(
        labelKey: 'netSales',
        value: Formatters.currency(r.number('net_sales') ?? 0, currency),
      ),
      _MetricCard(
        labelKey: 'grossProfit',
        value: r.number('gross_profit') == null
            ? context.tr('notMeasurable')
            : Formatters.currency(r.number('gross_profit')!, currency),
        hint: r.flag('cost_complete') ? null : context.tr('costIncomplete'),
      ),
      _MetricCard(
        labelKey: 'margin',
        value: r.number('gross_margin_percent') == null
            ? context.tr('notMeasurable')
            : Formatters.percent(r.number('gross_margin_percent')!),
      ),
      _MetricCard(
        labelKey: 'cogs',
        value: Formatters.currency(r.number('cogs') ?? 0, currency),
      ),
      _MetricCard(
        labelKey: 'ordersLabel',
        value: Formatters.number(r.number('recognized_orders') ?? 0),
      ),
      _MetricCard(
        labelKey: 'units',
        value: Formatters.number(r.number('units_sold') ?? 0),
      ),
      _MetricCard(
        labelKey: 'average',
        value: r.number('average_order_value') == null
            ? '—'
            : Formatters.currency(r.number('average_order_value')!, currency),
      ),
      _MetricCard(
        labelKey: 'costCoverage',
        value: r.number('cost_coverage_percent') == null
            ? '—'
            : Formatters.percent(r.number('cost_coverage_percent')!),
      ),
      _MetricCard(
        labelKey: 'discounts',
        value: Formatters.currency(r.number('discounts') ?? 0, currency),
      ),
      _MetricCard(
        labelKey: 'shippingRevenue',
        value: Formatters.currency(r.number('shipping_revenue') ?? 0, currency),
      ),
      _MetricCard(
        labelKey: 'taxCollected',
        value: Formatters.currency(r.number('tax_collected') ?? 0, currency),
      ),
      _MetricCard(
        labelKey: 'cancelledOrders',
        value: Formatters.number(r.number('cancelled_orders') ?? 0),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }

  Widget _series(BuildContext context, JsonResource data) {
    final raw = data.data['series'];
    final points = raw is List
        ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const <Map<String, dynamic>>[];
    if (points.isEmpty) return const SizedBox.shrink();
    final max = points.fold<double>(
      1,
      (max, point) {
        final value = (point['net_sales'] as num?)?.toDouble() ?? 0;
        return value > max ? value : max;
      },
    );
    final theme = Theme.of(context);
    return SectionCard(
      title: context.tr('salesTrend'),
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final point in points)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor:
                                (((point['net_sales'] as num?)?.toDouble() ??
                                            0) /
                                        max)
                                    .clamp(0.02, 1.0)
                                    .toDouble(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${point['date'] ?? ''}'.length >= 10
                            ? '${point['date']}'.substring(8)
                            : '${point['date'] ?? ''}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _products(BuildContext context, JsonResource data) {
    final raw = data.data['products'];
    final products = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => JsonResource(Map<String, dynamic>.from(e)))
            .toList()
        : const <JsonResource>[];
    final currency = data.text('currency', fallback: 'USD');
    if (products.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: context.tr('productPerformance'),
      child: Column(
        children: [
          for (final product in products)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                product.text('name', fallback: '—'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  product.text('sku'),
                  '${product.number('units')?.toInt() ?? 0} ${context.tr('units')}',
                ].where((value) => value.isNotEmpty).join(' · '),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(
                      product.number('net_sales') ?? 0,
                      currency,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    product.number('gross_profit') == null
                        ? context.tr('notMeasurable')
                        : Formatters.currency(
                            product.number('gross_profit')!,
                            currency,
                          ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: product.number('gross_profit') == null
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : AppColors.success,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stores(BuildContext context, JsonResource data) {
    final raw = data.data['stores'];
    final stores = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => JsonResource(Map<String, dynamic>.from(e)))
            .toList()
        : const <JsonResource>[];
    final currency = data.text('currency', fallback: 'USD');
    if (stores.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: context.tr('stores'),
      child: Column(
        children: [
          for (final store in stores)
            KeyValueRow(
              label: store.text('name', fallback: '—'),
              value: Formatters.currency(
                store.number('net_sales') ?? 0,
                currency,
              ),
            ),
        ],
      ),
    );
  }

  Widget _limitations(BuildContext context, JsonResource data) {
    final raw = data.data['limitations'];
    final items = raw is List
        ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const <Map<String, dynamic>>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return SectionCard(
      title: context.tr('limitations'),
      subtitle: context.tr('limitationsHint'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item['severity'] == 'warning'
                        ? Icons.warning_amber_outlined
                        : Icons.info_outline,
                    size: 18,
                    color: item['severity'] == 'warning'
                        ? AppColors.warning
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _limitationLabel(context, '${item['code'] ?? ''}'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _limitationLabel(BuildContext context, String code) {
    final key = 'limitation_$code';
    final translated = context.tr(key);
    return translated == key ? code.replaceAll('_', ' ') : translated;
  }

  Future<void> _pickDate({required bool from}) async {
    final initial = (from ? _from : _until) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _from = picked;
      } else {
        _until = picked;
      }
    });
    await _load();
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final bytes = await ref.read(apiClientProvider).download(
        ApiPaths.profitExport,
        query: {
          if (_storeId != null) 'store_id': _storeId,
          if (_currency != null) 'currency': _currency,
          if (_from != null) 'from': _date(_from!),
          if (_until != null) 'until': _date(_until!),
        },
      );
      final file = File(
        '${Directory.systemTemp.path}/profit-${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      AppSnack.show(
        context,
        context.tr('exportSaved', args: {'path': file.path}),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, _message(error), isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _date(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String _message(Object error) =>
      error is ApiException ? error.message : context.tr('errorGeneric');

  JsonMap _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.labelKey, required this.value, this.hint});

  final String labelKey;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(labelKey),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (hint != null)
              Text(
                hint!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                ),
                maxLines: 2,
              ),
          ],
        ),
      ),
    );
  }
}
