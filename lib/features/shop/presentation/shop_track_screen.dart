import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/shop_providers.dart';

/// Looks up an order from a tracking token or a saved tracking link.
///
/// The API authorises the read with the opaque token alone, so this screen only
/// collects it and navigates to the same order view a checkout confirmation
/// uses. It never accepts an internal order id.
class ShopTrackScreen extends StatefulWidget {
  const ShopTrackScreen({super.key, required this.shop});

  final ShopRef shop;

  @override
  State<ShopTrackScreen> createState() => _ShopTrackScreenState();
}

class _ShopTrackScreenState extends State<ShopTrackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Accepts a bare token or a pasted link such as
  /// `.../shop/acme/store/order/<token>`.
  String _tokenFrom(String raw) {
    final value = raw.trim();
    final marker = value.lastIndexOf('/order/');
    if (marker == -1) return value;
    return value.substring(marker + '/order/'.length).split('?').first;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final token = _tokenFrom(_controller.text);
    if (token.isEmpty) return;
    context
        .go(RoutePaths.shopOrder(widget.shop.tenant, widget.shop.store, token));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 28, 20, 32),
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.scheme.primary.withValues(
                alpha: context.isDark ? 0.18 : 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 36,
              color: context.scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.tr('trackOrder'),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.tr('trackOrderHelp'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.dukavo.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _controller,
                  label: context.tr('trackingToken'),
                  hint: context.tr('trackingTokenHint'),
                  prefixIcon: Icons.key_outlined,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _submit(),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? context.tr('requiredField')
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: context.tr('findOrder'),
                  icon: Icons.search,
                  expand: true,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
