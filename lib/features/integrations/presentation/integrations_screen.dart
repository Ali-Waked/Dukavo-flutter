import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';
import '../../stores/domain/store_domain.dart';
import '../application/integrations_controller.dart';
import '../domain/integrations_domain.dart';

/// The workspace's omnichannel integration centre.
///
/// Every declared channel is listed, including ones that await provider access:
/// those say so instead of offering a button that cannot work. Credential
/// values are write-only — a stored field shows as configured, and leaving it
/// blank keeps the value the server already holds.
class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  int? _busyId;

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    final canManage = permissions.canManageIntegrations;
    final channelsAsync = ref.watch(integrationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('integrations')),
        actions: [
          IconButton(
            tooltip: context.tr('integrationsRefresh'),
            onPressed: () => ref.invalidate(integrationsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: channelsAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(error),
          onRetry: () => ref.invalidate(integrationsProvider),
        ),
        data: (channels) {
          if (channels.isEmpty) {
            return EmptyState(
              icon: Icons.hub_outlined,
              title: context.tr('integrationsEmptyTitle'),
              message: context.tr('integrationsEmptyBody'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(integrationsProvider),
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Text(
                  context.tr('integrationsSubtitle'),
                  style: context.texts.bodyMedium
                      ?.copyWith(color: context.dukavo.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                InfoBanner(
                  message: context.tr('integrationsCredentialsHint'),
                  icon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final channel in channels) ...[
                  _ChannelCard(
                    channel: channel,
                    canManage: canManage,
                    busyId: _busyId,
                    onConnect: () => _openForm(channel),
                    onEdit: (connection) =>
                        _openForm(channel, connection: connection),
                    onTest: _test,
                    onReconnect: _reconnect,
                    onDisconnect: _disconnect,
                    onCopy: _copy,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(
    ChannelDefinition channel, {
    ChannelConnection? connection,
  }) async {
    final stores =
        ref.read(storeOptionsProvider).valueOrNull ?? const <Store>[];

    final result = await showModalBottomSheet<_IntegrationFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _IntegrationFormSheet(
          channel: channel,
          connection: connection,
          stores: stores,
        ),
      ),
    );

    if (result == null) return;

    try {
      final actions = ref.read(integrationsActionsProvider);
      if (connection == null) {
        await actions.connect(channel.key, result.draft);
      } else {
        await actions.update(connection.id, result.draft);
      }
      if (mounted) AppSnack.show(context, context.tr('integrationsSaved'));
    } catch (error) {
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    }
  }

  Future<void> _test(ChannelConnection connection) async {
    await _run(connection.id, () async {
      await ref.read(integrationsActionsProvider).test(connection.id);
      if (mounted) AppSnack.show(context, context.tr('integrationsTested'));
    });
  }

  Future<void> _reconnect(ChannelConnection connection) async {
    await _run(connection.id, () async {
      await ref.read(integrationsActionsProvider).reconnect(connection.id);
      if (mounted) {
        AppSnack.show(context, context.tr('integrationsReconnected'));
      }
    });
  }

  Future<void> _disconnect(ChannelConnection connection) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('integrationsDisconnectTitle', args: {
        'name': connection.name,
      }),
      message: context.tr('integrationsDisconnectBody'),
      confirmLabel: context.tr('integrationsDisconnect'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;

    await _run(connection.id, () async {
      await ref.read(integrationsActionsProvider).disconnect(connection.id);
      if (mounted) {
        AppSnack.show(context, context.tr('integrationsDisconnected'));
      }
    });
  }

  Future<void> _run(int id, Future<void> Function() action) async {
    if (_busyId != null) return;
    setState(() => _busyId = id);
    try {
      await action();
    } catch (error) {
      if (mounted) AppSnack.show(context, _message(error), isError: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _copy(String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (mounted) AppSnack.show(context, context.tr('integrationsCopied'));
    } catch (_) {
      if (mounted) {
        AppSnack.show(context, context.tr('integrationsCopyFailed'),
            isError: true);
      }
    }
  }

  String _message(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.channel,
    required this.canManage,
    required this.busyId,
    required this.onConnect,
    required this.onEdit,
    required this.onTest,
    required this.onReconnect,
    required this.onDisconnect,
    required this.onCopy,
  });

  final ChannelDefinition channel;
  final bool canManage;
  final int? busyId;
  final VoidCallback onConnect;
  final ValueChanged<ChannelConnection> onEdit;
  final ValueChanged<ChannelConnection> onTest;
  final ValueChanged<ChannelConnection> onReconnect;
  final ValueChanged<ChannelConnection> onDisconnect;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                alignment: Alignment.center,
                child: Text(
                  channel.name.isEmpty ? '?' : channel.name[0].toUpperCase(),
                  style: context.texts.titleMedium?.copyWith(
                    color: context.scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          channel.name,
                          style: context.texts.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        _Pill(
                          label: _availabilityLabel(context, channel),
                          tone: switch (channel.availability) {
                            'available' => _PillTone.success,
                            'awaiting_configuration' => _PillTone.warning,
                            _ => _PillTone.info,
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        channel.provider,
                        style: context.texts.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: context.dukavo.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      channel.notes,
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.dukavo.textSecondary),
                    ),
                  ],
                ),
              ),
              if (canManage && !channel.awaitsConfiguration)
                IconButton(
                  tooltip: context.tr('integrationsConnect'),
                  onPressed: onConnect,
                  icon: const Icon(Icons.add_link_rounded),
                ),
            ],
          ),
          if (channel.awaitsProviderAccess) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoBanner(
              tone: InfoBannerTone.warning,
              title: context.tr('integrationsAwaitingAccessTitle'),
              message: context.tr('integrationsAwaitingAccessBody'),
              icon: Icons.hourglass_top_rounded,
            ),
          ] else if (channel.awaitsConfiguration) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoBanner(
              title: context.tr('integrationsAwaitingConfigTitle'),
              message: context.tr('integrationsAwaitingConfigBody'),
              icon: Icons.settings_suggest_outlined,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xxs,
            runSpacing: AppSpacing.xxs,
            children: [
              for (final capability in channel.capabilities.enabled)
                _CapabilityChip(label: _capabilityLabel(context, capability)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('integrationsConnections'),
            style: context.texts.labelLarge
                ?.copyWith(color: context.dukavo.textMuted),
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (channel.connections.isEmpty)
            Text(
              context.tr('integrationsNoConnections'),
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.textSecondary),
            )
          else
            for (final connection in channel.connections)
              _ConnectionTile(
                connection: connection,
                canManage: canManage,
                busy: busyId == connection.id,
                onEdit: () => onEdit(connection),
                onTest: () => onTest(connection),
                onReconnect: () => onReconnect(connection),
                onDisconnect: () => onDisconnect(connection),
                onCopy: () => onCopy(connection.webhookUrl),
              ),
        ],
      ),
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile({
    required this.connection,
    required this.canManage,
    required this.busy,
    required this.onEdit,
    required this.onTest,
    required this.onReconnect,
    required this.onDisconnect,
    required this.onCopy,
  });

  final ChannelConnection connection;
  final bool canManage;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onTest;
  final VoidCallback onReconnect;
  final VoidCallback onDisconnect;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.xxs,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          connection.name,
                          style: context.texts.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        _Pill(
                          label: _statusLabel(context, connection.status),
                          tone: _statusTone(connection.status),
                        ),
                        _Pill(
                          label: _healthLabel(context, connection.health),
                          tone: _healthTone(connection.health),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        connection.storeName ??
                            context.tr('integrationsAllStores'),
                        if (connection.externalAccountId != null &&
                            connection.externalAccountId!.isNotEmpty)
                          connection.externalAccountId!,
                      ].join(' · '),
                      style: context.texts.bodySmall
                          ?.copyWith(color: context.dukavo.textMuted),
                    ),
                    if (connection.errorMessage != null &&
                        connection.errorMessage!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        connection.errorMessage!,
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.scheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (canManage)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'test':
                        onTest();
                      case 'reconnect':
                        onReconnect();
                      case 'edit':
                        onEdit();
                      case 'disconnect':
                        onDisconnect();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'test',
                      child: Text(context.tr('integrationsTest')),
                    ),
                    if (connection.status == 'disconnected' &&
                        connection.channel == 'whatsapp')
                      PopupMenuItem(
                        value: 'reconnect',
                        child: Text(context.tr('integrationsReconnect')),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.tr('integrationsEditConnection')),
                    ),
                    PopupMenuItem(
                      value: 'disconnect',
                      child: Text(context.tr('integrationsDisconnect')),
                    ),
                  ],
                ),
            ],
          ),
          if (connection.webhookUrl.isNotEmpty)
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.content_copy_rounded,
                      size: 14,
                      color: context.dukavo.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          connection.webhookUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: context.dukavo.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IntegrationFormSheet extends StatefulWidget {
  const _IntegrationFormSheet({
    required this.channel,
    required this.connection,
    required this.stores,
  });

  final ChannelDefinition channel;
  final ChannelConnection? connection;
  final List<Store> stores;

  @override
  State<_IntegrationFormSheet> createState() => _IntegrationFormSheetState();
}

class _IntegrationFormSheetState extends State<_IntegrationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final Map<String, TextEditingController> _credentials = {};
  int? _storeId;

  @override
  void initState() {
    super.initState();
    _name.text = widget.connection?.name ?? widget.channel.name;
    _storeId = widget.connection?.storeId;
    for (final field in widget.channel.credentialFields) {
      _credentials[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final controller in _credentials.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.connection == null
                    ? context.tr('integrationsConnectChannel', args: {
                        'channel': widget.channel.name,
                      })
                    : context.tr('integrationsEditConnection'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _name,
                label: context.tr('integrationsName'),
                hint: context.tr('integrationsNameHint'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int?>(
                initialValue: _storeId,
                decoration: InputDecoration(
                  labelText: context.tr('integrationsStore'),
                ),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(context.tr('integrationsAllStores')),
                  ),
                  for (final store in widget.stores)
                    DropdownMenuItem(value: store.id, child: Text(store.name)),
                ],
                onChanged: (value) => setState(() => _storeId = value),
              ),
              if (widget.channel.credentialFields.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.tr('integrationsCredentials'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.tr('integrationsCredentialsHint'),
                  style: context.texts.bodySmall
                      ?.copyWith(color: context.dukavo.textSecondary),
                ),
                for (final field in widget.channel.credentialFields) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: _credentials[field.key],
                    label:
                        '${field.label} (${field.required ? context.tr('integrationsRequired') : context.tr('integrationsOptional')})',
                    hint: field.secret && field.configured
                        ? context.tr('integrationsSecretHint')
                        : field.help,
                    helper: field.configured
                        ? context.tr('integrationsConfigured')
                        : null,
                    obscureText: field.secret,
                    validator: (value) {
                      if (!field.required || field.configured) return null;
                      return value == null || value.trim().isEmpty
                          ? context.tr('requiredField')
                          : null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.tr('save'),
                expand: true,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final credentials = <String, String>{};
    for (final entry in _credentials.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) credentials[entry.key] = value;
    }

    Navigator.of(context).pop(
      _IntegrationFormResult(
        IntegrationDraft(
          name: _name.text.trim(),
          storeId: _storeId,
          credentials: credentials,
        ),
      ),
    );
  }
}

class _IntegrationFormResult {
  const _IntegrationFormResult(this.draft);

  final IntegrationDraft draft;
}

enum _PillTone { success, warning, danger, info, neutral }

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.tone});

  final String label;
  final _PillTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    final (background, foreground) = switch (tone) {
      _PillTone.success => (colors.successContainer, colors.onSuccessContainer),
      _PillTone.warning => (colors.warningContainer, colors.onWarningContainer),
      _PillTone.danger => (colors.dangerContainer, colors.onDangerContainer),
      _PillTone.info => (colors.infoContainer, colors.onInfoContainer),
      _PillTone.neutral => (colors.surfaceHigh, colors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.texts.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: context.dukavo.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.texts.labelSmall
            ?.copyWith(color: context.dukavo.textSecondary),
      ),
    );
  }
}

String _availabilityLabel(BuildContext context, ChannelDefinition channel) {
  switch (channel.availability) {
    case 'available':
      return context.tr('integrationsAvailabilityAvailable');
    case 'awaiting_configuration':
      return context.tr('integrationsAvailabilityAwaitingConfiguration');
    default:
      return context.tr('integrationsAvailabilityAwaitingProviderAccess');
  }
}

String _statusLabel(BuildContext context, String status) {
  switch (status) {
    case 'connected':
      return context.tr('integrationsStatusConnected');
    case 'disconnected':
      return context.tr('integrationsStatusDisconnected');
    case 'error':
      return context.tr('integrationsStatusError');
    default:
      return context.tr('integrationsStatusPending');
  }
}

String _healthLabel(BuildContext context, String health) {
  switch (health) {
    case 'healthy':
      return context.tr('integrationsHealthHealthy');
    case 'degraded':
      return context.tr('integrationsHealthDegraded');
    case 'failing':
      return context.tr('integrationsHealthFailing');
    default:
      return context.tr('integrationsHealthUnknown');
  }
}

_PillTone _statusTone(String status) {
  switch (status) {
    case 'connected':
      return _PillTone.success;
    case 'error':
      return _PillTone.danger;
    case 'pending':
      return _PillTone.warning;
    default:
      return _PillTone.neutral;
  }
}

_PillTone _healthTone(String health) {
  switch (health) {
    case 'healthy':
      return _PillTone.success;
    case 'degraded':
      return _PillTone.warning;
    case 'failing':
      return _PillTone.danger;
    default:
      return _PillTone.neutral;
  }
}

String _capabilityLabel(BuildContext context, String key) {
  switch (key) {
    case 'image':
      return context.tr('integrationsCapabilityImage');
    case 'document':
      return context.tr('integrationsCapabilityDocument');
    case 'audio':
      return context.tr('integrationsCapabilityAudio');
    case 'voice':
      return context.tr('integrationsCapabilityVoice');
    case 'video':
      return context.tr('integrationsCapabilityVideo');
    case 'template':
      return context.tr('integrationsCapabilityTemplate');
    case 'delivery_status':
      return context.tr('integrationsCapabilityDeliveryStatus');
    case 'read_status':
      return context.tr('integrationsCapabilityReadStatus');
    case 'media_download':
      return context.tr('integrationsCapabilityMediaDownload');
    case 'typing':
      return context.tr('integrationsCapabilityTyping');
    default:
      return context.tr('integrationsCapabilityText');
  }
}
