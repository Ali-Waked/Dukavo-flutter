import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';
import '../application/analytics_controller.dart';
import '../domain/analytics_domain.dart';

String _isoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _days = 30;
  int? _storeId;
  DateTimeRange? _range;

  AnalyticsQuery get _query {
    if (_range != null) {
      return AnalyticsQuery(
        from: _isoDate(_range!.start),
        until: _isoDate(_range!.end),
        storeId: _storeId,
        productLimit: 10,
      );
    }
    final until = DateTime.now();
    final from = until.subtract(Duration(days: _days - 1));
    return AnalyticsQuery(
      from: _isoDate(from),
      until: _isoDate(until),
      storeId: _storeId,
      productLimit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(analyticsOverviewProvider(_query));
    final stores = ref.watch(storeOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('analyticsTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('dateRange'),
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_outlined),
          ),
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(analyticsOverviewProvider(_query)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: overview.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(analyticsOverviewProvider(_query)),
        ),
        data: (data) => ListView(
          padding: AppSpacing.page,
          children: [
            _Filters(
              days: _days,
              range: _range,
              stores: stores.valueOrNull ?? const <Store>[],
              storeId: _storeId,
              onDaysChanged: (days) => setState(() {
                _days = days;
                _range = null;
              }),
              onStoreChanged: (storeId) => setState(() => _storeId = storeId),
              onClearRange: () => setState(() => _range = null),
            ),
            if (data.storeName != null || data.from != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 6),
                child: Text(
                  [
                    if (data.storeName != null) data.storeName!,
                    if (data.from != null && data.until != null)
                      '${data.from} → ${data.until}',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.dukavo.textMuted,
                      ),
                ),
              ),
            if (data.kpis.isEmpty)
              EmptyState(
                title: context.tr('noAnalytics'),
                icon: Icons.insights_outlined,
              )
            else
              _KpiGrid(kpis: data.kpis, currency: data.currency),
            if (data.salesTrends.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SectionCard(
                title: context.tr('salesTrend'),
                child: _TrendChart(
                  points: data.salesTrends,
                  currency: data.currency,
                ),
              ),
            ],
            if (data.productPerformance.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SectionCard(
                title: context.tr('productPerformance'),
                child: Column(
                  children: [
                    for (final product in data.productPerformance.take(8))
                      _ProductRow(product: product, currency: data.currency),
                  ],
                ),
              ),
            ],
            if (data.stockHealth.totalItems > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              SectionCard(
                title: context.tr('stockHealth'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _HealthStat(
                            label: context.tr('outOfStock'),
                            value: data.stockHealth.outOfStock,
                            color: context.dukavo.danger,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HealthStat(
                            label: context.tr('lowStock'),
                            value: data.stockHealth.lowStock,
                            color: context.dukavo.warning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HealthStat(
                            label: context.tr('inStock'),
                            value: data.stockHealth.healthy,
                            color: context.dukavo.success,
                          ),
                        ),
                      ],
                    ),
                    if (data.stockHealth.items.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      for (final item in data.stockHealth.items.take(6))
                        _StockRow(item: item),
                    ],
                  ],
                ),
              ),
            ],
            if (data.limitations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SectionCard(
                title: context.tr('limitations'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final limitation in data.limitations)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              limitation.severity == 'warning'
                                  ? Icons.warning_amber_outlined
                                  : Icons.info_outline,
                              size: 16,
                              color: limitation.severity == 'warning'
                                  ? context.dukavo.warning
                                  : context.dukavo.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                limitation.code
                                    .replaceAll('_', ' ')
                                    .toLowerCase(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range ??
          DateTimeRange(
            start: now.subtract(Duration(days: _days - 1)),
            end: now,
          ),
    );
    if (picked != null) setState(() => _range = picked);
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.days,
    required this.range,
    required this.stores,
    required this.storeId,
    required this.onDaysChanged,
    required this.onStoreChanged,
    required this.onClearRange,
  });

  final int days;
  final DateTimeRange? range;
  final List<Store> stores;
  final int? storeId;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<int?> onStoreChanged;
  final VoidCallback onClearRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stores.isNotEmpty)
          DropdownButtonFormField<int?>(
            // ignore: deprecated_member_use
            value: storeId,
            decoration: InputDecoration(labelText: context.tr('storeFilter')),
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
            onChanged: onStoreChanged,
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final option in const [7, 30, 90])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(
                      option == 7
                          ? context.tr('thisWeek')
                          : option == 30
                              ? context.tr('last30Days')
                              : '90 ${context.tr('days')}',
                    ),
                    selected: range == null && days == option,
                    onSelected: (_) => onDaysChanged(option),
                  ),
                ),
              if (range != null)
                ActionChip(
                  avatar: const Icon(Icons.close, size: 16),
                  label: Text(
                    '${Formatters.date(range!.start.toIso8601String())} → '
                    '${Formatters.date(range!.end.toIso8601String())}',
                  ),
                  onPressed: onClearRange,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis, required this.currency});

  final List<AnalyticsKpi> kpis;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final kpi in kpis)
              SizedBox(
                width: width,
                child: _KpiCard(kpi: kpi, currency: currency),
              ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi, required this.currency});

  final AnalyticsKpi kpi;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = kpi.changePercent;
    final color = kpi.direction == 'up'
        ? context.dukavo.success
        : kpi.direction == 'down'
            ? context.dukavo.danger
            : theme.colorScheme.onSurfaceVariant;

    final value = kpi.isCurrency
        ? Formatters.currency(kpi.value, currency, compact: true)
        : kpi.unit == 'percent'
            ? Formatters.percent(kpi.value)
            : Formatters.number(kpi.value);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (change != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  kpi.direction == 'up'
                      ? Icons.trending_up
                      : kpi.direction == 'down'
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 3),
                Text(
                  Formatters.percent(change.abs()),
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points, required this.currency});

  final List<SalesTrendPoint> points;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = points.fold<num>(0, (sum, point) => sum + point.revenue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Formatters.currency(total, currency),
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          context.tr('revenue'),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 130,
          child: CustomPaint(
            size: Size.infinite,
            painter: _TrendPainter(
              values: points.map((point) => point.revenue).toList(),
              lineColor: theme.colorScheme.primary,
              fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              gridColor: theme.colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<num> values;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final grid = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final ceiling = maxValue <= 0 ? 1 : maxValue.toDouble();
    final step =
        values.length == 1 ? size.width : size.width / (values.length - 1);

    final line = Path();
    final fill = Path()..moveTo(0, size.height);
    for (var i = 0; i < values.length; i++) {
      final x = step * i;
      final y = size.height - (values[i] / ceiling) * (size.height - 8) - 4;
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
      fill.lineTo(x, y);
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(fill, Paint()..color = fillColor);
    canvas.drawPath(
      line,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.currency});

  final ProductPerformance product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    '${product.unitsSold} ${context.tr('units')}',
                    if (product.sku != null) product.sku!,
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(product.revenue, currency, compact: true),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (product.grossMarginPercent != null)
                Text(
                  '${context.tr('margin')} '
                  '${Formatters.percent(product.grossMarginPercent!)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthStat extends StatelessWidget {
  const _HealthStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.item});

  final StockHealthItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            '${item.available}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: item.status == 'out_of_stock'
                  ? context.dukavo.danger
                  : context.dukavo.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(status: item.status, compact: true),
        ],
      ),
    );
  }
}
