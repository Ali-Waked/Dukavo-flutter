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

/// Platform notification operations: campaigns, email templates and
/// delivery attempts. The private message payload is never drawn because the
/// server never sends it to this surface.
class PlatformNotificationsScreen extends ConsumerWidget {
  const PlatformNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canViewNotifications) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('notificationOperations'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final canManage = permissions.canManageNotifications;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('notificationOperations')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: context.tr('campaigns')),
              Tab(text: context.tr('emailTemplates')),
              Tab(text: context.tr('deliveries')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CollectionScreen(
              embedded: true,
              titleKey: 'campaigns',
              path: ApiPaths.platformNotificationCampaigns,
              paginated: true,
              icon: Icons.campaign_outlined,
              emptyTitleKey: 'noCampaigns',
              title: (resource) => resource.text('title', fallback: '—'),
              subtitle: (resource) {
                final counts = resource.map('counts');
                return [
                  resource.text('status_label', fallback: resource.text('status')),
                  if (counts != null)
                    '${counts['sent'] ?? 0}/${counts['total'] ?? 0}',
                ].where((part) => part.isNotEmpty).join(' · ');
              },
              status: (resource) => resource.text('status'),
              fields: const [
                CollectionFieldSpec(key: 'body', labelKey: 'message'),
                CollectionFieldSpec(key: 'category', labelKey: 'category'),
                CollectionFieldSpec(key: 'severity', labelKey: 'severity'),
                CollectionFieldSpec(key: 'priority', labelKey: 'priority'),
                CollectionFieldSpec(key: 'channels', labelKey: 'channels', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'audience', labelKey: 'audience', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'is_marketing', labelKey: 'isMarketing', type: CollectionFieldType.boolean),
                CollectionFieldSpec(key: 'action_url', labelKey: 'actionUrl'),
                CollectionFieldSpec(key: 'counts', labelKey: 'counts', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'scheduled_at', labelKey: 'scheduledAt', type: CollectionFieldType.date),
                CollectionFieldSpec(key: 'published_at', labelKey: 'publishedAt', type: CollectionFieldType.date),
                CollectionFieldSpec(key: 'cancelled_at', labelKey: 'cancelledAt', type: CollectionFieldType.date),
                CollectionFieldSpec(key: 'created_at', labelKey: 'createdAt', type: CollectionFieldType.date),
              ],
              extraSheet: (sheetContext, resource) => _CampaignScheduleSection(
                resource: resource,
                canManage: canManage,
              ),
              actions: [
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'publishCampaign',
                    path: (resource) =>
                        ApiPaths.platformNotificationCampaignPublish(resource.id),
                    confirmKey: 'publishCampaignMessage',
                    icon: Icons.send_outlined,
                    visible: (resource) => resource.flag('can_publish'),
                  ),
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'cancelCampaign',
                    path: (resource) =>
                        ApiPaths.platformNotificationCampaignCancel(resource.id),
                    confirmKey: 'cancelCampaignMessage',
                    icon: Icons.cancel_outlined,
                    destructive: true,
                    visible: (resource) => resource.flag('can_cancel'),
                  ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'emailTemplates',
              path: ApiPaths.platformEmailTemplates,
              itemsKey: 'templates',
              icon: Icons.mail_outline_rounded,
              emptyTitleKey: 'noEmailTemplates',
              title: (resource) =>
                  resource.text('label', fallback: resource.text('key')),
              subtitle: (resource) => [
                resource.text('key'),
                resource.text('group'),
              ].where((part) => part.isNotEmpty).join(' · '),
              status: (resource) =>
                  resource.flag('enabled') ? 'active' : 'inactive',
              fields: const [
                CollectionFieldSpec(key: 'key', labelKey: 'templateKey'),
                CollectionFieldSpec(key: 'kind', labelKey: 'kind'),
                CollectionFieldSpec(key: 'group', labelKey: 'group'),
                CollectionFieldSpec(key: 'optional', labelKey: 'optional', type: CollectionFieldType.boolean),
                CollectionFieldSpec(key: 'enabled', labelKey: 'enabled', type: CollectionFieldType.boolean),
                CollectionFieldSpec(key: 'variables', labelKey: 'variables', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'effective', labelKey: 'effectiveCopy', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'updated_at', labelKey: 'updatedAt', type: CollectionFieldType.date),
              ],
              extraSheet: (sheetContext, resource) => _EmailTemplateEditor(
                resource: resource,
                canManage: canManage,
              ),
              actions: [
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'sendTestEmail',
                    path: (resource) =>
                        ApiPaths.platformEmailTemplateTest(resource.text('key')),
                    icon: Icons.send_outlined,
                  ),
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'restoreTemplate',
                    path: (resource) =>
                        ApiPaths.platformEmailTemplateRestore(resource.text('key')),
                    confirmKey: 'restoreTemplateMessage',
                    icon: Icons.restore,
                    destructive: true,
                  ),
              ],
            ),
            CollectionScreen(
              embedded: true,
              titleKey: 'deliveries',
              path: ApiPaths.platformNotificationDeliveries,
              paginated: true,
              icon: Icons.local_shipping_outlined,
              emptyTitleKey: 'noDeliveries',
              title: (resource) => [
                resource.text('event_key'),
                resource.text('channel'),
              ].where((part) => part.isNotEmpty).join(' · '),
              subtitle: (resource) {
                final recipient = resource.map('recipient');
                final tenant = resource.map('tenant');
                return [
                  recipient?['name']?.toString(),
                  tenant?['name']?.toString(),
                  resource.text('error'),
                ].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
              },
              status: (resource) => resource.text('status'),
              fields: const [
                CollectionFieldSpec(key: 'event_key', labelKey: 'eventKey'),
                CollectionFieldSpec(key: 'channel', labelKey: 'channel'),
                CollectionFieldSpec(key: 'provider', labelKey: 'provider'),
                CollectionFieldSpec(key: 'status', labelKey: 'status'),
                CollectionFieldSpec(key: 'attempts', labelKey: 'attempts', type: CollectionFieldType.integer),
                CollectionFieldSpec(key: 'recipient', labelKey: 'recipient', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'tenant', labelKey: 'tenant', type: CollectionFieldType.json),
                CollectionFieldSpec(key: 'error', labelKey: 'error'),
                CollectionFieldSpec(key: 'failure_type', labelKey: 'failureType'),
                CollectionFieldSpec(key: 'provider_message_id', labelKey: 'providerMessageId'),
                CollectionFieldSpec(key: 'queued_at', labelKey: 'queuedAt', type: CollectionFieldType.date),
                CollectionFieldSpec(key: 'sent_at', labelKey: 'sentAt', type: CollectionFieldType.date),
                CollectionFieldSpec(key: 'delivered_at', labelKey: 'deliveredAt', type: CollectionFieldType.date),
                CollectionFieldSpec(key: 'failed_at', labelKey: 'failedAt', type: CollectionFieldType.date),
              ],
              actions: [
                if (canManage)
                  CollectionActionSpec(
                    labelKey: 'retryDelivery',
                    path: (resource) =>
                        ApiPaths.platformNotificationDeliveryRetry(resource.id),
                    confirmKey: 'retryDeliveryMessage',
                    icon: Icons.refresh,
                    visible: (resource) => resource.flag('retryable'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignScheduleSection extends ConsumerStatefulWidget {
  const _CampaignScheduleSection({
    required this.resource,
    required this.canManage,
  });

  final JsonResource resource;
  final bool canManage;

  @override
  ConsumerState<_CampaignScheduleSection> createState() =>
      _CampaignScheduleSectionState();
}

class _CampaignScheduleSectionState
    extends ConsumerState<_CampaignScheduleSection> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.canManage) return const SizedBox.shrink();
    final canSchedule = widget.resource.text('status') == 'draft' ||
        widget.resource.text('status') == 'scheduled';
    if (!canSchedule) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          label: context.tr('scheduleCampaign'),
          icon: Icons.event_outlined,
          variant: AppButtonVariant.outlined,
          expand: true,
          loading: _saving,
          onPressed: _schedule,
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  Future<void> _schedule() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null || !mounted) return;
    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).post<dynamic>(
        ApiPaths.platformNotificationCampaignSchedule(widget.resource.id),
        body: {'scheduled_at': scheduled.toUtc().toIso8601String()},
      );
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
      setState(() => _saving = false);
    }
  }
}

class _EmailTemplateEditor extends ConsumerStatefulWidget {
  const _EmailTemplateEditor({required this.resource, required this.canManage});

  final JsonResource resource;
  final bool canManage;

  @override
  ConsumerState<_EmailTemplateEditor> createState() =>
      _EmailTemplateEditorState();
}

class _EmailTemplateEditorState extends ConsumerState<_EmailTemplateEditor> {
  late final TextEditingController _subjectEn;
  late final TextEditingController _subjectAr;
  late final TextEditingController _headingEn;
  late final TextEditingController _headingAr;
  late final TextEditingController _introEn;
  late final TextEditingController _introAr;
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final effective = _mapOf(widget.resource.data['effective']);
    final subject = _mapOf(effective['subject']);
    final heading = _mapOf(effective['heading']);
    final intro = _mapOf(effective['intro']);
    _subjectEn = TextEditingController(text: '${subject['en'] ?? ''}');
    _subjectAr = TextEditingController(text: '${subject['ar'] ?? ''}');
    _headingEn = TextEditingController(text: '${heading['en'] ?? ''}');
    _headingAr = TextEditingController(text: '${heading['ar'] ?? ''}');
    _introEn = TextEditingController(text: '${intro['en'] ?? ''}');
    _introAr = TextEditingController(text: '${intro['ar'] ?? ''}');
    _enabled = widget.resource.flag('enabled');
  }

  @override
  void dispose() {
    for (final controller in [
      _subjectEn,
      _subjectAr,
      _headingEn,
      _headingAr,
      _introEn,
      _introAr,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canManage) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.resource.flag('optional'))
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.tr('enabled')),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
        _field(_subjectEn, context.tr('subjectEn')),
        _field(_subjectAr, context.tr('subjectAr')),
        _field(_headingEn, context.tr('headingEn')),
        _field(_headingAr, context.tr('headingAr')),
        _field(_introEn, context.tr('introEn'), lines: 3),
        _field(_introAr, context.tr('introAr'), lines: 3),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: context.tr('save'),
          expand: true,
          loading: _saving,
          onPressed: _save,
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(apiClientProvider).patch<dynamic>(
        ApiPaths.platformEmailTemplate(widget.resource.text('key')),
        body: {
          if (widget.resource.flag('optional')) 'enabled': _enabled,
          'subject': {'en': _subjectEn.text, 'ar': _subjectAr.text},
          'heading': {'en': _headingEn.text, 'ar': _headingAr.text},
          'intro': {'en': _introEn.text, 'ar': _introAr.text},
        },
      );
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

JsonMap _mapOf(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
