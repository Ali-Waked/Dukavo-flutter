import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/collection_screen.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';

/// Platform AI infrastructure administration.
///
/// The overview is a bespoke summary; every list is the same read-first
/// collection surface the rest of the console uses. Credentials stay
/// write-only: the rotate sheet posts a key and the server answers with a
/// masked hint, never the secret.
class PlatformAiAdminScreen extends ConsumerWidget {
  const PlatformAiAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canViewAiAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('aiAdministration'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }

    final canManage = permissions.canManageAiAdmin;
    final canRotate = permissions.canRotateAiCredentials;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('aiAdministration')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: context.tr('overview')),
              Tab(text: context.tr('providers')),
              Tab(text: context.tr('aiTasks')),
              Tab(text: context.tr('aiPrompts')),
              Tab(text: context.tr('activityLog')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _AiOverviewTab(),
            CollectionScreen(
              embedded: true,
              titleKey: 'providers',
              path: ApiPaths.platformAiAdminProviders,
              paginated: true,
              icon: Icons.auto_awesome_outlined,
              emptyTitleKey: 'noProviders',
              title: (resource) =>
                  resource.text('name', fallback: resource.text('key')),
              subtitle: (resource) {
                final configuration = resource.map('configuration');
                final source = configuration?['source'];
                final model = configuration?['model'];
                return [
                  if (source != null) '${context.tr('credentialSource')}: $source',
                  if (model != null) '$model',
                ].join(' · ');
              },
              status: (resource) =>
                  resource.flag('enabled') ? 'active' : 'inactive',
              fields: const [
                CollectionFieldSpec(key: 'key', labelKey: 'providerKey'),
                CollectionFieldSpec(key: 'driver', labelKey: 'driver'),
                CollectionFieldSpec(
                  key: 'enabled',
                  labelKey: 'enabled',
                  type: CollectionFieldType.boolean,
                ),
                CollectionFieldSpec(
                  key: 'priority',
                  labelKey: 'priority',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'models_count',
                  labelKey: 'models',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'routes_count',
                  labelKey: 'routes',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'credentials_count',
                  labelKey: 'credentials',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'configuration',
                  labelKey: 'configuration',
                  type: CollectionFieldType.json,
                ),
                CollectionFieldSpec(key: 'notes', labelKey: 'notes'),
              ],
              actions: [
                if (canRotate)
                  CollectionActionSpec(
                    labelKey: 'aiTestConnection',
                    path: (resource) =>
                        ApiPaths.platformAiAdminProviderTest(resource.id),
                    icon: Icons.network_check,
                  ),
              ],
              extraSheet: (sheetContext, resource) => _AiCredentialsSection(
                provider: resource,
                canRotate: canRotate,
              ),
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'aiTasks',
              path: ApiPaths.platformAiAdminTasks,
              paginated: true,
              icon: Icons.route_outlined,
              emptyTitleKey: 'noAiTasks',
              title: (resource) =>
                  resource.text('label', fallback: resource.text('key')),
              subtitle: (resource) => resource.text('key'),
              status: (resource) =>
                  resource.flag('enabled') ? 'active' : 'inactive',
              fields: const [
                CollectionFieldSpec(key: 'key', labelKey: 'taskKey'),
                CollectionFieldSpec(
                  key: 'enabled',
                  labelKey: 'enabled',
                  type: CollectionFieldType.boolean,
                ),
                CollectionFieldSpec(
                  key: 'daily_per_user',
                  labelKey: 'dailyPerUser',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'daily_per_tenant',
                  labelKey: 'dailyPerTenant',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'monthly_per_tenant',
                  labelKey: 'monthlyPerTenant',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'monthly_platform_requests',
                  labelKey: 'monthlyPlatformRequests',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'max_output_tokens',
                  labelKey: 'maxOutputTokens',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'temperature',
                  labelKey: 'temperature',
                  type: CollectionFieldType.decimal,
                ),
                CollectionFieldSpec(
                  key: 'timeout_seconds',
                  labelKey: 'timeoutSeconds',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'max_retries',
                  labelKey: 'maxRetries',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(key: 'description', labelKey: 'description'),
              ],
              actions: [
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'seedAiTasks',
                    path: (_) => ApiPaths.platformAiAdminTasksSeed,
                    confirmKey: 'seedAiTasksMessage',
                    icon: Icons.playlist_add_check,
                  ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'aiPrompts',
              path: ApiPaths.platformAiAdminPrompts,
              paginated: true,
              icon: Icons.article_outlined,
              emptyTitleKey: 'noAiPrompts',
              title: (resource) =>
                  resource.text('name', fallback: resource.text('key')),
              subtitle: (resource) {
                final task = resource.map('task');
                return task?['label']?.toString() ?? resource.text('key');
              },
              fields: const [
                CollectionFieldSpec(key: 'key', labelKey: 'promptKey'),
                CollectionFieldSpec(key: 'description', labelKey: 'description'),
                CollectionFieldSpec(
                  key: 'active_version_id',
                  labelKey: 'activeVersion',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'versions',
                  labelKey: 'versions',
                  type: CollectionFieldType.json,
                ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'activityLog',
              path: ApiPaths.platformAiAdminActivity,
              paginated: true,
              icon: Icons.history,
              emptyTitleKey: 'noActivity',
              title: (resource) {
                final provider = resource.text('provider');
                final task = resource.text('task');
                return provider.isEmpty ? task : '$task · $provider';
              },
              subtitle: (resource) => resource.text('model'),
              status: (resource) => resource.text('status'),
              fields: const [
                CollectionFieldSpec(key: 'correlation_id', labelKey: 'correlationId'),
                CollectionFieldSpec(
                  key: 'tenant_id',
                  labelKey: 'tenant',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(key: 'feature', labelKey: 'feature'),
                CollectionFieldSpec(key: 'provider', labelKey: 'provider'),
                CollectionFieldSpec(key: 'model', labelKey: 'model'),
                CollectionFieldSpec(key: 'status', labelKey: 'status'),
                CollectionFieldSpec(key: 'error_category', labelKey: 'errorCategory'),
                CollectionFieldSpec(
                  key: 'http_status',
                  labelKey: 'httpStatus',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'attempt',
                  labelKey: 'attempt',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'fallback_attempts',
                  labelKey: 'fallbackAttempts',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'duration_ms',
                  labelKey: 'durationMs',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'input_tokens',
                  labelKey: 'inputTokens',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'output_tokens',
                  labelKey: 'outputTokens',
                  type: CollectionFieldType.integer,
                ),
                CollectionFieldSpec(
                  key: 'cache_hit',
                  labelKey: 'cacheHit',
                  type: CollectionFieldType.boolean,
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

class _AiOverviewTab extends ConsumerStatefulWidget {
  const _AiOverviewTab();

  @override
  ConsumerState<_AiOverviewTab> createState() => _AiOverviewTabState();
}

class _AiOverviewTabState extends ConsumerState<_AiOverviewTab> {
  JsonMap? _overview;
  JsonMap? _settings;
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
      final api = ref.read(apiClientProvider);
      final results = await Future.wait([
        api.get<JsonMap>(ApiPaths.platformAiAdminOverview, decode: _map),
        api.get<JsonMap>(ApiPaths.platformAiAdminSettings, decode: _map),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = results[0];
        _settings = results[1];
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
          const SizedBox(height: 80),
          ErrorView(message: _error!, onRetry: _load),
        ],
      );
    }
    final overview = _overview ?? const <String, dynamic>{};
    final settings = _settings ?? const <String, dynamic>{};
    final counts = _mapOf(overview['counts']);
    final totals = _mapOf(overview['totals']);
    final byok = _mapOf(overview['byok']);
    final providers = (overview['providers'] as List?) ?? const [];
    final unregistered = (overview['unregistered_catalog'] as List?) ?? const [];
    final features = _mapOf(settings['features']);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.page,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      (overview['ai_enabled'] as bool? ?? false)
                          ? Icons.auto_awesome
                          : Icons.power_settings_new,
                      color: context.scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.tr('aiServing'),
                      style: context.texts.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    StatusChip(
                      status: (overview['ai_enabled'] as bool? ?? false)
                          ? 'active'
                          : 'inactive',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _Metric(
                      label: context.tr('providers'),
                      value: '${counts['providers'] ?? 0}',
                    ),
                    _Metric(
                      label: context.tr('enabled'),
                      value: '${counts['providers_enabled'] ?? 0}',
                    ),
                    _Metric(
                      label: context.tr('aiTasks'),
                      value: '${counts['tasks'] ?? 0}',
                    ),
                    _Metric(
                      label: context.tr('credentials'),
                      value: '${counts['credentials'] ?? 0}',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      (byok['enabled'] as bool? ?? false)
                          ? Icons.vpn_key_outlined
                          : Icons.lock_outline,
                      size: 16,
                      color: context.dukavo.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        (byok['enabled'] as bool? ?? false)
                            ? context.tr('byokEnabled')
                            : context.tr('byokDisabled'),
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.dukavo.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: context.tr('aiUsage30Days'),
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _Metric(
                  label: context.tr('requests'),
                  value: '${totals['requests'] ?? 0}',
                ),
                _Metric(
                  label: context.tr('failures'),
                  value: '${totals['failures'] ?? 0}',
                ),
                _Metric(
                  label: context.tr('tokens'),
                  value: Formatters.number(
                    (totals['tokens'] as num?) ?? 0,
                  ),
                ),
                _Metric(
                  label: context.tr('estimatedCost'),
                  value:
                      '\$${((totals['estimated_cost_usd'] as num?) ?? 0).toStringAsFixed(2)}',
                ),
                _Metric(
                  label: context.tr('cacheHits'),
                  value: '${totals['cache_hits'] ?? 0}',
                ),
                _Metric(
                  label: context.tr('fallbackRequests'),
                  value: '${totals['fallback_requests'] ?? 0}',
                ),
                _Metric(
                  label: context.tr('tenants'),
                  value: '${totals['unique_tenants'] ?? 0}',
                ),
              ],
            ),
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: context.tr('aiFeatureLimits'),
              child: Column(
                children: [
                  for (final entry in features.entries)
                    KeyValueRow(
                      label: entry.key,
                      value: _featureSummary(_mapOf(entry.value), context),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: context.tr('providers'),
            child: Column(
              children: [
                for (final raw in providers)
                  _ProviderRow(resource: JsonResource(_mapOf(raw))),
              ],
            ),
          ),
          if (unregistered.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SectionCard(
              title: context.tr('unregisteredProviders'),
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final entry in unregistered)
                    Chip(
                      label: Text(
                        '${_mapOf(entry)['name'] ?? _mapOf(entry)['key']}',
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          InfoBanner(
            icon: Icons.info_outline_rounded,
            message: context.tr('aiAdminReadOnlyNote'),
          ),
        ],
      ),
    );
  }

  static String _featureSummary(JsonMap feature, BuildContext context) {
    final enabled = feature['enabled'] as bool? ?? false;
    if (!enabled) return context.tr('inactive');
    final user = feature['daily_per_user'] ?? 0;
    final tenant = feature['daily_per_tenant'] ?? 0;
    return '${context.tr('enabled')} · $user / $tenant';
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.resource});

  final JsonResource resource;

  @override
  Widget build(BuildContext context) {
    final configuration = resource.map('configuration');
    final source = configuration?['source'];
    final health = resource.map('health');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(resource.text('name', fallback: resource.text('key'))),
      subtitle: Text(
        [
          if (source != null) '${context.tr('credentialSource')}: $source',
          if (health?['state'] != null) '${health!['state']}',
        ].join(' · '),
      ),
      trailing: StatusChip(
        status: resource.flag('enabled') ? 'active' : 'inactive',
        compact: true,
      ),
    );
  }
}

class _AiCredentialsSection extends ConsumerStatefulWidget {
  const _AiCredentialsSection({
    required this.provider,
    required this.canRotate,
  });

  final JsonResource provider;
  final bool canRotate;

  @override
  ConsumerState<_AiCredentialsSection> createState() =>
      _AiCredentialsSectionState();
}

class _AiCredentialsSectionState extends ConsumerState<_AiCredentialsSection> {
  List<JsonResource> _credentials = const <JsonResource>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiClientProvider);
      final page = await api.list<JsonResource>(
        ApiPaths.platformAiAdminProviderCredentials(widget.provider.id),
        item: JsonResource.fromJson,
      );
      if (!mounted) return;
      setState(() {
        _credentials = page.items;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('credentials'),
          style: context.texts.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: LoadingView(),
          )
        else if (_credentials.isEmpty)
          Text(
            context.tr('noCredentials'),
            style: context.texts.bodySmall
                ?.copyWith(color: context.dukavo.textSecondary),
          )
        else
          for (final credential in _credentials)
            KeyValueRow(
              label: credential.text('masked_key', fallback: '••••'),
              value: credential.text('model', fallback: '—'),
            ),
        if (widget.canRotate) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: context.tr('rotateCredential'),
            icon: Icons.vpn_key_outlined,
            variant: AppButtonVariant.outlined,
            expand: true,
            onPressed: _rotate,
          ),
        ],
      ],
    );
  }

  Future<void> _rotate() async {
    final apiKey = TextEditingController();
    final baseUrl = TextEditingController();
    final model = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('rotateCredential')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: apiKey,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('apiKey'),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 8)
                          ? dialogContext.tr('requiredField')
                          : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: baseUrl,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('baseUrl'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: model,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('model'),
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
    if (saved == true) {
      try {
        await ref.read(apiClientProvider).post<dynamic>(
          ApiPaths.platformAiAdminProviderCredentials(widget.provider.id),
          body: {
            'api_key': apiKey.text.trim(),
            if (baseUrl.text.trim().isNotEmpty) 'base_url': baseUrl.text.trim(),
            if (model.text.trim().isNotEmpty) 'model': model.text.trim(),
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
    apiKey.dispose();
    baseUrl.dispose();
    model.dispose();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.texts.labelSmall?.copyWith(
            color: context.dukavo.textMuted,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.texts.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

JsonMap _map(Object? data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  return const <String, dynamic>{};
}

JsonMap _mapOf(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
