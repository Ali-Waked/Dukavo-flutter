import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/product_controller.dart';
import '../domain/product_domain.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ref.read(productListProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);
    final permissions = ref.watch(permissionsProvider);
    final currency = ref.watch(currentSessionProvider)?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('products')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: notifier.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: permissions.canCreateProducts
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RoutePaths.createProduct),
              icon: const Icon(Icons.add),
              label: Text(context.tr('createProduct')),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.xxs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: SearchField(
              controller: _search,
              hint: context.tr('searchProducts'),
              onChanged: _onSearch,
              onSubmitted: notifier.setSearch,
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              children: [
                for (final entry in const <String?, String>{
                  null: 'active',
                  'draft': 'draft',
                  'archived': 'archived',
                  '': 'all',
                }.entries)
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(context.tr(entry.value)),
                      selected: notifier.status == entry.key,
                      onSelected: (_) => notifier.setStatus(entry.key),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Expanded(
            child: PagedListView<Product>(
              state: state,
              onRefresh: notifier.reload,
              onLoadMore: notifier.loadMore,
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                96,
              ),
              empty: EmptyState(
                title: context.tr('noProducts'),
                icon: Icons.inventory_2_outlined,
                actionLabel: permissions.canCreateProducts
                    ? context.tr('addFirstProduct')
                    : null,
                onAction: permissions.canCreateProducts
                    ? () => context.push(RoutePaths.createProduct)
                    : null,
              ),
              itemBuilder: (context, product, index) {
                return _ProductCard(
                  product: product,
                  currency: currency,
                  onTap: () => context.push(RoutePaths.product(product.slug)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.currency,
    required this.onTap,
  });

  final Product product;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    final texts = context.texts;
    final imageUrl = product.primaryImageUrl;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            child: SizedBox(
              width: 64,
              height: 64,
              child: imageUrl == null || imageUrl.isEmpty
                  ? Container(
                      color: colors.surfaceHigh,
                      child: Icon(
                        Icons.image_outlined,
                        color: colors.textMuted,
                        size: 22,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: colors.surfaceHigh),
                      errorWidget: (context, url, error) => Container(
                        color: colors.surfaceHigh,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: texts.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.sku ??
                      product.categoryName ??
                      product.slug,
                  style: texts.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      Formatters.currency(product.price, currency),
                      style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _StockChip(stock: product.stock),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({required this.stock});

  final ProductStock stock;

  @override
  Widget build(BuildContext context) {
    if (stock.available <= 0) {
      return const StatusChip(status: 'out_of_stock', compact: true);
    }
    return StatusChip(
      status: stock.available <= 5 ? 'low_stock' : 'in_stock',
      label: '${stock.available} ${context.tr('units')}',
      compact: true,
    );
  }
}
