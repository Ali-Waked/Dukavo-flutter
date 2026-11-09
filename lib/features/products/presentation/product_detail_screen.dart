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
              tooltip: context.tr('productImages'),
              onPressed: () => context.push(RoutePaths.productImages(slug)),
              icon: const Icon(Icons.photo_library_outlined),
            ),
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
          padding: AppSpacing.page,
          children: [
            if (product.images.isNotEmpty)
              SizedBox(
                height: 240,
                child: PageView.builder(
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: CachedNetworkImage(
                          imageUrl: product.images[index].url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: context.dukavo.surfaceHigh,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: context.dukavo.surfaceHigh,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: context.dukavo.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.dukavo.surfaceHigh,
                      context.dukavo.surfaceLow,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: context.dukavo.border),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 44,
                  color: context.dukavo.textMuted,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: context.texts.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            if (product.sku != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                product.sku!,
                                style: context.texts.bodySmall?.copyWith(
                                  color: context.dukavo.textMuted,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: product.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: context.tr('price'),
                          value: Formatters.currency(product.price, currency),
                          color: context.scheme.primary,
                          icon: Icons.sell_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _Stat(
                          label: context.tr('cost'),
                          value: Formatters.currency(product.cost, currency),
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _Stat(
                          label: context.tr('available'),
                          value: Formatters.number(product.stock.available),
                          color: product.stock.available <= 0
                              ? context.dukavo.danger
                              : context.dukavo.success,
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
                    value: product.isTaxable
                        ? context.tr('yes')
                        : context.tr('no'),
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
  const _Stat({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  final String label;
  final String value;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? context.dukavo.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.dukavo.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: accent),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.dukavo.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? context.dukavo.textPrimary,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
