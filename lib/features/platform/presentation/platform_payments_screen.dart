import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/resources/collection_screen.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';

/// Platform payment catalogue administration.
///
/// Markets, providers, methods and signed webhook evidence. Every list is a
/// server-owned catalogue; the only write offered inline is the active flag the
/// API explicitly accepts, and it is hidden without the manage grant.
class PlatformPaymentsScreen extends ConsumerWidget {
  const PlatformPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canViewPlatformPayments) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('paymentCatalogue'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final canManage = permissions.canManagePlatformPayments;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('paymentCatalogue')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: context.tr('countries')),
              Tab(text: context.tr('providers')),
              Tab(text: context.tr('paymentMethods')),
              Tab(text: context.tr('webhookEvents')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CollectionScreen(
              embedded: true,
              titleKey: 'countries',
              path: ApiPaths.platformPaymentCountries,
              itemsKey: 'countries',
              icon: Icons.public_outlined,
              emptyTitleKey: 'noCountries',
              title: (resource) =>
                  resource.text('name', fallback: resource.text('code')),
              subtitle: (resource) => [
                resource.text('code'),
                resource.text('currency'),
              ].where((part) => part.isNotEmpty).join(' · '),
              status: (resource) =>
                  resource.flag('is_active') ? 'active' : 'inactive',
              fields: const [
                CollectionFieldSpec(key: 'code', labelKey: 'countryCode'),
                CollectionFieldSpec(key: 'name', labelKey: 'name'),
                CollectionFieldSpec(key: 'name_ar', labelKey: 'nameAr'),
                CollectionFieldSpec(key: 'currency', labelKey: 'currency'),
                CollectionFieldSpec(
                  key: 'is_active',
                  labelKey: 'active',
                  type: CollectionFieldType.boolean,
                ),
                CollectionFieldSpec(
                  key: 'sort_order',
                  labelKey: 'sortOrder',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'coverage',
                  labelKey: 'providerCoverage',
                  type: CollectionFieldType.json,
                ),
              ],
              actions: [
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'toggleCountry',
                    method: 'PATCH',
                    path: (resource) =>
                        ApiPaths.platformPaymentCountry(resource.text('code')),
                    body: (resource) => {
                      'is_active': !resource.flag('is_active'),
                    },
                    confirmKey: 'toggleCountryMessage',
                    icon: Icons.toggle_on_outlined,
                  ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'providers',
              path: ApiPaths.platformPaymentProviders,
              itemsKey: 'providers',
              icon: Icons.account_balance_outlined,
              emptyTitleKey: 'noProviders',
              title: (resource) => resource.text('name', fallback: '—'),
              subtitle: (resource) => [
                resource.text('code'),
                resource.text('status_label', fallback: resource.text('status')),
              ].where((part) => part.isNotEmpty).join(' · '),
              status: (resource) => resource.text('status'),
              fields: const [
                CollectionFieldSpec(key: 'code', labelKey: 'providerCode'),
                CollectionFieldSpec(key: 'name', labelKey: 'name'),
                CollectionFieldSpec(key: 'status', labelKey: 'status'),
                CollectionFieldSpec(
                  key: 'integration_enabled',
                  labelKey: 'integrationEnabled',
                  type: CollectionFieldType.boolean,
                ),
                CollectionFieldSpec(key: 'adapter', labelKey: 'adapter'),
                CollectionFieldSpec(key: 'capabilities', labelKey: 'capabilities', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'countries', labelKey: 'countries', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'methods', labelKey: 'paymentMethods', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'docs_url', labelKey: 'docsUrl'),
                CollectionFieldSpec(key: 'webhook_docs_url', labelKey: 'webhookDocsUrl'),
                CollectionFieldSpec(key: 'notes', labelKey: 'notes'),
                CollectionFieldSpec(
                  key: 'last_verified_at',
                  labelKey: 'lastVerified',
                  type: CollectionFieldType.date,
                ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'paymentMethods',
              path: ApiPaths.platformPaymentMethods,
              itemsKey: 'methods',
              icon: Icons.payments_outlined,
              emptyTitleKey: 'noPaymentMethods',
              title: (resource) => resource.text('name', fallback: '—'),
              subtitle: (resource) => [
                resource.text('code'),
                resource.text('kind'),
              ].where((part) => part.isNotEmpty).join(' · '),
              status: (resource) =>
                  resource.flag('is_active') ? 'active' : 'inactive',
              fields: const [
                CollectionFieldSpec(key: 'code', labelKey: 'methodCode'),
                CollectionFieldSpec(key: 'name', labelKey: 'name'),
                CollectionFieldSpec(key: 'name_ar', labelKey: 'nameAr'),
                CollectionFieldSpec(key: 'description', labelKey: 'description'),
                CollectionFieldSpec(key: 'description_ar', labelKey: 'descriptionAr'),
                CollectionFieldSpec(key: 'kind', labelKey: 'kind'),
                CollectionFieldSpec(
                  key: 'is_active',
                  labelKey: 'active',
                  type: CollectionFieldType.boolean,
                ),
                CollectionFieldSpec(
                  key: 'sort_order',
                  labelKey: 'sortOrder',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'provider_count',
                  labelKey: 'providerCount',
                  type: CollectionFieldType.integer,
                ),
              ],
              actions: [
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'toggleMethod',
                    method: 'PATCH',
                    path: (resource) =>
                        ApiPaths.platformPaymentMethod(resource.id),
                    body: (resource) => {
                      'is_active': !resource.flag('is_active'),
                    },
                    confirmKey: 'toggleMethodMessage',
                    icon: Icons.toggle_on_outlined,
                  ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'webhookEvents',
              path: ApiPaths.platformPaymentWebhookEvents,
              itemsKey: 'events',
              icon: Icons.webhook_outlined,
              emptyTitleKey: 'noWebhookEvents',
              title: (resource) => resource.text('event_type', fallback: '—'),
              subtitle: (resource) {
                final provider = resource.map('provider');
                final name = provider?['name'] ?? provider?['code'] ?? '';
                return [
                  provider == null ? null : '$name',
                  resource.text('event_id'),
                ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
              },
              status: (resource) => resource.text('status'),
              fields: const [
                CollectionFieldSpec(key: 'event_type', labelKey: 'eventType'),
                CollectionFieldSpec(key: 'event_id', labelKey: 'eventId'),
                CollectionFieldSpec(key: 'status', labelKey: 'status'),
                CollectionFieldSpec(
                  key: 'signature_valid',
                  labelKey: 'signatureValid',
                  type: CollectionFieldType.boolean,
                ),
                CollectionFieldSpec(
                  key: 'payment_id',
                  labelKey: 'payment',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'tenant_id',
                  labelKey: 'tenant',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'store_id',
                  labelKey: 'store',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(key: 'failure_reason', labelKey: 'failureReason'),
                CollectionFieldSpec(key: 'payload', labelKey: 'payload', type: CollectionFieldType.json),
                CollectionFieldSpec(
                  key: 'processed_at',
                  labelKey: 'processedAt',
                  type: CollectionFieldType.date,
                ),
                CollectionFieldSpec(
                  key: 'created_at',
                  labelKey: 'createdAt',
                  type: CollectionFieldType.date,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
