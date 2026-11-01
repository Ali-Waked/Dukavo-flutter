import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../customers/application/customer_controller.dart';
import '../../customers/domain/customer_domain.dart';
import '../../products/application/product_controller.dart';
import '../../stores/application/store_controller.dart';
import '../application/order_controller.dart';
import '../domain/order_domain.dart';

const _orderStatuses = <String>[
  'pending',
  'confirmed',
  'processing',
  'shipped',
  'delivered',
  'cancelled',
];

String _statusLabel(BuildContext context, String status) {
  switch (status) {
    case 'partially_paid':
      return context.tr('partiallyPaid');
    case 'low_stock':
      return context.tr('lowStock');
    default:
      return context.tr(status);
  }
}

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListProvider);
    final notifier = ref.read(orderListProvider.notifier);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('orders')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: notifier.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: permissions.canCreateOrders
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RoutePaths.createOrder),
              icon: const Icon(Icons.add),
              label: Text(context.tr('createOrder')),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SearchField(
              controller: _search,
              hint: context.tr('searchOrders'),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => notifier.setSearch(value),
                );
              },
              onSubmitted: notifier.setSearch,
            ),
          ),
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
                    selected: notifier.status == null,
                    onSelected: (_) => notifier.setStatus(null),
                  ),
                ),
                for (final status in _orderStatuses)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(_statusLabel(context, status)),
                      selected: notifier.status == status,
                      onSelected: (_) => notifier.setStatus(
                        notifier.status == status ? null : status,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PagedListView<Order>(
              state: state,
              onRefresh: notifier.reload,
              onLoadMore: notifier.loadMore,
              empty: EmptyState(
                title: context.tr('noOrders'),
                icon: Icons.receipt_long_outlined,
                actionLabel: permissions.canCreateOrders
                    ? context.tr('createOrder')
                    : null,
                onAction: permissions.canCreateOrders
                    ? () => context.push(RoutePaths.createOrder)
                    : null,
              ),
              itemBuilder: (context, order, index) => _OrderTile(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(RoutePaths.order(order.orderNumber)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    Formatters.currency(order.grandTotal, order.currency),
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.displayCustomer,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusChip(status: order.status, compact: true),
                  const SizedBox(width: 6),
                  StatusChip(status: order.paymentStatus, compact: true),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                [
                  Formatters.dateTime(order.placedAt ?? order.createdAt),
                  if (order.itemCount != null)
                    context.tr('itemsCount', args: {'count': order.itemCount}),
                ].join(' · '),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderNumber});

  final String orderNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderDetailProvider(orderNumber));
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(orderNumber),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(orderDetailProvider(orderNumber)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderNumber)),
        ),
        data: (order) => _OrderDetailBody(
          order: order,
          canUpdate: permissions.canUpdateOrders,
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerStatefulWidget {
  const _OrderDetailBody({required this.order, required this.canUpdate});

  final Order order;
  final bool canUpdate;

  @override
  ConsumerState<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends ConsumerState<_OrderDetailBody> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('grandTotal'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currency(
                              order.grandTotal,
                              order.currency,
                            ),
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusChip(status: order.status),
                        const SizedBox(height: 6),
                        StatusChip(status: order.paymentStatus),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.dateTime(order.placedAt ?? order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.canUpdate) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: context.tr('changeStatus'),
                          icon: Icons.swap_horiz,
                          loading: _busy,
                          onPressed: order.allowedTransitions.isEmpty
                              ? null
                              : _changeStatus,
                        ),
                      ),
                      if (order.paymentStatus != 'paid' &&
                          order.paymentStatus != 'refunded') ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: context.tr('paymentMarkPaid'),
                            variant: AppButtonVariant.outlined,
                            icon: Icons.payments_outlined,
                            loading: _busy,
                            onPressed: order.allowedTransitions.isEmpty
                                ? null
                                : () => _changeStatus(markPaid: true),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (order.allowedTransitions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.tr('allowedTransitions'),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: context.tr('orderItems'),
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (item.sku != null)
                              Text(
                                item.sku!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(item.lineTotal, order.currency),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${Formatters.number(item.quantity)} × '
                            '${Formatters.currency(item.unitPrice, order.currency)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: context.tr('summary'),
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
                      '− ${Formatters.currency(order.discountTotal, order.currency)}',
                ),
              if (order.taxTotal > 0)
                KeyValueRow(
                  label: context.tr('tax'),
                  value: Formatters.currency(order.taxTotal, order.currency),
                ),
              if (order.shippingTotal > 0)
                KeyValueRow(
                  label: context.tr('shipping'),
                  value:
                      Formatters.currency(order.shippingTotal, order.currency),
                ),
              const Divider(height: 18),
              KeyValueRow(
                label: context.tr('grandTotal'),
                value: Formatters.currency(order.grandTotal, order.currency),
              ),
            ],
          ),
        ),
        if (order.customer != null || order.customerName != null) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('customer'),
            child: Column(
              children: [
                KeyValueRow(
                  label: context.tr('name'),
                  value: order.customer?.name ?? order.customerName ?? '—',
                ),
                KeyValueRow(
                  label: context.tr('phone'),
                  value: order.customer?.phone ?? order.customerPhone ?? '—',
                ),
                if (order.customer?.email != null)
                  KeyValueRow(
                    label: context.tr('email'),
                    value: order.customer!.email!,
                  ),
              ],
            ),
          ),
        ],
        if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('notes'),
            child: Text(order.notes!),
          ),
        ],
        if (order.statusHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('orderTimeline'),
            child: Column(
              children: [
                for (final entry in order.statusHistory)
                  _TimelineEntry(entry: entry),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _changeStatus({bool markPaid = false}) async {
    final order = widget.order;
    final allowed = order.allowedTransitions;
    if (allowed.isEmpty) return;

    final result = await showModalBottomSheet<_TransitionDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _TransitionSheet(
        order: order,
        allowed: allowed,
        markPaid: markPaid,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(orderActionsProvider).transition(
            order,
            status: result.status,
            note: result.note,
            paymentStatus: result.markPaid ? 'paid' : null,
          );
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.show(context, context.tr('statusUpdated'));
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry});

  final OrderHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fromStatus == null
                      ? _statusLabel(context, entry.toStatus)
                      : '${_statusLabel(context, entry.fromStatus!)} → '
                          '${_statusLabel(context, entry.toStatus)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (entry.note != null && entry.note!.trim().isNotEmpty)
                  Text(entry.note!, style: theme.textTheme.bodySmall),
                Text(
                  [
                    Formatters.dateTime(entry.createdAt),
                    if (entry.actorName != null) entry.actorName!,
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _TransitionDraft {
  const _TransitionDraft({
    required this.status,
    this.note,
    this.markPaid = false,
  });

  final String status;
  final String? note;
  final bool markPaid;
}

class _TransitionSheet extends StatefulWidget {
  const _TransitionSheet({
    required this.order,
    required this.allowed,
    required this.markPaid,
  });

  final Order order;
  final List<String> allowed;
  final bool markPaid;

  @override
  State<_TransitionSheet> createState() => _TransitionSheetState();
}

class _TransitionSheetState extends State<_TransitionSheet> {
  late String _status = widget.allowed.first;
  late bool _markPaid = widget.markPaid;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('changeStatus'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in widget.allowed)
                  ChoiceChip(
                    label: Text(_statusLabel(context, status)),
                    selected: _status == status,
                    onSelected: (_) => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _note,
              label: context.tr('orderTransitionNote'),
              helper: context.tr('optional'),
              maxLines: 3,
              minLines: 2,
            ),
            if (widget.order.paymentStatus != 'paid' &&
                widget.order.paymentStatus != 'refunded')
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('paymentMarkPaid')),
                value: _markPaid,
                onChanged: (value) => setState(() => _markPaid = value),
              ),
            const SizedBox(height: 12),
            AppButton(
              label: context.tr('confirm'),
              expand: true,
              onPressed: () => Navigator.of(context).pop(
                _TransitionDraft(
                  status: _status,
                  note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                  markPaid: _markPaid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderLineDraft {
  _OrderLineDraft({required this.option});

  final ProductOption option;
  int quantity = 1;

  num get lineTotal => option.variant.price * quantity;
}

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _walkInName = TextEditingController();
  final _walkInPhone = TextEditingController();
  final _notes = TextEditingController();

  Customer? _customer;
  final List<_OrderLineDraft> _lines = [];
  bool _submitting = false;

  @override
  void dispose() {
    _walkInName.dispose();
    _walkInPhone.dispose();
    _notes.dispose();
    super.dispose();
  }

  num get _estimatedTotal =>
      _lines.fold<num>(0, (sum, line) => sum + line.lineTotal);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = ref.watch(defaultStoreProvider);
    final options = ref.watch(productOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('createOrder'))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              SectionCard(
                title: context.tr('customer'),
                trailing: TextButton(
                  onPressed: _pickCustomer,
                  child: Text(context.tr('selectCustomer')),
                ),
                child: _customer == null
                    ? Column(
                        children: [
                          AppTextField(
                            controller: _walkInName,
                            label: context.tr('customerName'),
                            helper: context.tr('optional'),
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: _walkInPhone,
                            label: context.tr('customerPhone'),
                            helper: context.tr('optional'),
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      )
                    : ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AppAvatar(name: _customer!.name, size: 40),
                        title: Text(_customer!.name),
                        subtitle:
                            Text(_customer!.phone ?? _customer!.email ?? '—'),
                        trailing: IconButton(
                          tooltip: context.tr('clear'),
                          onPressed: () => setState(() => _customer = null),
                          icon: const Icon(Icons.close),
                        ),
                      ),
              ),
              if (store != null) ...[
                const SizedBox(height: 12),
                SectionCard(
                  title: context.tr('store'),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(store.name)),
                      Text(
                        store.currency,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SectionCard(
                title: context.tr('orderItems'),
                trailing: TextButton.icon(
                  onPressed: options.hasValue ? _addLine : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.tr('add')),
                ),
                child: _lines.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          context.tr('orderItemsRequired'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < _lines.length; i++)
                            _LineRow(
                              line: _lines[i],
                              currency: store?.currency ?? 'USD',
                              onQuantityChanged: (value) => setState(
                                () => _lines[i].quantity = value,
                              ),
                              onRemove: () =>
                                  setState(() => _lines.removeAt(i)),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: context.tr('notes'),
                child: AppTextField(
                  controller: _notes,
                  label: context.tr('note'),
                  helper: context.tr('optional'),
                  maxLines: 3,
                  minLines: 2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('subtotal'),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    Formatters.currency(
                      _estimatedTotal,
                      store?.currency ?? 'USD',
                    ),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('priceRequired'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('createOrder'),
                loading: _submitting,
                expand: true,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomer() async {
    final customers = await ref.read(customerOptionsProvider.future);
    if (!mounted) return;
    final picked = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _CustomerPicker(customers: customers),
    );
    if (picked != null) setState(() => _customer = picked);
  }

  Future<void> _addLine() async {
    final options = await ref.read(productOptionsProvider.future);
    if (!mounted) return;
    final picked = await showModalBottomSheet<ProductOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ProductPicker(options: options),
    );
    if (picked == null || !mounted) return;

    final existing = _lines.indexWhere(
      (line) => line.option.variant.id == picked.variant.id,
    );
    setState(() {
      if (existing >= 0) {
        _lines[existing].quantity++;
      } else {
        _lines.add(_OrderLineDraft(option: picked));
      }
    });
  }

  Future<void> _submit() async {
    if (_lines.isEmpty) {
      AppSnack.show(context, context.tr('orderItemsRequired'), isError: true);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final store = ref.read(defaultStoreProvider);
    if (store == null) {
      AppSnack.show(context, context.tr('noStore'), isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final draft = OrderDraft(
      storeId: store.id,
      customerId: _customer?.id,
      customerName: _customer == null && _walkInName.text.trim().isNotEmpty
          ? _walkInName.text.trim()
          : null,
      customerPhone: _customer == null && _walkInPhone.text.trim().isNotEmpty
          ? _walkInPhone.text.trim()
          : null,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      items: [
        for (final line in _lines)
          OrderItemDraft(
            productId: line.option.product.id,
            productVariantId: line.option.variant.id,
            quantity: line.quantity,
          ),
      ],
    );

    try {
      final order = await ref.read(orderActionsProvider).create(draft);
      if (!mounted) return;
      AppSnack.show(context, context.tr('orderCreated'));
      context.pushReplacement(RoutePaths.order(order.orderNumber));
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.currency,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final _OrderLineDraft line;
  final String currency;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.option.label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  Formatters.currency(line.option.variant.price, currency),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('remove'),
            visualDensity: VisualDensity.compact,
            onPressed: line.quantity > 1
                ? () => onQuantityChanged(line.quantity - 1)
                : null,
            icon: const Icon(Icons.remove_circle_outline, size: 20),
          ),
          Text(
            '${line.quantity}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          IconButton(
            tooltip: context.tr('add'),
            visualDensity: VisualDensity.compact,
            onPressed: line.quantity < 10000
                ? () => onQuantityChanged(line.quantity + 1)
                : null,
            icon: const Icon(Icons.add_circle_outline, size: 20),
          ),
          IconButton(
            tooltip: context.tr('delete'),
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      ),
    );
  }
}

class _CustomerPicker extends StatefulWidget {
  const _CustomerPicker({required this.customers});

  final List<Customer> customers;

  @override
  State<_CustomerPicker> createState() => _CustomerPickerState();
}

class _CustomerPickerState extends State<_CustomerPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(_query.toLowerCase()) ||
              (customer.phone ?? '').contains(_query),
        )
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: AppTextField(
                label: context.tr('searchCustomers'),
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(context.tr('noCustomers')))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        return ListTile(
                          leading: AppAvatar(name: customer.name, size: 40),
                          title: Text(customer.name),
                          subtitle:
                              Text(customer.phone ?? customer.email ?? '—'),
                          onTap: () => Navigator.of(context).pop(customer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPicker extends StatefulWidget {
  const _ProductPicker({required this.options});

  final List<ProductOption> options;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where(
          (option) =>
              option.product.name
                  .toLowerCase()
                  .contains(_query.toLowerCase()) ||
              option.variant.name
                  .toLowerCase()
                  .contains(_query.toLowerCase()) ||
              (option.variant.sku ?? '')
                  .toLowerCase()
                  .contains(_query.toLowerCase()),
        )
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: AppTextField(
                label: context.tr('searchProducts'),
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(context.tr('noProducts')))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        return ListTile(
                          title: Text(option.label),
                          subtitle: Text(
                            [
                              if (option.variant.sku != null)
                                option.variant.sku!,
                              context.tr('available'),
                              '${option.variant.stock.available}',
                            ].join(' · '),
                          ),
                          trailing: Text(
                            Formatters.currency(
                              option.variant.price,
                              option.product.currency,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
