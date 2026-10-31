import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/product_controller.dart';
import '../domain/product_domain.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(productDetailProvider(slug));
    final permissions = ref.watch(permissionsProvider);
    final currency = ref.watch(currentSessionProvider)?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('productDetails')),
        actions: [
          if (permissions.canManageProducts)
            IconButton(
              tooltip: context.tr('edit'),
              onPressed: () => context.push(RoutePaths.productEdit(slug)),
              icon: const Icon(Icons.edit_outlined),
            ),
          if (permissions.canManageProducts)
            IconButton(
              tooltip: context.tr('delete'),
              onPressed: () => _delete(context, ref),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(slug)),
        ),
        data: (product) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (product.images.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CachedNetworkImage(
                          imageUrl: product.images[index].url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (product.sku != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.sku!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                StatusChip(status: product.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: context.tr('price'),
                    value: Formatters.currency(product.price, currency),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(
                    label: context.tr('cost'),
                    value: Formatters.currency(product.cost, currency),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Stat(
                    label: context.tr('available'),
                    value: Formatters.number(product.stock.available),
                    color: product.stock.available <= 0
                        ? AppColors.danger
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: context.tr('details'),
              child: Column(
                children: [
                  KeyValueRow(
                    label: context.tr('category'),
                    value: product.categoryName ?? '—',
                  ),
                  KeyValueRow(
                    label: context.tr('stock'),
                    value: Formatters.number(product.stock.quantity),
                  ),
                  KeyValueRow(
                    label: context.tr('reserved'),
                    value: Formatters.number(product.stock.reserved),
                  ),
                  KeyValueRow(
                    label: context.tr('tax'),
                    value: product.isTaxable ? context.tr('yes') : context.tr('no'),
                  ),
                  KeyValueRow(
                    label: context.tr('createdAt'),
                    value: Formatters.date(product.createdAt),
                  ),
                ],
              ),
            ),
            if (product.variants.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: context.tr('variant'),
                child: Column(
                  children: [
                    for (final variant in product.variants)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    variant.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (variant.sku != null)
                                    Text(
                                      variant.sku!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(variant.price, currency),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${variant.stock.available}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (product.description != null &&
                product.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: context.tr('description'),
                child: Text(
                  product.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('deleteConfirmTitle'),
      message: context.tr('deleteConfirmMessage'),
      confirmLabel: context.tr('confirmDelete'),
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(productActionsProvider).delete(slug);
      if (context.mounted) {
        AppSnack.show(context, context.tr('productDeleted'));
        context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        AppSnack.show(context, error.toString(), isError: true);
      }
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
