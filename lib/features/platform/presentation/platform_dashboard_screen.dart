import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/platform_controller.dart';
import '../domain/platform_domain.dart';

/// The operator overview. Every figure comes from `GET /platform/dashboard`;
/// nothing is derived locally except the growth percentage, and that stays
/// "unavailable" when the previous window was empty.
class PlatformDashboardScreen extends ConsumerWidget {
  const PlatformDashboardScreen({super.key});

  static const _ranges = <String>['7d', '30d', '90d', '12m'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(platformDashboardProvider);
    final range = ref.watch(platformRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('platformOverview')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(platformDashboardProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(platformDashboardProvider);
          await ref.read(platformDashboardProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _RangeSelector(
              selected: range,
              onSelected: (value) {
                ref.read(platformRangeProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 12),
            AsyncValueView<PlatformDashboard>(
              value: dashboard,
              onRetry: () => ref.invalidate(platformDashboardProvider),
              builder: (data) => _DashboardBody(data: data),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final range in PlatformDashboardScreen._ranges)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(context.tr(_rangeKey(range))),
                selected: range == selected,
                onSelected: (_) => onSelected(range),
              ),
            ),
        ],
      ),
    );
  }

  static String _rangeKey(String range) {
    switch (range) {
      case '7d':
        return 'range7d';
      case '90d':
        return 'range90d';
      case '12m':
        return 'range12m';
      default:
        return 'range30d';
    }
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final PlatformDashboard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${data.from} — ${data.until}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _KpiGrid(data: data),
        const SizedBox(height: 16),
        SectionCard(
          title: context.tr('growthSeries'),
          subtitle: context.tr('growthSeriesHint'),
          child: _SeriesChart(points: data.series),
        ),
        const SizedBox(height: 16),
        _StatusCard(
          titleKey: 'tenants',
          items: data.statusFor('tenants'),
          icon: Icons.business_outlined,
          onTap: () => context.go(RoutePaths.platformTenants),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          titleKey: 'users',
          items: data.statusFor('users'),
          icon: Icons.people_outline,
          onTap: () => context.go(RoutePaths.platformUsers),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          titleKey: 'waitlist',
          items: data.statusFor('waitlist'),
          icon: Icons.hourglass_empty,
          onTap: () => context.go(RoutePaths.platformWaitlist),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          titleKey: 'contactMessages',
          items: data.statusFor('contact_messages'),
          icon: Icons.mark_email_unread_outlined,
          onTap: () => context.go(RoutePaths.platformContact),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          titleKey: 'subscribers',
          items: data.statusFor('newsletter_subscribers'),
          icon: Icons.mark_email_read_outlined,
          onTap: () => context.go(RoutePaths.platformSubscribers),
        ),
        const SizedBox(height: 12),
        _StatusCard(
          titleKey: 'userAccounts',
          items: data.statusFor('user_accounts'),
          icon: Icons.group_outlined,
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.data});

  final PlatformDashboard data;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _KpiCard(
        labelKey: 'tenants',
        metric: data.tenants,
        icon: Icons.business_outlined,
        extraKey: 'active',
        extraValue: data.tenants.extraValue('active'),
      ),
      _KpiCard(
        labelKey: 'users',
        metric: data.users,
        icon: Icons.people_outline,
        extraKey: 'members',
        extraValue: data.users.extraValue('members'),
      ),
      _KpiCard(
        labelKey: 'waitlist',
        metric: data.waitlist,
        icon: Icons.hourglass_empty,
        extraKey: 'pending',
        extraValue: data.waitlist.extraValue('pending'),
      ),
      _KpiCard(
        labelKey: 'contactMessages',
        metric: data.contactMessages,
        icon: Icons.mark_email_unread_outlined,
        extraKey: 'unresolved',
        extraValue: data.contactMessages.extraValue('unresolved'),
      ),
      _KpiCard(
        labelKey: 'subscribers',
        metric: data.newsletterSubscribers,
        icon: Icons.mark_email_read_outlined,
        extraKey: 'subscribed',
        extraValue: data.newsletterSubscribers.extraValue('subscribed'),
      ),
      _KpiCard(
        labelKey: 'pricingPlans',
        metric: data.plans,
        icon: Icons.sell_outlined,
        extraKey: 'active',
        extraValue: data.plans.extraValue('active'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 3 : 2;
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
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.labelKey,
    required this.metric,
    required this.icon,
    required this.extraKey,
    required this.extraValue,
  });

  final String labelKey;
  final PlatformMetric metric;
  final IconData icon;
  final String extraKey;
  final int extraValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final growth = PlatformDashboard.growth(metric);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr(labelKey),
                    style: theme.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Formatters.number(metric.total),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${context.tr(extraKey)}: ${Formatters.number(extraValue)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (metric.newCount != null) ...[
                  Text(
                    '+${Formatters.number(metric.newCount!)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      context.tr('newInPeriod'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            if (growth != null)
              Text(
                '${growth >= 0 ? '+' : ''}${Formatters.percent(growth)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: growth >= 0 ? AppColors.success : AppColors.danger,
                ),
              )
            else if (metric.newCount != null)
              Text(
                context.tr('noPreviousData'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeriesChart extends StatelessWidget {
  const _SeriesChart({required this.points});

  final List<PlatformSeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.isEmpty) {
      return Text(context.tr('noData'), style: theme.textTheme.bodySmall);
    }
    final maxValue = points.fold<int>(
      0,
      (max, point) =>
          [max, point.tenants, point.users].reduce((a, b) => a > b ? a : b),
    );
    final safeMax = maxValue <= 0 ? 1 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(color: theme.colorScheme.primary, labelKey: 'tenants'),
            const SizedBox(width: 14),
            _LegendDot(
              color: theme.colorScheme.tertiary,
              labelKey: 'users',
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final point in points)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _Bar(
                                  value: point.tenants,
                                  max: safeMax,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 1),
                              Expanded(
                                child: _Bar(
                                  value: point.users,
                                  max: safeMax,
                                  color: theme.colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _shortBucket(point.bucket),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _shortBucket(String bucket) {
    if (bucket.length >= 7) return bucket.substring(5);
    return bucket;
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.max, required this.color});

  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final factor = value <= 0 ? 0.0 : (value / max).clamp(0.04, 1.0);
    return FractionallySizedBox(
      heightFactor: factor,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.labelKey});

  final Color color;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(context.tr(labelKey),
            style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.titleKey,
    required this.items,
    required this.icon,
    this.onTap,
  });

  final String titleKey;
  final List<PlatformStatusCount> items;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final total = items.fold<int>(0, (sum, item) => sum + item.count);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr(titleKey),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    Formatters.number(total),
                    style: theme.textTheme.labelLarge,
                  ),
                  if (onTap != null) const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              for (final item in items) ...[
                _StatusBar(item: item, total: total),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.item, required this.total});

  final PlatformStatusCount item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final factor = total <= 0 ? 0.0 : item.count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr(item.value),
                style: theme.textTheme.labelSmall,
              ),
            ),
            Text(
              Formatters.number(item.count),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: factor,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
