import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/dashboard_controller.dart';
import '../domain/dashboard_domain.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final session = ref.watch(currentSessionProvider);
    final currency = session?.currency ?? 'USD';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            await ref.read(dashboardProvider.future);
          },
          child: async.when(
            loading: () => const LoadingView(),
            error: (error, stack) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  child: ErrorView(
                    message: error is ApiException
                        ? error.message
                        : context.tr('errorLoading'),
                    onRetry: () => ref.invalidate(dashboardProvider),
                  ),
                ),
              ],
            ),
            data: (bundle) => _DashboardBody(
              bundle: bundle,
              currency: currency,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.bundle, required this.currency});

  final DashboardBundle bundle;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final permissions = ref.watch(permissionsProvider);
    final summary = bundle.overview.summary;
    final theme = Theme.of(context);
    final firstName = session?.user.firstName ?? '';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting(context)}${firstName.isEmpty ? '' : ', $firstName'}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 15),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          session?.activeTenant?.name ?? context.tr('noStore'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: context.tr('notifications'),
              onPressed: () => context.push(RoutePaths.notifications),
              icon: const Icon(Icons.notifications_none_outlined),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _RevenueHero(
          summary: summary,
          currency: currency,
          revenue: bundle.revenue,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [
            _MetricCard(
              label: context.tr('ordersToday'),
              value: Formatters.number(summary.ordersToday),
              icon: Icons.receipt_long_outlined,
              tint: AppColors.info,
              onTap: permissions.canViewOrders
                  ? () => context.go(RoutePaths.orders)
                  : null,
            ),
            _MetricCard(
              label: context.tr('awaitingFulfilment'),
              value: Formatters.number(summary.awaitingFulfilment),
              icon: Icons.local_shipping_outlined,
              tint: AppColors.warning,
              onTap: permissions.canViewOrders
                  ? () => context.go(RoutePaths.orders)
                  : null,
            ),
            _MetricCard(
              label: context.tr('lowStockItems'),
              value: Formatters.number(summary.lowStockItems),
              icon: Icons.inventory_2_outlined,
              tint: summary.lowStockItems > 0
                  ? AppColors.danger
                  : AppColors.success,
              onTap: permissions.canViewInventory
                  ? () => context.push(RoutePaths.inventory)
                  : null,
            ),
            _MetricCard(
              label: context.tr('openConversations'),
              value: Formatters.number(summary.openConversations),
              icon: Icons.chat_bubble_outline,
              tint: AppColors.primary,
              onTap: permissions.canViewConversations
                  ? () => context.go(RoutePaths.conversations)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 22),
        _SectionHeader(
          title: context.tr('topProducts'),
          actionLabel: context.tr('viewAll'),
          onAction: permissions.canViewProducts
              ? () => context.go(RoutePaths.products)
              : null,
        ),
        const SizedBox(height: 10),
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: bundle.topProducts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    context.tr('noTopProducts'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < bundle.topProducts.length; i++)
                      _TopProductRow(
                        rank: i + 1,
                        product: bundle.topProducts[i],
                        currency: currency,
                        onTap: bundle.topProducts[i].productSlug == null
                            ? null
                            : () => context.push(
                                  RoutePaths.product(
                                    bundle.topProducts[i].productSlug!,
                                  ),
                                ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 22),
        _SectionHeader(title: context.tr('deadStock')),
        const SizedBox(height: 10),
        SectionCard(
          child: bundle.deadStock.isEmpty
              ? Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('noDeadStock'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    for (final item in bundle.deadStock)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.sku != null)
                                    Text(
                                      item.sku!,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            StatusChip(
                              status: 'low_stock',
                              label: '${item.stock} ${context.tr('units')}',
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 22),
        _SectionHeader(title: context.tr('quickActions')),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (permissions.canCreateOrders)
              _QuickAction(
                icon: Icons.add_shopping_cart,
                label: context.tr('createOrder'),
                onTap: () => context.push(RoutePaths.createOrder),
              ),
            if (permissions.canCreateProducts)
              _QuickAction(
                icon: Icons.add_box_outlined,
                label: context.tr('createProduct'),
                onTap: () => context.push(RoutePaths.createProduct),
              ),
            if (permissions.canCreateCustomers)
              _QuickAction(
                icon: Icons.person_add_alt,
                label: context.tr('createCustomer'),
                onTap: () => context.push(RoutePaths.createCustomer),
              ),
            if (permissions.canViewAnalytics)
              _QuickAction(
                icon: Icons.insights_outlined,
                label: context.tr('analytics'),
                onTap: () => context.push(RoutePaths.analytics),
              ),
          ],
        ),
      ],
    );
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('goodMorning');
    if (hour < 18) return context.tr('goodAfternoon');
    return context.tr('goodEvening');
  }
}

class _RevenueHero extends StatelessWidget {
  const _RevenueHero({
    required this.summary,
    required this.currency,
    required this.revenue,
  });

  final DashboardSummary summary;
  final String currency;
  final List<RevenuePoint> revenue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('revenueToday'),
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.currency(summary.revenueToday, currency),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          if (revenue.length > 1)
            SizedBox(
              height: 56,
              child: CustomPaint(
                size: Size.infinite,
                painter: _SparklinePainter(
                  values:
                      revenue.map((point) => point.total.toDouble()).toList(),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HeroStat(
                label: context.tr('revenueMonth'),
                value: Formatters.currency(summary.revenueMonth, currency,
                    compact: true),
              ),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _HeroStat(
                label: context.tr('averageOrderValue'),
                value: Formatters.currency(summary.averageOrderValue, currency,
                    compact: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(maxValue - minValue, 1);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x =
          values.length == 1 ? 0.0 : (i / (values.length - 1)) * size.width;
      final y = size.height -
          ((values[i] - minValue) / range) * (size.height * 0.85) -
          size.height * 0.075;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent.withValues(alpha: 0.35),
            AppColors.accent.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 17, color: tint),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({
    required this.rank,
    required this.product,
    required this.currency,
    this.onTap,
  });

  final int rank;
  final TopProduct product;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$rank',
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${product.units} ${context.tr('units')}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.currency(product.revenue, currency, compact: true),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
