import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/shop_providers.dart';
import '../domain/shop_models.dart';
import 'shop_shell.dart';

class ShopProductScreen extends ConsumerStatefulWidget {
  const ShopProductScreen({
    super.key,
    required this.shop,
    required this.slug,
  });

  final ShopRef shop;
  final String slug;

  @override
  ConsumerState<ShopProductScreen> createState() => _ShopProductScreenState();
}

class _ShopProductScreenState extends ConsumerState<ShopProductScreen> {
  int? _variantId;
  int _quantity = 1;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      shopProductProvider((widget.shop, widget.slug)),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('productDetails')),
        actions: [
          IconButton(
            tooltip: context.tr('cart'),
            onPressed: () => context.go(
              RoutePaths.shopCart(widget.shop.tenant, widget.shop.store),
            ),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: shopErrorMessage(context, error),
          onRetry: () => ref.invalidate(
            shopProductProvider((widget.shop, widget.slug)),
          ),
        ),
        data: (product) => _body(context, product),
      ),
    );
  }

  Widget _body(BuildContext context, ShopProduct product) {
    final theme = Theme.of(context);
    final variants = product.variants;
    final selectedId = _variantId ??
        product.defaultVariant?.id ??
        (variants.isEmpty ? null : variants.first.id);
    final selected = variants.where((v) => v.id == selectedId).firstOrNull;
    final unitPrice = selected?.price ?? product.price;
    final inStock = selected?.inStock ?? product.inStock;
    final available = selected?.available ?? product.available;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              if (product.images.isNotEmpty)
                SizedBox(
                  height: 280,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: product.images.length,
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CachedNetworkImage(
                            imageUrl: product.images[index].url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                      if (product.images.length > 1)
                        PositionedDirectional(
                          bottom: 10,
                          start: 0,
                          end: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var index = 0;
                                  index < product.images.length;
                                  index++)
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.8,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              else
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.image_outlined, size: 48),
                ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (!product.inStock)
                    StatusChip(
                      status: 'out_of_stock',
                      label: context.tr('outOfStock'),
                    ),
                ],
              ),
              if (product.categoryName != null) ...[
                const SizedBox(height: 4),
                Text(
                  product.categoryName!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                Formatters.currency(unitPrice, product.currency),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (selected != null && selected.sku != null)
                Text(
                  '${context.tr('sku')}: ${selected.sku}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (variants.length > 1) ...[
                const SizedBox(height: 18),
                Text(
                  context.tr('chooseVariant'),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final variant in variants)
                      ChoiceChip(
                        label: Text(
                          variant.name.isEmpty
                              ? context.tr('defaultLabel')
                              : variant.name,
                        ),
                        selected: variant.id == selectedId,
                        onSelected: variant.inStock
                            ? (_) => setState(() {
                                  _variantId = variant.id;
                                  _quantity = 1;
                                })
                            : null,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    context.tr('quantity'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  _QuantityStepper(
                    quantity: _quantity,
                    max: available > 0 ? available : 99,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                ],
              ),
              if (inStock && available > 0 && available <= 5) ...[
                const SizedBox(height: 6),
                Text(
                  context.tr('onlyLeft', args: {'count': available}),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
              if (product.description?.isNotEmpty == true) ...[
                const SizedBox(height: 20),
                Text(
                  context.tr('description'),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  product.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('subtotalEstimate'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        Formatters.currency(
                          unitPrice * _quantity,
                          product.currency,
                        ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: inStock
                        ? context.tr('addToCart')
                        : context.tr('outOfStock'),
                    icon: Icons.add_shopping_cart,
                    expand: true,
                    onPressed: inStock
                        ? () => _addToCart(context, product, selected)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addToCart(
    BuildContext context,
    ShopProduct product,
    ShopVariant? variant,
  ) {
    if (variant == null) {
      AppSnack.show(context, context.tr('chooseVariant'), isError: true);
      return;
    }
    ref.read(cartProvider(widget.shop).notifier).add(
          ShopCartLine(
            productSlug: product.slug,
            productName: product.name,
            variantId: variant.id,
            variantName: variant.name,
            unitPrice: variant.price,
            currency: product.currency,
            quantity: _quantity,
            imageUrl: product.primaryImageUrl,
            maxQuantity: variant.available,
          ),
        );
    AppSnack.show(context, context.tr('addedToCart'));
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.tr('decrease'),
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: context.tr('increase'),
          onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
