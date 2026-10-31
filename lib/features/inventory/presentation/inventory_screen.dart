import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_domain.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryListProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryListProvider);
    final notifier = ref.read(inventoryListProvider.notifier);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('inventory')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: notifier.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(context.tr('all')),
                    selected: !notifier.lowStockOnly,
                    onSelected: (_) => notifier.setLowStockOnly(false),
                  ),
                ),
                ChoiceChip(
                  label: Text(context.tr('lowStock')),
                  selected: notifier.lowStockOnly,
                  onSelected: (_) => notifier.setLowStockOnly(true),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagedListView<InventoryItem>(
              state: state,
              onRefresh: notifier.reload,
              onLoadMore: notifier.loadMore,
              empty: EmptyState(
                title: context.tr('noInventory'),
                icon: Icons.warehouse_outlined,
              ),
              itemBuilder: (context, item, index) {
                return _InventoryTile(
                  item: item,
                  onTap: () => _openSheet(context, ref, item, permissions),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSheet(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
    Permissions permissions,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _StockSheet(item: item, canManage: permissions.canManageInventory),
      ),
    );
    if (context.mounted) {
      await ref.read(inventoryListProvider.notifier).reload();
    }
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.item, required this.onTap});

  final InventoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (item.isLowStock ? AppColors.danger : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: item.isLowStock ? AppColors.danger : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (item.variantName != null) item.variantName!,
                        if (item.productSku != null) item.productSku!,
                        if (item.storeName != null) item.storeName!,
                      ].join(' · '),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.available}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: item.isLowStock ? AppColors.danger : null,
                    ),
                  ),
                  StatusChip(
                    status: item.isLowStock ? 'low_stock' : 'in_stock',
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockSheet extends ConsumerStatefulWidget {
  const _StockSheet({required this.item, required this.canManage});

  final InventoryItem item;
  final bool canManage;

  @override
  ConsumerState<_StockSheet> createState() => _StockSheetState();
}

class _StockSheetState extends ConsumerState<_StockSheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final movements = ref.watch(inventoryMovementsProvider(item.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(item.displayName, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                [
                  if (item.variantName != null) item.variantName!,
                  if (item.storeName != null) item.storeName!,
                ].join(' · '),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      label: context.tr('stock'),
                      value: Formatters.number(item.quantity),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Stat(
                      label: context.tr('reserved'),
                      value: Formatters.number(item.reserved),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Stat(
                      label: context.tr('available'),
                      value: Formatters.number(item.available),
                      color: item.available <= 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
              if (widget.canManage) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: context.tr('adjustStock'),
                        icon: Icons.tune,
                        variant: AppButtonVariant.outlined,
                        onPressed: _busy ? null : () => _move(adjust: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: context.tr('receiveStock'),
                        icon: Icons.add_box_outlined,
                        onPressed: _busy ? null : () => _move(adjust: false),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Text(context.tr('movements'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: movements.when(
                  loading: () => const LoadingView(),
                  error: (error, stack) => ErrorView(
                    message: error.toString(),
                    onRetry: () =>
                        ref.invalidate(inventoryMovementsProvider(item.id)),
                  ),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Text(context.tr('noData')),
                      );
                    }
                    return ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 18),
                      itemBuilder: (context, index) {
                        final movement = entries[index];
                        return _MovementRow(movement: movement);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _move({required bool adjust}) async {
    final item = widget.item;
    final result = await showDialog<_MovementResult>(
      context: context,
      builder: (dialogContext) => _MovementDialog(
        item: item,
        adjust: adjust,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      final draft = StockMovementDraft(
        inventoryId: item.id,
        storeId: item.storeId,
        productVariantId: item.productVariantId,
        quantity: result.quantity,
        note: result.note,
        lowStockThreshold: result.threshold,
      );
      if (adjust) {
        await ref.read(inventoryActionsProvider).adjust(draft);
      } else {
        await ref.read(inventoryActionsProvider).receive(draft);
      }
      if (!mounted) return;
      AppSnack.show(
        context,
        context.tr(adjust ? 'stockAdjusted' : 'stockReceived'),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _MovementResult {
  const _MovementResult({
    required this.quantity,
    this.note,
    this.threshold,
  });

  final int quantity;
  final String? note;
  final int? threshold;
}

class _MovementDialog extends StatefulWidget {
  const _MovementDialog({required this.item, required this.adjust});

  final InventoryItem item;
  final bool adjust;

  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _note = TextEditingController();
  final _threshold = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.adjust) {
      _quantity.text = '${widget.item.quantity}';
      _threshold.text = widget.item.lowStockThreshold?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    _threshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.tr(widget.adjust ? 'adjustStock' : 'receiveStock'),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _quantity,
                label: context.tr(
                  widget.adjust ? 'newQuantity' : 'quantity',
                ),
                prefixIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: widget.adjust
                    ? (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return context.tr('mustBePositive');
                        }
                        return null;
                      }
                    : Validators.positiveInteger,
              ),
              if (widget.adjust) ...[
                const SizedBox(height: 10),
                AppTextField(
                  controller: _threshold,
                  label: context.tr('threshold'),
                  helper: context.tr('optional'),
                  prefixIcon: Icons.warning_amber_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed < 0) {
                      return context.tr('invalidNumber');
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 10),
              AppTextField(
                controller: _note,
                label: context.tr('note'),
                helper: context.tr('optional'),
                maxLines: 2,
                minLines: 1,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(
              _MovementResult(
                quantity: int.tryParse(_quantity.text.trim()) ?? 0,
                note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                threshold: widget.adjust
                    ? int.tryParse(_threshold.text.trim())
                    : null,
              ),
            );
          },
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});

  final InventoryMovement movement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = movement.isInbound ? AppColors.success : AppColors.danger;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            movement.isInbound ? Icons.south_west : Icons.north_east,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      movement.typeLabel,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${movement.isInbound ? '+' : '−'}${movement.quantity}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Text(
                [
                  Formatters.dateTime(movement.createdAt),
                  if (movement.userName != null) movement.userName!,
                ].join(' · '),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              if (movement.note != null && movement.note!.isNotEmpty)
                Text(
                  movement.note!,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
