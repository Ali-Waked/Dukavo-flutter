import 'package:cached_network_image/cached_network_image.dart';
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

/// The client-held cart.
///
/// Prices shown here are the last ones the catalogue returned. They are an
/// estimate only: the server re-resolves every line, fee and total at checkout,
/// so the amount charged can differ and the checkout screen states that.
class ShopCartScreen extends ConsumerWidget {
  const ShopCartScreen({super.key, required this.shop});

  final ShopRef shop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider(shop));
    final notifier = ref.read(cartProvider(shop).notifier);
    final theme = Theme.of(context);

    if (cart.isEmpty) {
      return EmptyState(
        title: context.tr('cartEmpty'),
        message: context.tr('cartEmptyHint'),
        icon: Icons.shopping_bag_outlined,
        actionLabel: context.tr('continueShopping'),
        onAction: () =>
            context.go(RoutePaths.shopStore(shop.tenant, shop.store)),
      );
    }

    final currency = cart.first.currency;
    final subtotal = notifier.subtotal;

    return ListView(
      padding: AppSpacing.page,
      children: [
        for (final line in cart)
          _CartLineCard(
            shop: shop,
            line: line,
            onQuantityChanged: (quantity) =>
                notifier.setQuantity(line.variantId, quantity),
            onRemove: () => notifier.remove(line.variantId),
          ),
        const SizedBox(height: AppSpacing.xs),
        SectionCard(
          title: context.tr('orderSummary'),
          child: Column(
            children: [
              KeyValueRow(
                label: context.tr('items'),
                value: Formatters.number(
                  cart.fold<int>(0, (total, line) => total + line.quantity),
                ),
              ),
              KeyValueRow(
                label: context.tr('subtotal'),
                value: Formatters.currency(subtotal, currency),
              ),
              const Divider(height: 20),
              KeyValueRow(
                label: context.tr('estimatedTotal'),
                value: Formatters.currency(subtotal, currency),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: context.dukavo.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr('totalsResolvedAtCheckout'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.dukavo.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: context.tr('proceedToCheckout'),
          icon: Icons.arrow_forward,
          expand: true,
          onPressed: () => context.go(
            RoutePaths.shopCheckout(shop.tenant, shop.store),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: context.tr('continueShopping'),
          variant: AppButtonVariant.text,
          expand: true,
          onPressed: () =>
              context.go(RoutePaths.shopStore(shop.tenant, shop.store)),
        ),
      ],
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({
    required this.shop,
    required this.line,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final ShopRef shop;
  final ShopCartLine line;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = line.maxQuantity > 0 ? line.maxQuantity : 99;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.dukavo.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.dukavo.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () => context.push(
              RoutePaths.shopProduct(
                  shop.tenant, shop.store, line.productSlug),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 78,
                height: 78,
                child: line.imageUrl == null
                    ? Container(
                        color: context.dukavo.surfaceHigh,
                        child: Icon(
                          Icons.image_outlined,
                          color: context.dukavo.textMuted,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: line.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: context.dukavo.surfaceHigh,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: context.dukavo.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        line.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('remove'),
                      visualDensity: VisualDensity.compact,
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: context.dukavo.danger,
                      ),
                    ),
                  ],
                ),
                if (line.variantName.isNotEmpty)
                  Text(
                    line.variantName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.dukavo.textMuted,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      Formatters.currency(line.unitPrice, line.currency),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _Stepper(
                      quantity: line.quantity,
                      max: max,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    Formatters.currency(line.lineTotal, line.currency),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.dukavo.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: context.tr('decrease'),
            visualDensity: VisualDensity.compact,
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          IconButton(
            tooltip: context.tr('increase'),
            visualDensity: VisualDensity.compact,
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
