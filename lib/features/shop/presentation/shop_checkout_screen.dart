import 'dart:math';

import 'package:flutter/material.dart';
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

/// Public checkout.
///
/// The form sends what to buy, where to deliver and how to pay. It never sends
/// a price, a fee or a total: the API re-prices the cart, quotes delivery from
/// the store's own zones and returns the authoritative order.
class ShopCheckoutScreen extends ConsumerStatefulWidget {
  const ShopCheckoutScreen({super.key, required this.shop});

  final ShopRef shop;

  @override
  ConsumerState<ShopCheckoutScreen> createState() => _ShopCheckoutScreenState();
}

class _ShopCheckoutScreenState extends ConsumerState<ShopCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _lineOne = TextEditingController();
  final _lineTwo = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postalCode = TextEditingController();
  final _country = TextEditingController(text: 'SA');
  final _area = TextEditingController();
  final _notes = TextEditingController();

  late final String _idempotencyKey = _newKey();
  String? _paymentCode;
  String? _zoneCity;
  String? _error;
  bool _sending = false;

  static String _newKey() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return values
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _lineOne.dispose();
    _lineTwo.dispose();
    _city.dispose();
    _state.dispose();
    _postalCode.dispose();
    _country.dispose();
    _area.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider(widget.shop));
    final methods = ref.watch(shopPaymentsProvider(widget.shop));
    final zones = ref.watch(shopShippingProvider(widget.shop));
    final theme = Theme.of(context);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('checkout'))),
        body: EmptyState(
          title: context.tr('cartEmpty'),
          message: context.tr('cartEmptyHint'),
          icon: Icons.shopping_bag_outlined,
          actionLabel: context.tr('continueShopping'),
          onAction: () => context.go(
            RoutePaths.shopStore(widget.shop.tenant, widget.shop.store),
          ),
        ),
      );
    }

    final currency = cart.first.currency;
    final subtotal = cart.fold<num>(0, (total, line) => total + line.lineTotal);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('checkout'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            SectionCard(
              title: context.tr('contactDetails'),
              child: Column(
                children: [
                  AppTextField(
                    controller: _name,
                    label: context.tr('fullName'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) => _required(context, value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _phone,
                    label: context.tr('phone'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: (value) => _required(context, value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _email,
                    label: context.tr('email'),
                    helper: context.tr('optional'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return null;
                      return _emailError(context, value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SectionCard(
              title: context.tr('deliveryAddress'),
              child: Column(
                children: [
                  zones.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: LinearProgressIndicator(),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        shopErrorMessage(context, error),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.dukavo.danger,
                        ),
                      ),
                    ),
                    data: (items) => _ZoneFields(
                      zones: items,
                      city: _city,
                      area: _area,
                      selectedCity: _zoneCity,
                      onCityChanged: (value) =>
                          setState(() => _zoneCity = value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _lineOne,
                    label: context.tr('addressLineOne'),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    autofillHints: const [AutofillHints.streetAddressLine1],
                    validator: (value) => _required(context, value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _lineTwo,
                    label: context.tr('addressLineTwo'),
                    helper: context.tr('optional'),
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.streetAddressLine2],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _state,
                          label: context.tr('state'),
                          helper: context.tr('optional'),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _postalCode,
                          label: context.tr('postalCode'),
                          helper: context.tr('optional'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _country,
                    label: context.tr('countryCode'),
                    helper: context.tr('countryCodeHint'),
                    textCapitalization: TextCapitalization.characters,
                    maxLines: 1,
                    validator: (value) => _countryError(context, value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _notes,
                    label: context.tr('orderNotes'),
                    helper: context.tr('optional'),
                    maxLines: 3,
                    minLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SectionCard(
              title: context.tr('paymentMethod'),
              child: methods.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                ),
                error: (error, stack) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        shopErrorMessage(context, error),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('retry'),
                      onPressed: () =>
                          ref.invalidate(shopPaymentsProvider(widget.shop)),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      context.tr('noPaymentMethods'),
                      style: theme.textTheme.bodySmall,
                    );
                  }
                  final available =
                      items.where((item) => item.available).toList();
                  final selected = _paymentCode ??
                      (available.isEmpty ? null : available.first.code);
                  return RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentCode = value);
                      }
                    },
                    child: Column(
                      children: [
                        for (final method in items)
                          _PaymentTile(
                            method: method,
                            enabled: method.available,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SectionCard(
              title: context.tr('orderSummary'),
              child: Column(
                children: [
                  for (final line in cart)
                    KeyValueRow(
                      label: '${line.productName} × ${line.quantity}',
                      value: Formatters.currency(line.lineTotal, line.currency),
                    ),
                  const Divider(height: 20),
                  KeyValueRow(
                    label: context.tr('subtotal'),
                    value: Formatters.currency(subtotal, currency),
                  ),
                  KeyValueRow(
                    label: context.tr('delivery'),
                    value: context.tr('calculatedByStore'),
                  ),
                  const Divider(height: 20),
                  KeyValueRow(
                    label: context.tr('total'),
                    value: Formatters.currency(subtotal, currency),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: context.dukavo.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.tr('finalTotalOnConfirmation'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: context.dukavo.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ErrorView(message: _error!, onRetry: _submit),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.tr('placeOrder'),
              icon: Icons.check_circle_outline,
              expand: true,
              loading: _sending,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      setState(() {
        _error =
            _city.text.trim().isEmpty ? context.tr('chooseDeliveryCity') : null;
      });
      return;
    }
    final cart = ref.read(cartProvider(widget.shop));
    if (cart.isEmpty) return;
    final method = _paymentCode ??
        ref
            .read(shopPaymentsProvider(widget.shop))
            .valueOrNull
            ?.where((item) => item.available)
            .firstOrNull
            ?.code;
    if (method == null) {
      setState(() => _error = context.tr('noPaymentMethods'));
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final order = await ref.read(shopRepositoryProvider).checkout(
        widget.shop.tenant,
        widget.shop.store,
        {
          'customer_name': _name.text.trim(),
          'customer_phone': _phone.text.trim(),
          if (_email.text.trim().isNotEmpty)
            'customer_email': _email.text.trim(),
          if (_area.text.trim().isNotEmpty) 'area': _area.text.trim(),
          if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
          'payment_method': method,
          'idempotency_key': _idempotencyKey,
          'shipping_address': {
            'contact_name': _name.text.trim(),
            'line_one': _lineOne.text.trim(),
            if (_lineTwo.text.trim().isNotEmpty)
              'line_two': _lineTwo.text.trim(),
            'city': _city.text.trim(),
            if (_state.text.trim().isNotEmpty) 'state': _state.text.trim(),
            if (_postalCode.text.trim().isNotEmpty)
              'postal_code': _postalCode.text.trim(),
            'country': _country.text.trim().toUpperCase(),
          },
          'items': [
            for (final line in cart)
              {
                'product_variant_id': line.variantId,
                'quantity': line.quantity,
              },
          ],
        },
      );
      ref.read(cartProvider(widget.shop).notifier).clear();
      if (!mounted) return;
      final token = order.trackingToken;
      if (token != null && token.isNotEmpty) {
        context.go(
          RoutePaths.shopOrder(widget.shop.tenant, widget.shop.store, token),
        );
      } else {
        setState(() {
          _sending = false;
          _error = context.tr('orderPlacedNoTracking');
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error =
            error is ApiException ? error.message : context.tr('errorGeneric');
      });
    }
  }
}

class _ZoneFields extends StatelessWidget {
  const _ZoneFields({
    required this.zones,
    required this.city,
    required this.area,
    required this.selectedCity,
    required this.onCityChanged,
  });

  final List<ShopShippingZone> zones;
  final TextEditingController city;
  final TextEditingController area;
  final String? selectedCity;
  final ValueChanged<String?> onCityChanged;

  @override
  Widget build(BuildContext context) {
    final cities = <String>{};
    for (final zone in zones) {
      final value = zone.city;
      if (value != null && value.isNotEmpty) cities.add(value);
    }

    if (cities.isEmpty) {
      return AppTextField(
        controller: city,
        label: context.tr('city'),
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.addressCity],
        validator: (value) => _required(context, value),
      );
    }

    final selected = selectedCity != null && cities.contains(selectedCity)
        ? selectedCity
        : null;
    final cityZones =
        zones.where((item) => item.city == selected).toList(growable: false);
    final zone = cityZones.firstOrNull;
    final areas = zone?.areas ?? const <String>[];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(labelText: context.tr('city')),
          items: [
            for (final value in cities)
              DropdownMenuItem(value: value, child: Text(value)),
          ],
          onChanged: (value) {
            onCityChanged(value);
            city.text = value ?? '';
            area.clear();
          },
          validator: (value) => value == null || value.isEmpty
              ? context.tr('requiredField')
              : null,
        ),
        if (areas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: areas.contains(area.text) ? area.text : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.tr('area'),
              helperText: context.tr('areaHint'),
            ),
            items: [
              for (final value in areas)
                DropdownMenuItem(value: value, child: Text(value)),
            ],
            onChanged: (value) => area.text = value ?? '',
            validator: (value) => value == null || value.isEmpty
                ? context.tr('requiredField')
                : null,
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: area,
            label: context.tr('area'),
            helper: context.tr('optional'),
            textInputAction: TextInputAction.next,
          ),
        ],
        if (selected != null && cityZones.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: area,
              builder: (context, value, _) {
                final needle = value.text.trim().toLowerCase();
                final matched = cityZones.firstWhere(
                  (item) =>
                      item.areas.isEmpty ||
                      item.areas.any(
                        (candidate) => candidate.trim().toLowerCase() == needle,
                      ),
                  orElse: () => cityZones.first,
                );
                return _ShippingCopy(zone: matched);
              },
            ),
          ),
      ],
    );
  }
}

/// Customer-facing copy for the selected delivery option.
///
/// The API resolves this to one language; the widget never sees a raw
/// translations document. Arabic copy is laid out right-to-left even if the
/// surrounding interface is English.
class _ShippingCopy extends StatelessWidget {
  const _ShippingCopy({required this.zone});

  final ShopShippingZone zone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction =
        zone.locale == 'ar' ? TextDirection.rtl : Directionality.of(context);
    final items = <(String, String?)>[
      (context.tr('shippingMethodName'), zone.methodName),
      (context.tr('shippingMethodDescription'), zone.methodDescription),
      (context.tr('deliveryInstructions'), zone.deliveryInstructions),
      (context.tr('shippingTerms'), zone.terms),
    ].where((item) => item.$2 != null && item.$2!.trim().isNotEmpty).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: direction,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.dukavo.surfaceLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in items) ...[
              Text(
                item.$1,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: context.dukavo.textMuted,
                ),
              ),
              Text(item.$2!, style: theme.textTheme.bodySmall),
              if (item != items.last) const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.enabled,
  });

  final ShopPaymentMethod method;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RadioListTile<String>(
      value: method.code,
      enabled: enabled,
      contentPadding: EdgeInsets.zero,
      title: Text(method.label),
      subtitle: Text(
        enabled
            ? method.description
            : (method.unavailableReason ?? method.description),
        style: theme.textTheme.bodySmall?.copyWith(
          color: enabled ? context.dukavo.textMuted : context.dukavo.danger,
        ),
      ),
    );
  }
}

String? _required(BuildContext context, String? value) {
  if (value == null || value.trim().isEmpty) return context.tr('requiredField');
  return null;
}

String? _emailError(BuildContext context, String? value) {
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(value!.trim())) return context.tr('invalidEmail');
  return null;
}

String? _countryError(BuildContext context, String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return context.tr('requiredField');
  if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(text)) {
    return context.tr('countryCodeHint');
  }
  return null;
}
