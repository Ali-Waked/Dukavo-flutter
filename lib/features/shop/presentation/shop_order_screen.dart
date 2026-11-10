import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/shop_providers.dart';
import '../domain/shop_models.dart';
import 'shop_shell.dart';

/// A customer-safe order view, authorised by the tracking token in the URL.
///
/// The token is the secret the API issues on checkout. Nothing here can read an
/// order without it, and no internal id, cost or merchant note is exposed.
///
/// A payment is never confirmed by returning from the provider page. While the
/// latest attempt is pending the screen re-reads the order every 15 seconds,
/// and only the server's signed confirmation can move it to paid.
class ShopOrderScreen extends ConsumerStatefulWidget {
  const ShopOrderScreen({
    super.key,
    required this.shop,
    required this.token,
  });

  final ShopRef shop;
  final String token;

  @override
  ConsumerState<ShopOrderScreen> createState() => _ShopOrderScreenState();
}

class _ShopOrderScreenState extends ConsumerState<ShopOrderScreen>
    with WidgetsBindingObserver {
  Timer? _poll;
  bool _retrying = false;
  String? _actionError;

  ShopOrderRef get _refKey =>
      ShopOrderRef(widget.shop.tenant, widget.shop.store, widget.token);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => _pollPending());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    super.dispose();
  }

  /// Coming back from the provider is not proof of payment, but it is a good
  /// moment to ask the server what the webhook has recorded so far.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollPending();
    }
  }

  void _pollPending() {
    final order = ref.read(shopOrderProvider(_refKey)).valueOrNull;

    if (order?.payment?.isPending == true) {
      ref.invalidate(shopOrderProvider(_refKey));
    }
  }

  Future<void> _retry() async {
    if (_retrying) return;

    final order = ref.read(shopOrderProvider(_refKey)).valueOrNull;

    setState(() {
      _retrying = true;
      _actionError = null;
    });

    try {
      await ref.read(shopRepositoryProvider).retryPayment(
            widget.shop.tenant,
            widget.shop.store,
            widget.token,
            methodCode: order?.payment?.methodCode,
          );
      ref.invalidate(shopOrderProvider(_refKey));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _actionError =
            error is ApiException ? error.message : context.tr('errorGeneric');
      });
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('paymentLinkCopied'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(shopOrderProvider(_refKey));
    final methods = ref.watch(shopPaymentsProvider(widget.shop)).valueOrNull;

    String? bankInstructions;
    for (final method in methods ?? const <ShopPaymentMethod>[]) {
      if (method.code == 'bank_transfer') {
        bankInstructions = method.instructions;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('orderTracking')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(shopOrderProvider(_refKey)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: order.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: shopErrorMessage(context, error),
          onRetry: () => ref.invalidate(shopOrderProvider(_refKey)),
        ),
        data: (value) => _OrderBody(
          shop: widget.shop,
          order: value,
          bankInstructions: bankInstructions,
          retrying: _retrying,
          actionError: _actionError,
          onRetry: _retry,
          onCopyLink: _copyLink,
        ),
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({
    required this.shop,
    required this.order,
    required this.bankInstructions,
    required this.retrying,
    required this.actionError,
    required this.onRetry,
    required this.onCopyLink,
  });

  final ShopRef shop;
  final ShopOrder order;
  final String? bankInstructions;
  final bool retrying;
  final String? actionError;
  final Future<void> Function() onRetry;
  final Future<void> Function(String url) onCopyLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payment = order.payment;
    final isBankTransfer = order.paymentMethod == 'bank_transfer';
    final isCod = order.paymentMethod == 'cod';
    final isPaid = order.paymentStatus == 'paid';

    return ListView(
      padding: AppSpacing.page,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                context.dukavo.heroStart,
                context.dukavo.heroEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: context.dukavo.shadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr(
                        isPaid
                            ? 'orderConfirmed'
                            : payment?.isPending == true
                                ? 'orderAwaitingPayment'
                                : 'orderConfirmed',
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                order.orderNumber,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusChip(
                    status: order.status,
                    label: order.statusLabel.isEmpty
                        ? order.status
                        : order.statusLabel,
                  ),
                  StatusChip(
                    status: order.paymentStatus,
                    label: order.paymentStatusLabel.isEmpty
                        ? order.paymentStatus
                        : order.paymentStatusLabel,
                  ),
                ],
              ),
              if (order.placedAt != null) ...[
                const SizedBox(height: 10),
                Text(
                  Formatters.dateTime(order.placedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          title: context.tr('items'),
          child: Column(
            children: [
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              [
                                if (item.sku != null && item.sku!.isNotEmpty)
                                  item.sku!,
                                '× ${item.quantity}',
                              ].join(' · '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: context.dukavo.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.currency(item.lineTotal, order.currency),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          title: context.tr('orderSummary'),
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
                      '-${Formatters.currency(order.discountTotal, order.currency)}',
                  valueColor: context.dukavo.success,
                ),
              if (order.taxTotal > 0)
                KeyValueRow(
                  label: context.tr('tax'),
                  value: Formatters.currency(order.taxTotal, order.currency),
                ),
              KeyValueRow(
                label: context.tr('delivery'),
                value: Formatters.currency(order.shippingTotal, order.currency),
              ),
              const Divider(height: 20),
              KeyValueRow(
                label: context.tr('total'),
                value: Formatters.currency(order.grandTotal, order.currency),
              ),
              if (order.paymentMethodLabel != null)
                KeyValueRow(
                  label: context.tr('paymentMethod'),
                  value: order.paymentMethodLabel!,
                ),
            ],
          ),
        ),
        if (payment != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            title: context.tr('paymentStatus'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (payment.providerName != null)
                  KeyValueRow(
                    label: context.tr('paymentProvider'),
                    value: payment.providerName!,
                  ),
                if (payment.methodCode != null)
                  KeyValueRow(
                    label: context.tr('paymentRail'),
                    value: payment.methodCode!,
                  ),
                KeyValueRow(
                  label: context.tr('paymentAttempt'),
                  value: '${payment.attemptNumber}',
                ),
                KeyValueRow(
                  label: context.tr('paymentAmount'),
                  value: Formatters.currency(
                    payment.amount,
                    payment.currency.isEmpty
                        ? order.currency
                        : payment.currency,
                  ),
                ),
                if (payment.reference != null)
                  KeyValueRow(
                    label: context.tr('paymentReference'),
                    value: payment.reference!,
                  ),
                if (payment.failureReason != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    payment.failureReason!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.dukavo.danger,
                    ),
                  ),
                ],
                if (payment.isPaid) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr('paymentPaidNote'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.dukavo.success,
                    ),
                  ),
                ] else if (payment.isPending) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr('paymentPendingNote'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.dukavo.textMuted,
                    ),
                  ),
                ],
                if (!payment.isPaid &&
                    payment.checkoutUrl != null &&
                    payment.checkoutUrl!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.tr('paymentLinkHint'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.dukavo.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.dukavo.surfaceLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: SelectableText(
                      payment.checkoutUrl!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: context.tr('copyPaymentLink'),
                    icon: Icons.copy_rounded,
                    expand: true,
                    onPressed: () => onCopyLink(payment.checkoutUrl!),
                  ),
                ],
                if (payment.retryAllowed && !payment.isPaid) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: context.tr('retryPayment'),
                    icon: Icons.refresh_rounded,
                    expand: true,
                    variant: AppButtonVariant.outlined,
                    loading: retrying,
                    onPressed: retrying ? null : onRetry,
                  ),
                ],
                if (actionError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ErrorView(message: actionError!, onRetry: onRetry),
                ],
              ],
            ),
          ),
        ],
        if (isBankTransfer) ...[
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            title: context.tr('bankTransfer'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('bankTransferNote'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.dukavo.textMuted,
                  ),
                ),
                if (bankInstructions != null &&
                    bankInstructions!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.dukavo.surfaceLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      bankInstructions!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (isCod && !isPaid) ...[
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Text(
              context.tr('codNote'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.dukavo.textMuted,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        SectionCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.bookmark_outline_rounded,
                size: 18,
                color: context.dukavo.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('saveTrackingLink'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: context.tr('continueShopping'),
          icon: Icons.storefront_outlined,
          expand: true,
          onPressed: () =>
              context.go(RoutePaths.shopStore(shop.tenant, shop.store)),
        ),
      ],
    );
  }
}
