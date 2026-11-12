import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/shop_providers.dart';
import '../domain/shop_models.dart';

/// Chrome for one public storefront.
///
/// The cart badge is the only stateful part. A shopper can browse without a
/// session, so nothing here reads the authenticated session or permissions.
class ShopShell extends ConsumerWidget {
  const ShopShell({
    super.key,
    required this.shop,
    required this.location,
    required this.child,
  });

  final ShopRef shop;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(shopInfoProvider(shop)).valueOrNull;
    final cart = ref.watch(cartProvider(shop));
    final count = cart.fold<int>(0, (total, line) => total + line.quantity);
    final onCart = location.endsWith('/cart');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (info?.logoUrl != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CachedNetworkImage(
                      imageUrl: info!.logoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.storefront_outlined, size: 20),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: Text(
                info?.name ?? context.tr('shop'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.tr('trackOrder'),
            onPressed: () =>
                context.go(RoutePaths.shopTrack(shop.tenant, shop.store)),
            icon: const Icon(Icons.local_shipping_outlined),
          ),
          IconButton(
            tooltip: context.tr('about'),
            onPressed: () => _showStoreInfo(context, info),
            icon: const Icon(Icons.info_outline),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: context.tr('cart'),
                onPressed: onCart
                    ? null
                    : () => context
                        .go(RoutePaths.shopCart(shop.tenant, shop.store)),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if (count > 0)
                PositionedDirectional(
                  top: 6,
                  end: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: onCart ? 1 : 0,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go(RoutePaths.shopStore(shop.tenant, shop.store));
          } else {
            context.go(RoutePaths.shopCart(shop.tenant, shop.store));
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: context.tr('shop'),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: context.tr('cart'),
          ),
        ],
      ),
    );
  }

  void _showStoreInfo(BuildContext context, StorefrontInfo? info) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info?.name ?? context.tr('shop'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (info?.description.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(info!.description),
              ],
              if (info?.address != null) ...[
                const SizedBox(height: 12),
                KeyValueRow(
                  label: context.tr('address'),
                  value: info!.address!,
                ),
              ],
              if (info?.openingHours != null)
                KeyValueRow(
                  label: context.tr('openingHours'),
                  value: info!.openingHours!,
                ),
              if (info?.phone != null)
                KeyValueRow(
                  label: context.tr('phone'),
                  value: info!.phone!,
                ),
              if (info?.email != null)
                KeyValueRow(
                  label: context.tr('email'),
                  value: info!.email!,
                ),
              if (info?.deliveryNote != null) ...[
                const SizedBox(height: 12),
                Text(
                  info!.deliveryNote!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (info?.returnPolicy != null) ...[
                const SizedBox(height: 12),
                Text(
                  info!.returnPolicy!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('viewDukavo'),
                icon: Icons.open_in_new,
                expand: true,
                variant: AppButtonVariant.outlined,
                onPressed: () => context.push(RoutePaths.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The storefront catalogue: store story, categories, search and the products.
class ShopHomeScreen extends ConsumerStatefulWidget {
  const ShopHomeScreen({super.key, required this.shop});

  final ShopRef shop;

  @override
  ConsumerState<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends ConsumerState<ShopHomeScreen> {
  final _search = TextEditingController();

  List<ShopProduct> _items = const [];
  String? _category;
  String _sort = '';
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    } else {
      if (_loadingMore || _page >= _lastPage) return;
      setState(() => _loadingMore = true);
    }
    try {
      final page = await ref.read(shopRepositoryProvider).products(
            widget.shop.tenant,
            widget.shop.store,
            search: _search.text.trim(),
            category: _category,
            sort: _sort,
            page: reset ? 1 : _page + 1,
          );
      if (!mounted) return;
      setState(() {
        _items = reset ? page.items : [..._items, ...page.items];
        _page = page.meta.currentPage;
        _lastPage = page.meta.lastPage;
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = _message(error);
      });
    }
  }

  Future<void> _trackOrder(BuildContext context) async {
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('trackOrder')),
        content: AppTextField(
          controller: controller,
          label: context.tr('trackingToken'),
          helper: context.tr('trackingTokenHint'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(context.tr('track')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (token == null || token.isEmpty) return;
    if (!context.mounted) return;
    context.push(
      RoutePaths.shopOrder(widget.shop.tenant, widget.shop.store, token),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(shopInfoProvider(widget.shop));
    final categories = ref.watch(shopCategoriesProvider(widget.shop));
    final theme = Theme.of(context);
    ref.listen(effectiveLocaleProvider, (previous, next) {
      if (previous != next) {
        _load();
      }
    });
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(shopInfoProvider(widget.shop));
        ref.invalidate(shopCategoriesProvider(widget.shop));
        await _load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          info.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: LinearProgressIndicator(),
            ),
            error: (error, stack) => ErrorView(
              message: _message(error),
              onRetry: () => ref.invalidate(shopInfoProvider(widget.shop)),
            ),
            data: (store) => _StoreHeader(info: store),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => _trackOrder(context),
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: Text(context.tr('trackOrder')),
            ),
          ),
          const SizedBox(height: 14),
          SearchField(
            controller: _search,
            hint: context.tr('searchProducts'),
            onSubmitted: (_) => _load(),
          ),
          const SizedBox(height: 10),
          categories.when(
            loading: () => const SizedBox(height: 44),
            error: (error, stack) => const SizedBox.shrink(),
            data: (items) => items.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(context.tr('all')),
                            selected: _category == null,
                            onSelected: (_) {
                              setState(() => _category = null);
                              _load();
                            },
                          ),
                        ),
                        for (final category in items)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: ChoiceChip(
                              label: Text(
                                '${category.name} (${category.productsCount})',
                              ),
                              selected: _category == category.slug,
                              onSelected: (_) {
                                setState(() => _category = category.slug);
                                _load();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('products'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              DropdownButton<String>(
                value: _sort,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(context.tr('sortRecommended')),
                  ),
                  DropdownMenuItem(
                    value: 'newest',
                    child: Text(context.tr('sortNewest')),
                  ),
                  DropdownMenuItem(
                    value: 'price_asc',
                    child: Text(context.tr('sortPriceLow')),
                  ),
                  DropdownMenuItem(
                    value: 'price_desc',
                    child: Text(context.tr('sortPriceHigh')),
                  ),
                  DropdownMenuItem(
                    value: 'name',
                    child: Text(context.tr('sortName')),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _sort = value ?? '');
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_error != null) ...[
            ErrorView(message: _error!, onRetry: _load),
            const SizedBox(height: 12),
          ],
          if (_loading && _items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: LoadingView(),
            )
          else if (!_loading && _items.isEmpty)
            EmptyState(
              title: context.tr('noProducts'),
              icon: Icons.shopping_bag_outlined,
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 3 : 2;
                final width =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final product in _items)
                      SizedBox(
                        width: width,
                        child: _ShopProductCard(
                          shop: widget.shop,
                          product: product,
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_page < _lastPage)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: AppButton(
                  label: context.tr('loadMore'),
                  variant: AppButtonVariant.outlined,
                  loading: _loadingMore,
                  onPressed: () => _load(reset: false),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.info});

  final StorefrontInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = info.heroImageUrl;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.primary,
      ),
      child: Stack(
        children: [
          if (image != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          if (image != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info.logoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CachedNetworkImage(
                          imageUrl: info.logoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.storefront_outlined),
                        ),
                      ),
                    ),
                  ),
                Text(
                  info.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (info.tagline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    info.tagline!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                if (info.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    info.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                if (info.deliveryNote != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          info.deliveryNote!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopProductCard extends StatelessWidget {
  const _ShopProductCard({required this.shop, required this.product});

  final ShopRef shop;
  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          RoutePaths.shopProduct(shop.tenant, shop.store, product.slug),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.primaryImageUrl == null
                  ? Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: product.primaryImageUrl!,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (product.summary != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (product.categoryName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.categoryName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.currency(product.price, product.currency),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (!product.inStock)
                        StatusChip(
                          status: 'out_of_stock',
                          label: context.tr('outOfStock'),
                          compact: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `/shop` without a store. There is no public store directory endpoint, so the
/// app says so honestly instead of guessing a store.
class ShopLandingScreen extends StatelessWidget {
  const ShopLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('shop'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('shopLinkRequired'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('shopLinkRequiredHint'),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: context.tr('aboutDukavo'),
                icon: Icons.open_in_new,
                onPressed: () => context.push(RoutePaths.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _message(Object error) =>
    error is ApiException ? error.message : 'Something went wrong.';

/// Exposed so the checkout screen can reuse the same paginated error text.
String shopErrorMessage(BuildContext context, Object error) =>
    error is ApiException ? error.message : context.tr('errorGeneric');
