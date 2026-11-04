import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';
import '../../stores/presentation/store_selector_field.dart';
import '../application/payment_controller.dart';
import '../domain/payment_domain.dart';

/// The payment methods a store can honestly offer today.
///
/// Cash on delivery is configurable. Online payment is displayed with the
/// server's own reason for being unavailable; the app never implies that a card
/// can be charged while no provider is configured.
class PaymentSettingsScreen extends ConsumerStatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  ConsumerState<PaymentSettingsScreen> createState() =>
      _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends ConsumerState<PaymentSettingsScreen> {
  int? _storeId;

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storeOptionsProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('paymentSettings')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              final stores = storesAsync.valueOrNull ?? const <Store>[];
              final id = _resolveStoreId(stores);
              if (id != null) ref.invalidate(paymentSettingsProvider(id));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
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
          final settingsAsync = ref.watch(paymentSettingsProvider(storeId));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              StoreSelectorField(
                stores: stores,
                selectedId: storeId,
                onChanged: (value) => setState(() => _storeId = value),
              ),
              const SizedBox(height: 12),
              settingsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: LoadingView(),
                ),
                error: (error, stack) => ErrorView(
                  message: error.toString(),
                  onRetry: () =>
                      ref.invalidate(paymentSettingsProvider(storeId)),
                ),
                data: (settings) => _PaymentForm(
                  key: ValueKey(storeId),
                  storeId: storeId,
                  settings: settings,
                  canManage: permissions.canManagePayments,
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
}

class _PaymentForm extends ConsumerStatefulWidget {
  const _PaymentForm({
    super.key,
    required this.storeId,
    required this.settings,
    required this.canManage,
  });

  final int storeId;
  final PaymentSettings settings;
  final bool canManage;

  @override
  ConsumerState<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends ConsumerState<_PaymentForm> {
  late bool _codEnabled = widget.settings.codEnabled;
  late final _instructions =
      TextEditingController(text: widget.settings.codInstructions ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: context.tr('paymentMethods'),
          subtitle: context.tr('paymentsIntro'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.settings.methods.isEmpty)
                Text(context.tr('noPaymentMethods'))
              else
                for (final method in widget.settings.methods)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MethodTile(method: method),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: context.tr('cashOnDelivery'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('codEnabled')),
                subtitle: Text(context.tr('codEnabledHint')),
                value: _codEnabled,
                onChanged: widget.canManage
                    ? (value) => setState(() => _codEnabled = value)
                    : null,
              ),
              const SizedBox(height: 4),
              AppTextField(
                controller: _instructions,
                label: context.tr('codInstructions'),
                helper: context.tr('codInstructionsHint'),
                enabled: widget.canManage,
                maxLines: 4,
                minLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('onlinePaymentsNote'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (widget.canManage) ...[
          const SizedBox(height: 16),
          AppButton(
            label: context.tr('saveChanges'),
            expand: true,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(paymentActionsProvider).update(
            widget.storeId,
            PaymentSettingsDraft(
              codEnabled: _codEnabled,
              codInstructions: _instructions.text,
            ),
          );
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, context.tr('paymentSettingsUpdated'));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method});

  final PaymentMethodOption method;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = method.code == 'online'
        ? Icons.credit_card_outlined
        : Icons.payments_outlined;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        method.label,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusChip(
                      status: method.available ? 'active' : 'inactive',
                      label: context.tr(
                        method.available ? 'available' : 'unavailable',
                      ),
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  method.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!method.available &&
                    method.unavailableReason != null &&
                    method.unavailableReason!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    method.unavailableReason!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
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
