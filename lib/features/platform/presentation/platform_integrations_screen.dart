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
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';

/// Platform omnichannel integration health.
///
/// The list is channel-level health; the sheet is the tenant connections and
/// unprocessed webhook evidence the server already exposes. A re-check calls
/// the provider, so it stays behind the manage grant.
class PlatformIntegrationsScreen extends ConsumerWidget {
  const PlatformIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canViewPlatformIntegrations) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('integrationHealth'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final canManage = permissions.canManagePlatformIntegrations;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('integrationHealth'))),
      body: CollectionScreen(
        titleKey: 'integrationHealth',
        path: ApiPaths.platformIntegrations,
        itemsKey: 'channels',
        icon: Icons.hub_outlined,
        emptyTitleKey: 'noIntegrations',
        title: (resource) => resource.text('name', fallback: resource.text('key')),
        subtitle: (resource) => [
          resource.text('provider'),
          resource.text('availability'),
          '${resource.number('connected')?.toInt() ?? 0}/${resource.number('connections')?.toInt() ?? 0}',
        ].where((part) => part.isNotEmpty).join(' · '),
        status: (resource) {
          final failing = resource.number('failing')?.toInt() ?? 0;
          if (!resource.flag('platform_configured')) return 'inactive';
          return failing > 0 ? 'failed' : 'active';
        },
        fields: const [
          CollectionFieldSpec(key: 'key', labelKey: 'channelKey'),
          CollectionFieldSpec(key: 'provider', labelKey: 'provider'),
          CollectionFieldSpec(key: 'availability', labelKey: 'availability'),
          CollectionFieldSpec(key: 'capabilities', labelKey: 'capabilities', type: CollectionFieldType.json),
          CollectionFieldSpec(key: 'platform_configured', labelKey: 'platformConfigured', type: CollectionFieldType.boolean),
          CollectionFieldSpec(key: 'connections', labelKey: 'connections', type: CollectionFieldType.integer),
          CollectionFieldSpec(key: 'connected', labelKey: 'connected', type: CollectionFieldType.integer),
          CollectionFieldSpec(key: 'failing', labelKey: 'failing', type: CollectionFieldType.integer),
          CollectionFieldSpec(key: 'unprocessed_events', labelKey: 'unprocessedEvents', type: CollectionFieldType.integer),
          CollectionFieldSpec(key: 'credential_fields', labelKey: 'credentialFields', type: CollectionFieldType.json),
          CollectionFieldSpec(key: 'notes', labelKey: 'notes'),
        ],
        actions: [
          if (canManage)
            CollectionActionSpec(
              labelKey: 'recheckIntegration',
              path: (resource) =>
                  ApiPaths.platformIntegrationRecheck(resource.text('key')),
              confirmKey: 'recheckIntegrationMessage',
              icon: Icons.health_and_safety_outlined,
            ),
        ],
        onItemTap: (sheetContext, resource) => showModalBottomSheet<void>(
          context: sheetContext,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _ChannelDetailSheet(
            channelKey: resource.text('key'),
            canManage: canManage,
          ),
        ),
      ),
    );
  }
}

class _ChannelDetailSheet extends ConsumerStatefulWidget {
  const _ChannelDetailSheet({required this.channelKey, required this.canManage});

  final String channelKey;
  final bool canManage;

  @override
  ConsumerState<_ChannelDetailSheet> createState() =>
      _ChannelDetailSheetState();
}

class _ChannelDetailSheetState extends ConsumerState<_ChannelDetailSheet> {
  JsonMap? _data;
  bool _loading = true;
  bool _checking = false;
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
            ApiPaths.platformIntegration(widget.channelKey),
            decode: (value) =>
                value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
          );
      if (!mounted) return;
      setState(() {
        _data = data;
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

  Future<void> _recheck() async {
    setState(() => _checking = true);
    try {
      await ref.read(apiClientProvider).post<dynamic>(
            ApiPaths.platformIntegrationRecheck(widget.channelKey),
          );
      if (!mounted) return;
      AppSnack.show(context, context.tr('recheckComplete'));
      await _load();
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = _data == null ? null : _mapOf(_data!['channel']);
    final connections = (_data?['connections'] as List?) ?? const [];
    final events = (_data?['unprocessed_events'] as List?) ?? const [];

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: _loading
            ? const LoadingView()
            : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : ListView(
                    padding: AppSpacing.page,
                    children: [
                      Text(
                        channel?['name']?.toString() ??
                            widget.channelKey,
                        style: context.texts.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        [
                          channel?['provider'],
                          channel?['availability'],
                        ].whereType<Object>().join(' · '),
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.dukavo.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (channel != null)
                        SectionCard(
                          child: Column(
                            children: [
                              KeyValueRow(
                                label: context.tr('platformConfigured'),
                                value: (channel['platform_configured'] as bool? ??
                                        false)
                                    ? context.tr('yes')
                                    : context.tr('no'),
                              ),
                              KeyValueRow(
                                label: context.tr('capabilities'),
                                value: ((channel['capabilities'] as List?) ?? const [])
                                    .join(', '),
                              ),
                              KeyValueRow(
                                label: context.tr('credentialFields'),
                                value: ((channel['credential_fields'] as List?) ?? const [])
                                    .join(', '),
                              ),
                              KeyValueRow(
                                label: context.tr('notes'),
                                value: channel['notes']?.toString() ?? '—',
                              ),
                            ],
                          ),
                        ),
                      if (widget.canManage) ...[
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: context.tr('recheckIntegration'),
                          icon: Icons.health_and_safety_outlined,
                          loading: _checking,
                          expand: true,
                          onPressed: _recheck,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SectionCard(
                        title: context.tr('connections'),
                        child: connections.isEmpty
                            ? Text(context.tr('noConnections'))
                            : Column(
                                children: [
                                  for (final raw in connections)
                                    _ConnectionRow(resource: JsonResource(_mapOf(raw))),
                                ],
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SectionCard(
                        title: context.tr('unprocessedEvents'),
                        child: events.isEmpty
                            ? Text(context.tr('nothingHereYet'))
                            : Column(
                                children: [
                                  for (final raw in events)
                                    _EventRow(resource: JsonResource(_mapOf(raw))),
                                ],
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({required this.resource});

  final JsonResource resource;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(resource.text('name', fallback: '—')),
      subtitle: Text(
        [
          resource.text('tenant'),
          resource.text('external_account_id'),
          resource.text('error_message'),
        ].where((part) => part.isNotEmpty).join(' · '),
      ),
      trailing: StatusChip(
        status: resource.text('health', fallback: resource.text('status')),
        compact: true,
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.resource});

  final JsonResource resource;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(resource.text('event_type', fallback: '—')),
      subtitle: Text(resource.text('failure')),
    );
  }
}

JsonMap _mapOf(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
