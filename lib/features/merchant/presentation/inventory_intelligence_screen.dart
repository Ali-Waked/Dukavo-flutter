import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';

/// Inventory intelligence: demand, cover, reorder suggestions and valuation.
///
/// Everything shown is computed by the server from recorded movements. When the
/// history is too short for a forecast the API says so and this screen prints
/// that instead of inventing a demand rate.
class InventoryIntelligenceScreen extends ConsumerStatefulWidget {
  const InventoryIntelligenceScreen({super.key});

  @override
  ConsumerState<InventoryIntelligenceScreen> createState() =>
      _InventoryIntelligenceScreenState();
}

class _InventoryIntelligenceScreenState
    extends ConsumerState<InventoryIntelligenceScreen> {
  final TextEditingController _search = TextEditingController();

  JsonResource? _data;
  List<JsonResource> _items = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _exporting = false;
  String? _error;
  String _status = 'all';
  int? _storeId;
  int _page = 1;
  int _lastPage = 1;

  static const _statuses = <String>[
    'all',
    'low',
    'out',
    'slow',
    'reorder',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Map<String, dynamic> _query(int page) => {
        if (_storeId != null) 'store_id': _storeId,
        if (_status != 'all') 'status': _status,
        if (_search.text.trim().isNotEmpty) 'q': _search.text.trim(),
        'page': page,
        'per_page': 20,
      };

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      if (_loadingMore || _page >= _lastPage) return;
      setState(() => _loadingMore = true);
    }
    try {
      final data = await ref.read(apiClientProvider).get<JsonMap>(
            ApiPaths.inventoryIntelligence,
            query: _query(reset ? 1 : _page + 1),
            decode: _asMap,
          );
      final resource = JsonResource(data);
      final rawItems = data['items'];
      final items = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => JsonResource(Map<String, dynamic>.from(e)))
              .toList()
          : <JsonResource>[];
      final pagination = data['pagination'];
      final meta = pagination is Map
          ? Map<String, dynamic>.from(pagination)
          : const <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _data = resource;
        _items = reset ? items : <JsonResource>[..._items, ...items];
        _page = _asInt(meta['current_page'], reset ? 1 : _page + 1);
        _lastPage = _asInt(meta['last_page'], 1);
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = _message(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stores =
        ref.watch(storeOptionsProvider).valueOrNull ?? const <Store>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('inventoryIntelligence')),
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
          padding: AppSpacing.page,
          children: [
            SearchField(
              controller: _search,
              hint: context.tr('searchProducts'),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 10),
            if (stores.isNotEmpty)
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
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final status in _statuses)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(context.tr(_statusLabel(status))),
                        selected: _status == status,
                        onSelected: (_) {
                          setState(() => _status = status);
                          _load();
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              ErrorView(message: _error!, onRetry: _load),
              const SizedBox(height: 12),
            ],
            if (_loading && _data == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: LoadingView(),
              )
            else if (_data != null) ...[
              _summary(context, _data!),
              const SizedBox(height: 12),
              if (_items.isEmpty)
                EmptyState(
                  title: context.tr('noInventory'),
                  icon: Icons.warehouse_outlined,
                )
              else ...[
                for (final item in _items) _itemCard(context, item),
                if (_page < _lastPage)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: AppButton(
                      label: context.tr('loadMore'),
                      variant: AppButtonVariant.outlined,
                      loading: _loadingMore,
                      onPressed: () => _load(reset: false),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context, JsonResource data) {
    final summary = JsonResource(
      data.map('summary') ?? const <String, dynamic>{},
    );
    final theme = Theme.of(context);
    final valuationRaw = summary.data['valuation'];
    final valuations = valuationRaw is List
        ? valuationRaw.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const <Map<String, dynamic>>[];

    return SectionCard(
      title: context.tr('summary'),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                context,
                context.tr('items'),
                Formatters.number(summary.number('items_count') ?? 0),
                theme.colorScheme.primary,
              ),
              _pill(
                context,
                context.tr('available'),
                Formatters.number(summary.number('units_available') ?? 0),
                context.dukavo.info,
              ),
              _pill(
                context,
                context.tr('lowStock'),
                Formatters.number(summary.number('low_stock_count') ?? 0),
                context.dukavo.warning,
              ),
              _pill(
                context,
                context.tr('outOfStock'),
                Formatters.number(summary.number('out_of_stock_count') ?? 0),
                context.dukavo.danger,
              ),
              _pill(
                context,
                context.tr('reorder'),
                Formatters.number(summary.number('reorder_count') ?? 0),
                context.dukavo.success,
              ),
            ],
          ),
          if (valuations.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final entry in valuations)
              KeyValueRow(
                label:
                    '${context.tr('stockValue')} · ${entry['currency'] ?? ''}',
                value: Formatters.currency(
                  (entry['value'] as num?)?.toDouble() ?? 0,
                  '${entry['currency'] ?? ''}',
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(BuildContext context, JsonResource item) {
    final forecast = item.map('forecast') ?? const <String, dynamic>{};
    final replenishment =
        item.map('replenishment') ?? const <String, dynamic>{};
    final currency = item.text('currency', fallback: 'USD');
    final suggested =
        (replenishment['suggested_quantity'] as num?)?.toInt() ?? 0;
    final cover = replenishment['days_of_cover'];
    final daily = forecast['daily_demand'];
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.text('product_name', fallback: '—'),
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusChip(status: item.text('status')),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                item.text('sku'),
                item.text('variant_name'),
                item.text('store'),
              ].where((value) => value.isNotEmpty).join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _fact(
                  context,
                  context.tr('available'),
                  Formatters.number(item.number('available') ?? 0),
                ),
                _fact(
                  context,
                  context.tr('reserved'),
                  Formatters.number(item.number('reserved_quantity') ?? 0),
                ),
                if (item.number('inventory_value') != null)
                  _fact(
                    context,
                    context.tr('stockValue'),
                    Formatters.currency(
                      item.number('inventory_value')!,
                      currency,
                    ),
                  ),
                if (daily != null)
                  _fact(
                    context,
                    context.tr('dailyDemand'),
                    Formatters.number((daily as num).toDouble()),
                  ),
                if (cover != null)
                  _fact(
                    context,
                    context.tr('daysOfCover'),
                    '$cover',
                  ),
                if (suggested > 0)
                  _fact(
                    context,
                    context.tr('suggestedOrder'),
                    Formatters.number(suggested),
                  ),
              ],
            ),
            if (forecast['status'] == 'insufficient_history') ...[
              const SizedBox(height: 8),
              Text(
                context.tr('insufficientHistory'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: context.dukavo.warning,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _fact(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'low':
        return 'lowStock';
      case 'out':
        return 'outOfStock';
      case 'slow':
        return 'slowMoving';
      case 'reorder':
        return 'reorder';
      default:
        return 'all';
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final bytes = await ref.read(apiClientProvider).download(
            ApiPaths.inventoryIntelligenceExport,
            query: _query(1)
              ..remove('page')
              ..remove('per_page'),
          );
      final file = File(
        '${Directory.systemTemp.path}/inventory-${DateTime.now().millisecondsSinceEpoch}.csv',
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

  String _message(Object error) =>
      error is ApiException ? error.message : context.tr('errorGeneric');

  static int _asInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  JsonMap _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}
