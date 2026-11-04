import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';
import '../../stores/presentation/store_selector_field.dart';
import '../application/shipping_controller.dart';
import '../domain/shipping_domain.dart';

/// Delivery zones for one store.
///
/// Fees are calculated again on the server at checkout; this screen only tells
/// the merchant what customers will be charged for a given city or area.
class ShippingZonesScreen extends ConsumerStatefulWidget {
  const ShippingZonesScreen({super.key});

  @override
  ConsumerState<ShippingZonesScreen> createState() =>
      _ShippingZonesScreenState();
}

class _ShippingZonesScreenState extends ConsumerState<ShippingZonesScreen> {
  int? _storeId;

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storeOptionsProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('shippingZones')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              final stores = storesAsync.valueOrNull ?? const <Store>[];
              final id = _resolveStoreId(stores);
              if (id != null) ref.invalidate(shippingZonesProvider(id));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: permissions.canManageShipping
          ? storesAsync.maybeWhen(
              data: (stores) {
                final id = _resolveStoreId(stores);
                if (id == null) return null;
                return FloatingActionButton.extended(
                  onPressed: () => _openEditor(id),
                  icon: const Icon(Icons.add),
                  label: Text(context.tr('addShippingZone')),
                );
              },
              orElse: () => null,
            )
          : null,
      body: storesAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(storeOptionsProvider),
        ),
        data: (stores) {
          if (stores.isEmpty) {
            return EmptyState(
              title: context.tr('noStores'),
              message: context.tr('noStoresMessage'),
              icon: Icons.store_mall_directory_outlined,
            );
          }

          final storeId = _resolveStoreId(stores)!;
          final zonesAsync = ref.watch(shippingZonesProvider(storeId));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: StoreSelectorField(
                  stores: stores,
                  selectedId: storeId,
                  onChanged: (value) => setState(() => _storeId = value),
                ),
              ),
              Expanded(
                child: zonesAsync.when(
                  loading: () => const LoadingView(),
                  error: (error, stack) => ErrorView(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(shippingZonesProvider(storeId)),
                  ),
                  data: (zones) {
                    if (zones.isEmpty) {
                      return EmptyState(
                        title: context.tr('noShippingZones'),
                        message: context.tr('noShippingZonesMessage'),
                        icon: Icons.local_shipping_outlined,
                        actionLabel: permissions.canManageShipping
                            ? context.tr('addShippingZone')
                            : null,
                        onAction: permissions.canManageShipping
                            ? () => _openEditor(storeId)
                            : null,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(shippingZonesProvider(storeId));
                        await ref.read(shippingZonesProvider(storeId).future);
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        children: [
                          Text(
                            context.tr('shippingZonesIntro'),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          for (final zone in zones)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ZoneCard(
                                zone: zone,
                                currencyCode: stores
                                    .firstWhere((store) => store.id == storeId)
                                    .currency,
                                canManage: permissions.canManageShipping,
                                onEdit: () => _openEditor(storeId, zone: zone),
                                onDelete: () => _delete(storeId, zone),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int? _resolveStoreId(List<Store> stores) {
    if (stores.isEmpty) return null;
    if (_storeId != null && stores.any((store) => store.id == _storeId)) {
      return _storeId;
    }
    return defaultStoreFrom(stores)?.id;
  }

  Future<void> _openEditor(int storeId, {ShippingZone? zone}) async {
    final result = await showModalBottomSheet<ShippingZoneDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _ZoneFormSheet(zone: zone),
      ),
    );
    if (result == null) return;

    try {
      if (zone == null) {
        await ref.read(shippingActionsProvider).create(storeId, result);
      } else {
        await ref
            .read(shippingActionsProvider)
            .update(storeId, zone.id, result);
      }
      if (!mounted) return;
      AppSnack.show(
        context,
        context
            .tr(zone == null ? 'shippingZoneCreated' : 'shippingZoneUpdated'),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _delete(int storeId, ShippingZone zone) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('deleteConfirmTitle'),
      message:
          context.tr('deleteShippingZoneMessage', args: {'name': zone.name}),
      confirmLabel: context.tr('confirmDelete'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(shippingActionsProvider).delete(storeId, zone.id);
      if (!mounted) return;
      AppSnack.show(context, context.tr('shippingZoneDeleted'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.zone,
    required this.currencyCode,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final ShippingZone zone;
  final String currencyCode;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Formatters.currency(zone.fee, currencyCode);
    final freeThreshold = zone.freeShippingThreshold;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          zone.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      StatusChip(
                        status: zone.isActive ? 'active' : 'inactive',
                        label:
                            context.tr(zone.isActive ? 'isActive' : 'inactive'),
                        compact: true,
                      ),
                    ],
                  ),
                  if (zone.coverage.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      zone.coverage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _Metric(
                        label: context.tr('deliveryFee'),
                        value: currency,
                      ),
                      if (freeThreshold != null)
                        _Metric(
                          label: context.tr('freeShippingOver'),
                          value:
                              Formatters.currency(freeThreshold, currencyCode),
                        ),
                      _Metric(
                        label: context.tr('sortOrder'),
                        value: '${zone.sortOrder}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (canManage)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(context.tr('edit')),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(context.tr('delete')),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ZoneFormSheet extends StatefulWidget {
  const _ZoneFormSheet({this.zone});

  final ShippingZone? zone;

  @override
  State<_ZoneFormSheet> createState() => _ZoneFormSheetState();
}

class _ZoneFormSheetState extends State<_ZoneFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.zone?.name ?? '');
  late final _city = TextEditingController(text: widget.zone?.city ?? '');
  late final _areas =
      TextEditingController(text: widget.zone?.areas.join(', ') ?? '');
  late final _fee = TextEditingController(
    text: widget.zone == null ? '' : '${widget.zone!.fee}',
  );
  late final _freeThreshold = TextEditingController(
    text: widget.zone?.freeShippingThreshold == null
        ? ''
        : '${widget.zone!.freeShippingThreshold}',
  );
  late final _sortOrder =
      TextEditingController(text: '${widget.zone?.sortOrder ?? 0}');
  late bool _isActive = widget.zone?.isActive ?? true;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _city,
      _areas,
      _fee,
      _freeThreshold,
      _sortOrder,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr(
                  widget.zone == null ? 'addShippingZone' : 'editShippingZone',
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _name,
                label: context.tr('zoneName'),
                validator: Validators.required,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _city,
                label: context.tr('city'),
                helper: context.tr('cityHint'),
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _areas,
                label: context.tr('areas'),
                helper: context.tr('areasHint'),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _fee,
                label: context.tr('deliveryFee'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.positiveNumber,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _freeThreshold,
                label: context.tr('freeShippingThreshold'),
                helper: context.tr('freeShippingThresholdHint'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = num.tryParse(value.trim());
                  if (parsed == null) return context.tr('enterNumber');
                  if (parsed < 0) return context.tr('enterPositiveNumber');
                  return null;
                },
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _sortOrder,
                label: context.tr('sortOrder'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null) return context.tr('enterWholeNumber');
                  if (parsed < 0) return context.tr('enterPositiveNumber');
                  return null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('isActive')),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.tr('cancel'),
                      variant: AppButtonVariant.outlined,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: context.tr('saveChanges'),
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final areas = _areas.text
        .split(',')
        .map((area) => area.trim())
        .where((area) => area.isNotEmpty)
        .toList();
    final threshold = num.tryParse(_freeThreshold.text.trim());

    Navigator.of(context).pop(
      ShippingZoneDraft(
        name: _name.text.trim(),
        city: _city.text.trim(),
        areas: areas,
        fee: num.parse(_fee.text.trim()),
        freeShippingThreshold: threshold,
        isActive: _isActive,
        sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      ),
    );
  }
}
