import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/presentation/store_selector_field.dart';

/// Merchant payment connections and attempt history.
///
/// Connections are per store: credentials enter once, are verified by the
/// provider and never come back. Refunds are bounded by the server; the mobile
/// form only collects the amount the API explicitly accepts.
class MerchantPaymentsScreen extends ConsumerStatefulWidget {
  const MerchantPaymentsScreen({super.key});

  @override
  ConsumerState<MerchantPaymentsScreen> createState() =>
      _MerchantPaymentsScreenState();
}

class _MerchantPaymentsScreenState
    extends ConsumerState<MerchantPaymentsScreen> {
  int? _storeId;

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canViewPayments) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('payments'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final stores = ref.watch(storeOptionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('payments'))),
      body: stores.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error is ApiException ? error.message : context.tr('errorGeneric'),
          onRetry: () => ref.invalidate(storeOptionsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.store_outlined,
              title: context.tr('noStores'),
            );
          }
          final selected = _storeId ?? defaultStoreFrom(list)?.id ?? list.first.id;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: StoreSelectorField(
                  stores: list,
                  selectedId: selected,
                  onChanged: (value) => setState(() => _storeId = value),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: _StorePaymentsBody(
                  key: ValueKey(selected),
                  storeId: selected,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StorePaymentsBody extends StatelessWidget {
  const _StorePaymentsBody({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: context.tr('paymentConnections')),
              Tab(text: context.tr('paymentHistory')),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ConnectionsTab(storeId: storeId),
                _PaymentsTab(storeId: storeId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionsTab extends ConsumerStatefulWidget {
  const _ConnectionsTab({required this.storeId});

  final int storeId;

  @override
  ConsumerState<_ConnectionsTab> createState() => _ConnectionsTabState();
}

class _ConnectionsTabState extends ConsumerState<_ConnectionsTab> {
  List<JsonResource> _connections = const <JsonResource>[];
  List<JsonResource> _providers = const <JsonResource>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(apiClientProvider).get<JsonMap>(
            ApiPaths.storePaymentConnections(widget.storeId),
            decode: (value) =>
                value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
          );
      if (!mounted) return;
      setState(() {
        _connections = _resources(data['connections']);
        _providers = _resources(data['providers']);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException ? error.message : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          ErrorView(message: _error!, onRetry: _load),
        ],
      );
    }
    final canManage = ref.watch(permissionsProvider).canManagePayments;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.page,
        children: [
          if (canManage)
            AppButton(
              label: context.tr('addPaymentConnection'),
              icon: Icons.add,
              expand: true,
              onPressed: _providers.isEmpty ? null : _create,
            ),
          const SizedBox(height: AppSpacing.sm),
          if (_connections.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyState(
                icon: Icons.account_balance_outlined,
                title: context.tr('noPaymentConnections'),
                message: context.tr('noPaymentConnectionsMessage'),
              ),
            )
          else
            for (final connection in _connections)
              _ConnectionCard(
                connection: connection,
                canManage: canManage,
                onVerify: () => _verify(connection),
                onDelete: () => _delete(connection),
              ),
        ],
      ),
    );
  }

  Future<void> _verify(JsonResource connection) async {
    try {
      await ref.read(apiClientProvider).post<dynamic>(
            ApiPaths.storePaymentConnectionVerify(
              widget.storeId,
              connection.id,
            ),
          );
      if (!mounted) return;
      AppSnack.show(context, context.tr('connectionVerified'));
      await _load();
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    }
  }

  Future<void> _delete(JsonResource connection) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('delete'),
      message: context.tr('revokeConnectionMessage'),
      confirmLabel: context.tr('delete'),
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(apiClientProvider).delete(
            ApiPaths.storePaymentConnection(widget.storeId, connection.id),
          );
      if (!mounted) return;
      AppSnack.show(context, context.tr('deleted'));
      await _load();
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    }
  }

  Future<void> _create() async {
    final provider = ValueNotifier<String?>(null);
    final environment = ValueNotifier<String>('sandbox');
    final secret = TextEditingController();
    final publicKey = TextEditingController();
    final webhook = TextEditingController();
    final reference = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final providers = _providers;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('addPaymentConnection')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: provider,
                  builder: (context, value, _) => DropdownButtonFormField<String>(
                    initialValue: value,
                    decoration: InputDecoration(
                      labelText: dialogContext.tr('provider'),
                    ),
                    items: [
                      for (final entry in providers)
                        DropdownMenuItem(
                          value: entry.text('code'),
                          child: Text(entry.text('name', fallback: entry.text('code'))),
                        ),
                    ],
                    validator: (value) => value == null
                        ? dialogContext.tr('requiredField')
                        : null,
                    onChanged: (value) => provider.value = value,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ValueListenableBuilder<String>(
                  valueListenable: environment,
                  builder: (context, value, _) => DropdownButtonFormField<String>(
                    initialValue: value,
                    decoration: InputDecoration(
                      labelText: dialogContext.tr('environment'),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'sandbox',
                        child: Text(dialogContext.tr('sandbox')),
                      ),
                      DropdownMenuItem(
                        value: 'live',
                        child: Text(dialogContext.tr('live')),
                      ),
                    ],
                    onChanged: (value) => environment.value = value ?? 'sandbox',
                  ),
                ),
                TextFormField(
                  controller: secret,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('secretKey'),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? dialogContext.tr('requiredField')
                          : null,
                ),
                TextFormField(
                  controller: publicKey,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('publicKey'),
                  ),
                ),
                TextFormField(
                  controller: webhook,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('webhookSecret'),
                  ),
                ),
                TextFormField(
                  controller: reference,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('merchantReference'),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: Text(dialogContext.tr('save')),
          ),
        ],
      ),
    );
    if (saved == true && provider.value != null) {
      try {
        await ref.read(apiClientProvider).post<dynamic>(
          ApiPaths.storePaymentConnections(widget.storeId),
          body: {
            'provider_code': provider.value,
            'environment': environment.value,
            'credentials': {
              'secret_key': secret.text.trim(),
              if (publicKey.text.trim().isNotEmpty)
                'public_key': publicKey.text.trim(),
            },
            if (webhook.text.trim().isNotEmpty)
              'webhook_secret': webhook.text.trim(),
            if (reference.text.trim().isNotEmpty)
              'merchant_reference': reference.text.trim(),
          },
        );
        if (!mounted) return;
        AppSnack.show(context, context.tr('saved'));
        await _load();
      } catch (error) {
        if (!mounted) return;
        AppSnack.show(
          context,
          error is ApiException ? error.message : context.tr('errorGeneric'),
          isError: true,
        );
      }
    }
    provider.dispose();
    environment.dispose();
    secret.dispose();
    publicKey.dispose();
    webhook.dispose();
    reference.dispose();
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({
    required this.connection,
    required this.canManage,
    required this.onVerify,
    required this.onDelete,
  });

  final JsonResource connection;
  final bool canManage;
  final VoidCallback onVerify;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final provider = connection.map('provider');
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${provider?['name'] ?? provider?['code'] ?? '—'}',
                    style: context.texts.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                StatusChip(
                  status: connection.text('status'),
                  label: connection.text('status_label'),
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            KeyValueRow(
              label: context.tr('environment'),
              value: context.tr(connection.text('environment')),
            ),
            KeyValueRow(
              label: context.tr('credentials'),
              value: connection.flag('has_credentials')
                  ? context.tr('yes')
                  : context.tr('no'),
            ),
            if (connection.text('last_error').isNotEmpty)
              KeyValueRow(
                label: context.tr('error'),
                value: connection.text('last_error'),
              ),
            if (canManage) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.tr('verifyConnection'),
                      variant: AppButtonVariant.tonal,
                      onPressed: onVerify,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    tooltip: context.tr('delete'),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentsTab extends ConsumerStatefulWidget {
  const _PaymentsTab({required this.storeId});

  final int storeId;

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  List<JsonResource> _payments = const <JsonResource>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(apiClientProvider).list<JsonResource>(
            ApiPaths.merchantPayments,
            query: {'store_id': widget.storeId, 'per_page': 50},
            item: JsonResource.fromJson,
          );
      if (!mounted) return;
      setState(() {
        _payments = page.items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException ? error.message : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          ErrorView(message: _error!, onRetry: _load),
        ],
      );
    }
    if (_payments.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: context.tr('noPayments'),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.page,
        children: [
          for (final payment in _payments)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                onTap: () => _open(payment),
                title: Text(
                  Formatters.currency(
                    payment.number('amount') ?? 0,
                    payment.text('currency'),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  [
                    payment.map('provider')?['name']?.toString() ??
                        payment.map('provider')?['code']?.toString() ??
                        '',
                    payment.text('order_number'),
                    payment.text('status_label', fallback: payment.text('status')),
                  ].where((part) => part.isNotEmpty).join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _open(JsonResource payment) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaymentSheet(
        payment: payment,
        onChanged: _load,
      ),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.payment, required this.onChanged});

  final JsonResource payment;
  final Future<void> Function() onChanged;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final provider = payment.map('provider');
    final canManage = ref.watch(permissionsProvider).canManagePayments;
    final canRefund = ref.watch(permissionsProvider).canRefundPayments;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: AppSpacing.page,
        children: [
          Text(
            Formatters.currency(
              payment.number('amount') ?? 0,
              payment.text('currency'),
            ),
            style: context.texts.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          StatusChip(
            status: payment.text('status'),
            label: payment.text('status_label'),
          ),
          const SizedBox(height: AppSpacing.md),
          KeyValueRow(
            label: context.tr('provider'),
            value: '${provider?['name'] ?? provider?['code'] ?? '—'}',
          ),
          KeyValueRow(
            label: context.tr('order'),
            value: payment.text('order_number', fallback: '—'),
          ),
          KeyValueRow(
            label: context.tr('methodCode'),
            value: payment.text('method_code', fallback: '—'),
          ),
          KeyValueRow(
            label: context.tr('reference'),
            value: payment.text('reference', fallback: '—'),
            technical: true,
          ),
          KeyValueRow(
            label: context.tr('failureReason'),
            value: payment.text('failure_reason', fallback: '—'),
          ),
          KeyValueRow(
            label: context.tr('paidAt'),
            value: Formatters.dateTime(payment.optionalText('paid_at')),
          ),
          KeyValueRow(
            label: context.tr('createdAt'),
            value: Formatters.dateTime(payment.optionalText('created_at')),
          ),
          const SizedBox(height: AppSpacing.md),
          if (canManage)
            AppButton(
              label: context.tr('syncPayment'),
              icon: Icons.sync,
              variant: AppButtonVariant.tonal,
              expand: true,
              loading: _working,
              onPressed: _sync,
            ),
          if (canRefund) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: context.tr('refundPayment'),
              icon: Icons.undo,
              variant: AppButtonVariant.outlined,
              expand: true,
              loading: _working,
              onPressed: _refund,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sync() async {
    setState(() => _working = true);
    try {
      await ref.read(apiClientProvider).post<dynamic>(
            ApiPaths.merchantPaymentSync(widget.payment.id),
          );
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
      await widget.onChanged();
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _refund() async {
    final amount = TextEditingController(
      text: '${widget.payment.number('amount') ?? ''}',
    );
    final reason = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('refundPayment')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: dialogContext.tr('refundAmount'),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  return parsed == null || parsed <= 0
                      ? dialogContext.tr('invalidNumber')
                      : null;
                },
              ),
              TextFormField(
                controller: reason,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: dialogContext.tr('refundReason'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: Text(dialogContext.tr('refundPayment')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _working = true);
      try {
        await ref.read(apiClientProvider).post<dynamic>(
          ApiPaths.merchantPaymentRefund(widget.payment.id),
          body: {
            'amount': double.parse(amount.text.trim()),
            if (reason.text.trim().isNotEmpty) 'reason': reason.text.trim(),
          },
        );
        if (!mounted) return;
        AppSnack.show(context, context.tr('refundSubmitted'));
        await widget.onChanged();
      } catch (error) {
        if (!mounted) return;
        AppSnack.show(
          context,
          error is ApiException ? error.message : context.tr('errorGeneric'),
          isError: true,
        );
      } finally {
        if (mounted) setState(() => _working = false);
      }
    }
    amount.dispose();
    reason.dispose();
  }
}

List<JsonResource> _resources(Object? value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((row) => JsonResource(Map<String, dynamic>.from(row)))
        .toList();
  }
  return const <JsonResource>[];
}
