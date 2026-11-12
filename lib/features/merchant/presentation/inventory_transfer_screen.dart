import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';

/// Move one product variant between two stores in the active workspace.
///
/// The server validates both stores, the variant and the quantity against the
/// tenant, so this screen only collects the four ids the endpoint accepts and
/// offers no local stock arithmetic.
class InventoryTransferScreen extends ConsumerStatefulWidget {
  const InventoryTransferScreen({super.key});

  @override
  ConsumerState<InventoryTransferScreen> createState() =>
      _InventoryTransferScreenState();
}

class _InventoryTransferScreenState
    extends ConsumerState<InventoryTransferScreen> {
  final TextEditingController _note = TextEditingController();
  final TextEditingController _quantity = TextEditingController(text: '1');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<JsonResource> _variants = const <JsonResource>[];
  bool _loadingVariants = true;
  String? _variantError;
  int? _fromStoreId;
  int? _toStoreId;
  String? _variantId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVariants());
  }

  @override
  void dispose() {
    _note.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _loadVariants() async {
    setState(() {
      _loadingVariants = true;
      _variantError = null;
    });
    try {
      final page = await ref.read(apiClientProvider).list<JsonResource>(
            ApiPaths.products,
            query: {'per_page': 100},
            item: JsonResource.fromJson,
          );
      final variants = <JsonResource>[];
      for (final product in page.items) {
        final raw = product.data['variants'];
        if (raw is! List) continue;
        for (final entry in raw.whereType<Map>()) {
          final variant = Map<String, dynamic>.from(entry);
          variant['_product_name'] = product.text('name');
          variants.add(JsonResource(variant));
        }
      }
      if (!mounted) return;
      setState(() {
        _variants = variants;
        _loadingVariants = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingVariants = false;
        _variantError = error is ApiException ? error.message : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canViewInventory) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('inventoryTransfer'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final canManage = permissions.canManageInventory;
    final stores = ref.watch(storeOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('inventoryTransfer'))),
      body: stores.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error is ApiException
              ? error.message
              : context.tr('errorGeneric'),
          onRetry: () => ref.invalidate(storeOptionsProvider),
        ),
        data: (list) => _body(context, list, canManage),
      ),
    );
  }

  Widget _body(BuildContext context, List<Store> stores, bool canManage) {
    if (stores.length < 2) {
      return EmptyState(
        icon: Icons.swap_horiz_rounded,
        title: context.tr('transferNeedsTwoStores'),
        message: context.tr('transferNeedsTwoStoresMessage'),
      );
    }
    final fromId = _fromStoreId ?? stores.first.id;
    final toId = _toStoreId ??
        stores.firstWhere((store) => store.id != fromId).id;
    final destinations = stores.where((store) => store.id != fromId).toList();

    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          InfoBanner(
            icon: Icons.info_outline_rounded,
            message: context.tr('inventoryTransferHint'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            key: const ValueKey('transfer-from-store'),
            initialValue: fromId,
            decoration: InputDecoration(labelText: context.tr('fromStore')),
            items: [
              for (final store in stores)
                DropdownMenuItem(value: store.id, child: Text(store.name)),
            ],
            onChanged: canManage
                ? (value) {
                    if (value == null) return;
                    setState(() {
                      _fromStoreId = value;
                      if (_toStoreId == value) _toStoreId = null;
                    });
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<int>(
            key: ValueKey('transfer-to-store-$fromId'),
            initialValue: destinations.any((store) => store.id == toId)
                ? toId
                : destinations.first.id,
            decoration: InputDecoration(labelText: context.tr('toStore')),
            items: [
              for (final store in destinations)
                DropdownMenuItem(value: store.id, child: Text(store.name)),
            ],
            onChanged: canManage
                ? (value) => setState(() => _toStoreId = value)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_loadingVariants)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: LoadingView(),
            )
          else if (_variantError != null)
            ErrorView(message: _variantError!, onRetry: _loadVariants)
          else if (_variants.isEmpty)
            InfoBanner(
              icon: Icons.inventory_2_outlined,
              message: context.tr('noVariantsToTransfer'),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _variantId,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.tr('productVariant')),
              items: [
                for (final variant in _variants)
                  DropdownMenuItem(
                    value: '${variant.id}',
                    child: Text(
                      _variantLabel(variant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              validator: (value) => value == null
                  ? context.tr('requiredField')
                  : null,
              onChanged: canManage
                  ? (value) => setState(() => _variantId = value)
                  : null,
            ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _quantity,
            readOnly: !canManage,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.tr('quantity')),
            validator: (value) {
              final parsed = int.tryParse(value?.trim() ?? '');
              if (parsed == null || parsed < 1) {
                return context.tr('invalidNumber');
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _note,
            readOnly: !canManage,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(labelText: context.tr('note')),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: context.tr('transferStock'),
            icon: Icons.swap_horiz_rounded,
            expand: true,
            loading: _saving,
            onPressed:
                !canManage || _variants.isEmpty ? null : () => _submit(fromId, toId),
          ),
        ],
      ),
    );
  }

  String _variantLabel(JsonResource variant) {
    final product = variant.text('_product_name');
    final name = variant.text('name');
    final sku = variant.text('sku');
    return [
      if (product.isNotEmpty) product,
      if (name.isNotEmpty) name,
      if (sku.isNotEmpty) sku,
    ].join(' · ');
  }

  Future<void> _submit(int fromId, int toId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final variantId = int.tryParse(_variantId ?? '');
    if (variantId == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('transferStock'),
      message: context.tr('transferStockConfirm'),
      confirmLabel: context.tr('transferStock'),
    );
    if (!confirmed) return;
    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).post<dynamic>(
        ApiPaths.inventoryTransfers,
        body: {
          'from_store_id': fromId,
          'to_store_id': toId,
          'product_variant_id': variantId,
          'quantity': int.parse(_quantity.text.trim()),
          if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
        },
      );
      if (!mounted) return;
      AppSnack.show(context, context.tr('stockTransferred'));
      setState(() {
        _saving = false;
        _quantity.text = '1';
        _note.clear();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    }
  }
}
