import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/shop_providers.dart';
import '../domain/shop_models.dart';
import 'shop_shell.dart';

/// A customer-safe order view, authorised by the tracking token in the URL.
///
/// The token is the secret the API issues on checkout. Nothing here can read an
/// order without it, and no internal id, cost or merchant note is exposed.
class ShopOrderScreen extends ConsumerWidget {
  const ShopOrderScreen({
    super.key,
    required this.shop,
    required this.token,
  });

  final ShopRef shop;
  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refKey = ShopOrderRef(shop.tenant, shop.store, token);
    final order = ref.watch(shopOrderProvider(refKey));
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('orderTracking')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(shopOrderProvider(refKey)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: order.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: shopErrorMessage(context, error),
          onRetry: () => ref.invalidate(shopOrderProvider(refKey)),
        ),
        data: (value) => _OrderBody(shop: shop, order: value),
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.shop, required this.order});

  final ShopRef shop;
  final ShopOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: AppSpacing.page,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                context.dukavo.heroStart,
                context.dukavo.heroEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: context.dukavo.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('orderConfirmed'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                order.orderNumber,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(
                    status: order.status,
                    label: order.statusLabel.isEmpty
                        ? order.status
                        : order.statusLabel,
                  ),
                  StatusChip(
                    status: order.paymentStatus,
                    label: order.paymentStatusLabel.isEmpty
                        ? order.paymentStatus
                        : order.paymentStatusLabel,
                  ),
                ],
              ),
              if (order.placedAt != null) ...[
                const SizedBox(height: 10),
                Text(
                  Formatters.dateTime(order.placedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          title: context.tr('items'),
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              [
                                if (item.sku != null && item.sku!.isNotEmpty)
                                  item.sku!,
                                '× ${item.quantity}',
                              ].join(' · '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: context.dukavo.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.currency(item.lineTotal, order.currency),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          title: context.tr('orderSummary'),
          child: Column(
            children: [
              KeyValueRow(
                label: context.tr('subtotal'),
                value: Formatters.currency(order.subtotal, order.currency),
              ),
              if (order.discountTotal > 0)
                KeyValueRow(
                  label: context.tr('discount'),
                  value:
                      '-${Formatters.currency(order.discountTotal, order.currency)}',
                  valueColor: context.dukavo.success,
                ),
              if (order.taxTotal > 0)
                KeyValueRow(
                  label: context.tr('tax'),
                  value: Formatters.currency(order.taxTotal, order.currency),
                ),
              KeyValueRow(
                label: context.tr('delivery'),
                value: Formatters.currency(order.shippingTotal, order.currency),
              ),
              const Divider(height: 20),
              KeyValueRow(
                label: context.tr('total'),
                value: Formatters.currency(order.grandTotal, order.currency),
              ),
              if (order.paymentMethodLabel != null)
                KeyValueRow(
                  label: context.tr('paymentMethod'),
                  value: order.paymentMethodLabel!,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          title: context.tr('deliveryAddress'),
          child: Column(
            children: [
              KeyValueRow(
                label: context.tr('fullName'),
                value: order.customerName,
              ),
              KeyValueRow(
                label: context.tr('phone'),
                value: order.customerPhone,
              ),
              for (final entry in _addressLines(order.shippingAddress))
                KeyValueRow(
                  label: context.tr(entry.$1),
                  value: entry.$2,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 18,
                color: context.dukavo.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('saveTrackingLink'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: context.tr('continueShopping'),
          icon: Icons.storefront_outlined,
          expand: true,
          onPressed: () =>
              context.go(RoutePaths.shopStore(shop.tenant, shop.store)),
        ),
      ],
    );
  }

  List<(String, String)> _addressLines(Map<String, dynamic> address) {
    String? text(String key) {
      final value = address[key];
      if (value == null) return null;
      final result = '$value'.trim();
      return result.isEmpty ? null : result;
    }

    final lines = <(String, String)>[];
    void add(String labelKey, String? key) {
      final value = key == null ? null : text(key);
      if (value != null) lines.add((labelKey, value));
    }

    add('addressLineOne', 'line_one');
    add('addressLineTwo', 'line_two');
    add('city', 'city');
    add('area', 'area');
    add('state', 'state');
    add('postalCode', 'postal_code');
    add('country', 'country');
    return lines;
  }
}
