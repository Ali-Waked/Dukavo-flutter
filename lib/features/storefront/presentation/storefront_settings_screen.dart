import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';
import '../../stores/presentation/store_selector_field.dart';
import '../application/storefront_controller.dart';
import '../domain/storefront_domain.dart';

/// Merchant management of the public shopfront.
///
/// The API binds the store through the tenant, so picking a store here can only
/// ever address a store the signed-in merchant belongs to.
class StorefrontSettingsScreen extends ConsumerStatefulWidget {
  const StorefrontSettingsScreen({super.key});

  @override
  ConsumerState<StorefrontSettingsScreen> createState() =>
      _StorefrontSettingsScreenState();
}

class _StorefrontSettingsScreenState
    extends ConsumerState<StorefrontSettingsScreen> {
  int? _storeId;

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storeOptionsProvider);
    final permissions = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('storefrontSettings')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () {
              final stores = storesAsync.valueOrNull ?? const <Store>[];
              final id = _resolveStoreId(stores);
              if (id != null) ref.invalidate(storefrontSettingsProvider(id));
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
          final settingsAsync = ref.watch(storefrontSettingsProvider(storeId));

          return ListView(
            padding: AppSpacing.page,
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
                      ref.invalidate(storefrontSettingsProvider(storeId)),
                ),
                data: (settings) => _StorefrontForm(
                  key: ValueKey(settings.storeId),
                  settings: settings,
                  canManage: permissions.canManageStorefront,
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

class _StorefrontForm extends ConsumerStatefulWidget {
  const _StorefrontForm({
    super.key,
    required this.settings,
    required this.canManage,
  });

  final StorefrontSettings settings;
  final bool canManage;

  @override
  ConsumerState<_StorefrontForm> createState() => _StorefrontFormState();
}

class _StorefrontFormState extends ConsumerState<_StorefrontForm> {
  final _formKey = GlobalKey<FormState>();

  late bool _enabled = widget.settings.storefrontEnabled;
  late bool _showOutOfStock = widget.settings.settings.showOutOfStock;

  late final _description =
      TextEditingController(text: widget.settings.description ?? '');
  late final _logoUrl =
      TextEditingController(text: widget.settings.logoUrl ?? '');
  late final _tagline =
      TextEditingController(text: widget.settings.settings.tagline ?? '');
  late final _about =
      TextEditingController(text: widget.settings.settings.about ?? '');
  late final _heroImageUrl =
      TextEditingController(text: widget.settings.settings.heroImageUrl ?? '');
  late final _contactEmail =
      TextEditingController(text: widget.settings.settings.contactEmail ?? '');
  late final _contactPhone =
      TextEditingController(text: widget.settings.settings.contactPhone ?? '');
  late final _whatsappNumber = TextEditingController(
      text: widget.settings.settings.whatsappNumber ?? '');
  late final _address =
      TextEditingController(text: widget.settings.settings.address ?? '');
  late final _facebook =
      TextEditingController(text: widget.settings.settings.facebook ?? '');
  late final _instagram =
      TextEditingController(text: widget.settings.settings.instagram ?? '');
  late final _tiktok =
      TextEditingController(text: widget.settings.settings.tiktok ?? '');
  late final _openingHours =
      TextEditingController(text: widget.settings.settings.openingHours ?? '');
  late final _deliveryNote =
      TextEditingController(text: widget.settings.settings.deliveryNote ?? '');
  late final _returnPolicy =
      TextEditingController(text: widget.settings.settings.returnPolicy ?? '');
  late final _metaTitle =
      TextEditingController(text: widget.settings.settings.metaTitle ?? '');
  late final _metaDescription = TextEditingController(
      text: widget.settings.settings.metaDescription ?? '');

  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _description,
      _logoUrl,
      _tagline,
      _about,
      _heroImageUrl,
      _contactEmail,
      _contactPhone,
      _whatsappNumber,
      _address,
      _facebook,
      _instagram,
      _tiktok,
      _openingHours,
      _deliveryNote,
      _returnPolicy,
      _metaTitle,
      _metaDescription,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final tenantSlug = ref.watch(currentSessionProvider)?.activeTenant?.slug;
    final shopUrl = tenantSlug == null
        ? null
        : AppConfig.shopUrl(tenantSlug: tenantSlug, storeSlug: settings.slug);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            title: settings.name,
            subtitle: shopUrl ?? '${context.tr('slug')}: ${settings.slug}',
            trailing: StatusChip(status: settings.status),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('storefrontEnabled')),
                  subtitle: Text(
                    _enabled
                        ? context.tr('storefrontEnabledHint')
                        : context.tr('storefrontDisabledHint'),
                  ),
                  value: _enabled,
                  onChanged: widget.canManage
                      ? (value) => setState(() => _enabled = value)
                      : null,
                ),
                if (!_enabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      context.tr('storefrontDisabledWarning'),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                if (shopUrl != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          shopUrl,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: context.tr('copy'),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: shopUrl));
                          if (context.mounted) {
                            AppSnack.show(context, context.tr('copied'));
                          }
                        },
                        icon: const Icon(Icons.copy_all_outlined, size: 18),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('branding'),
            child: Column(
              children: [
                AppTextField(
                  controller: _description,
                  label: context.tr('description'),
                  enabled: widget.canManage,
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _logoUrl,
                  label: context.tr('logoUrl'),
                  hint: 'https://',
                  enabled: widget.canManage,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _tagline,
                  label: context.tr('tagline'),
                  enabled: widget.canManage,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _heroImageUrl,
                  label: context.tr('heroImageUrl'),
                  hint: 'https://',
                  enabled: widget.canManage,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _about,
                  label: context.tr('about'),
                  enabled: widget.canManage,
                  maxLines: 5,
                  minLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('contactDetails'),
            child: Column(
              children: [
                AppTextField(
                  controller: _contactEmail,
                  label: context.tr('contactEmail'),
                  enabled: widget.canManage,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.optionalEmail,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _contactPhone,
                  label: context.tr('phone'),
                  enabled: widget.canManage,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _whatsappNumber,
                  label: context.tr('whatsappNumber'),
                  enabled: widget.canManage,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _address,
                  label: context.tr('address'),
                  enabled: widget.canManage,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _openingHours,
                  label: context.tr('openingHours'),
                  enabled: widget.canManage,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('socialLinks'),
            child: Column(
              children: [
                AppTextField(
                  controller: _facebook,
                  label: 'Facebook',
                  hint: 'https://',
                  enabled: widget.canManage,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _instagram,
                  label: 'Instagram',
                  hint: 'https://',
                  enabled: widget.canManage,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _tiktok,
                  label: 'TikTok',
                  hint: 'https://',
                  enabled: widget.canManage,
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('policies'),
            child: Column(
              children: [
                AppTextField(
                  controller: _deliveryNote,
                  label: context.tr('deliveryNote'),
                  enabled: widget.canManage,
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _returnPolicy,
                  label: context.tr('returnPolicy'),
                  enabled: widget.canManage,
                  maxLines: 5,
                  minLines: 3,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('showOutOfStock')),
                  subtitle: Text(context.tr('showOutOfStockHint')),
                  value: _showOutOfStock,
                  onChanged: widget.canManage
                      ? (value) => setState(() => _showOutOfStock = value)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.tr('searchEngine'),
            subtitle: context.tr('searchEngineHint'),
            child: Column(
              children: [
                AppTextField(
                  controller: _metaTitle,
                  label: context.tr('metaTitle'),
                  enabled: widget.canManage,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _metaDescription,
                  label: context.tr('metaDescription'),
                  enabled: widget.canManage,
                  maxLines: 3,
                  minLines: 2,
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
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(storefrontActionsProvider).update(
            widget.settings.storeId,
            StorefrontDraft(
              storefrontEnabled: _enabled,
              description: _description.text,
              logoUrl: _logoUrl.text,
              settings: StorefrontPresentationSettings(
                tagline: _tagline.text,
                about: _about.text,
                heroImageUrl: _heroImageUrl.text,
                contactEmail: _contactEmail.text,
                contactPhone: _contactPhone.text,
                whatsappNumber: _whatsappNumber.text,
                address: _address.text,
                facebook: _facebook.text,
                instagram: _instagram.text,
                tiktok: _tiktok.text,
                openingHours: _openingHours.text,
                deliveryNote: _deliveryNote.text,
                returnPolicy: _returnPolicy.text,
                showOutOfStock: _showOutOfStock,
                metaTitle: _metaTitle.text,
                metaDescription: _metaDescription.text,
              ),
            ),
          );
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, context.tr('storefrontUpdated'));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}
