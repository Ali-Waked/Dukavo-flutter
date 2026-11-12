import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../notifications/application/notification_controller.dart';
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
            loading: () => const ListSkeleton(rows: 4),
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
    final unread = ref.watch(notificationUnreadProvider);
    final summary = bundle.overview.summary;
    final firstName = session?.user.firstName ?? '';

    final quickActions = <_QuickActionData>[
      if (permissions.canCreateOrders)
        _QuickActionData(
          icon: Icons.add_shopping_cart_rounded,
          label: context.tr('createOrder'),
          color: context.dukavo.info,
          onTap: () => context.push(RoutePaths.createOrder),
        ),
      if (permissions.canCreateProducts)
        _QuickActionData(
          icon: Icons.add_box_outlined,
          label: context.tr('createProduct'),
          color: context.scheme.primary,
          onTap: () => context.push(RoutePaths.createProduct),
        ),
      if (permissions.canCreateCustomers)
        _QuickActionData(
          icon: Icons.person_add_alt_rounded,
          label: context.tr('createCustomer'),
          color: context.dukavo.warning,
          onTap: () => context.push(RoutePaths.createCustomer),
        ),
      if (permissions.canViewAnalytics)
        _QuickActionData(
          icon: Icons.insights_rounded,
          label: context.tr('analytics'),
          color: context.dukavo.success,
          onTap: () => context.push(RoutePaths.analytics),
        ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.page,
      children: [
        PageHeader(
          eyebrow: context.tr('dashboard'),
          title: _greetingTitle(context, firstName),
          subtitle: session?.activeTenant?.name ?? context.tr('noStore'),
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
          actions: [
            NotificationBellButton(
              tooltip: context.tr('notifications'),
              unreadCount: unread,
              onPressed: () => context.push(RoutePaths.notifications),
            ),
          ],
        ),
        _RevenueHero(
          summary: summary,
          currency: currency,
          revenue: bundle.revenue,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.32,
          children: [
            StatisticCard(
              label: context.tr('ordersToday'),
              value: Formatters.number(summary.ordersToday),
              icon: Icons.receipt_long_outlined,
              tint: context.dukavo.info,
              compact: true,
              onTap: permissions.canViewOrders
                  ? () => context.go(RoutePaths.orders)
                  : null,
            ),
            StatisticCard(
              label: context.tr('awaitingFulfilment'),
              value: Formatters.number(summary.awaitingFulfilment),
              icon: Icons.local_shipping_outlined,
              tint: context.dukavo.warning,
              compact: true,
              onTap: permissions.canViewOrders
                  ? () => context.go(RoutePaths.orders)
                  : null,
            ),
            StatisticCard(
              label: context.tr('lowStockItems'),
              value: Formatters.number(summary.lowStockItems),
              icon: Icons.inventory_2_outlined,
              tint: summary.lowStockItems > 0
                  ? context.dukavo.danger
                  : context.dukavo.success,
              compact: true,
              onTap: permissions.canViewInventory
                  ? () => context.push(RoutePaths.inventory)
                  : null,
            ),
            StatisticCard(
              label: context.tr('openConversations'),
              value: Formatters.number(summary.openConversations),
              icon: Icons.chat_bubble_outline_rounded,
              tint: context.scheme.primary,
              compact: true,
              onTap: permissions.canViewConversations
                  ? () => context.go(RoutePaths.conversations)
                  : null,
            ),
          ],
        ),
        if (quickActions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: context.tr('quickActions')),
          _QuickActionGrid(actions: quickActions),
        ],
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: context.tr('topProducts'),
          actionLabel: context.tr('viewAll'),
          onAction: permissions.canViewProducts
              ? () => context.go(RoutePaths.products)
              : null,
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxs,
            vertical: AppSpacing.xxs,
          ),
          child: bundle.topProducts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    context.tr('noTopProducts'),
                    style: context.texts.bodyMedium?.copyWith(
                      color: context.dukavo.textSecondary,
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
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: context.tr('deadStock')),
        AppCard(
          child: bundle.deadStock.isEmpty
              ? Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.dukavo.successContainer,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: context.dukavo.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.tr('noDeadStock'),
                        style: context.texts.bodyMedium?.copyWith(
                          color: context.dukavo.textSecondary,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    for (final item in bundle.deadStock)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: context.texts.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.sku != null)
                                    Text(
                                      item.sku!,
                                      style: context.texts.labelSmall?.copyWith(
                                        color: context.dukavo.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
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
      ],
    );
  }

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('goodMorning');
    if (hour < 18) return context.tr('goodAfternoon');
    return context.tr('goodEvening');
  }

  /// Builds "Good morning، Name" with the right comma and a bidi isolate
  /// around the name so the comma cannot jump to the other side.
  String _greetingTitle(BuildContext context, String firstName) {
    final greeting = _greeting(context);
    if (firstName.isEmpty) return greeting;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final separator = isArabic ? '،' : ',';
    final isArabicName = RegExp(r'[\u0600-\u06FF]').hasMatch(firstName);
    final isolateStart = isArabicName ? '\u2067' : '\u2066';
    return '$greeting$separator $isolateStart$firstName\u2069';
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
    final colors = context.dukavo;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.heroStart, colors.heroEnd],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.heroStart.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -40,
            end: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -60,
            start: -20,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.space_dashboard_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('revenueToday'),
                          style: context.texts.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                Formatters.currency(summary.revenueToday, currency),
                style: context.texts.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (revenue.length > 1) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 56,
                  child: ClipRect(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _SparklinePainter(
                        values: revenue
                            .map((point) => point.total.toDouble())
                            .toList(),
                        line: context.dukavo.chartLine,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _HeroStat(
                    label: context.tr('revenueMonth'),
                    value: Formatters.currency(
                      summary.revenueMonth,
                      currency,
                      compact: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  _HeroStat(
                    label: context.tr('averageOrderValue'),
                    value: Formatters.currency(
                      summary.averageOrderValue,
                      currency,
                      compact: true,
                    ),
                  ),
                ],
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: context.texts.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.line});

  final List<double> values;
  final Color line;

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
            line.withValues(alpha: 0.30),
            line.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.line != line;
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank == 1
                    ? context.scheme.primaryContainer
                    : context.dukavo.surfaceLow,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                '$rank',
                style: context.texts.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: rank == 1
                      ? context.scheme.onPrimaryContainer
                      : context.dukavo.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: context.texts.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${product.units} ${context.tr('units')}',
                    style: context.texts.labelSmall?.copyWith(
                      color: context.dukavo.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              Formatters.currency(product.revenue, currency, compact: true),
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.45,
      children: [
        for (final action in actions)
          AppCard(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            onTap: action.onTap,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: action.color.withValues(
                      alpha: context.isDark ? 0.16 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Icon(action.icon, size: 18, color: action.color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    action.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.dukavo.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
