import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/resources/resource_spec.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';

const bundleStatusOptions = <ResourceOption>[
  ResourceOption('draft', 'draft'),
  ResourceOption('active', 'active'),
  ResourceOption('archived', 'archived'),
];

const bundleDiscountOptions = <ResourceOption>[
  ResourceOption('percentage', 'percentage'),
  ResourceOption('fixed', 'fixed'),
];

const whatsappStatusOptions = <ResourceOption>[
  ResourceOption('pending', 'pending'),
  ResourceOption('connected', 'connected'),
  ResourceOption('disconnected', 'disconnected'),
  ResourceOption('error', 'error'),
];

const automationStatusOptions = <ResourceOption>[
  ResourceOption('active', 'active'),
  ResourceOption('paused', 'paused'),
];

const automationTriggerOptions = <ResourceOption>[
  ResourceOption('order.created', 'triggerOrderCreated'),
  ResourceOption('order.status_changed', 'triggerOrderStatusChanged'),
  ResourceOption('inventory.low_stock', 'triggerInventoryLowStock'),
  ResourceOption(
    'conversation.message_received',
    'triggerConversationMessage',
  ),
  ResourceOption(
    'recovery.opportunity_detected',
    'triggerRecoveryDetected',
  ),
];

const automationTaskStatusOptions = <ResourceOption>[
  ResourceOption('open', 'open'),
  ResourceOption('completed', 'completed'),
  ResourceOption('dismissed', 'dismissed'),
];

const aiActionStatusOptions = <ResourceOption>[
  ResourceOption('draft', 'draft'),
  ResourceOption('pending_approval', 'pendingApproval'),
  ResourceOption('approved', 'approved'),
  ResourceOption('rejected', 'rejected'),
  ResourceOption('executed', 'executed'),
  ResourceOption('failed', 'failed'),
  ResourceOption('expired', 'expired'),
];

String _nestedName(JsonResource resource, String key) {
  final map = resource.map(key);
  if (map == null) return '—';
  return '${map['name'] ?? map['email'] ?? '—'}';
}

class UserRolesSection extends StatelessWidget {
  const UserRolesSection({super.key, required this.resource});

  final JsonResource resource;

  @override
  Widget build(BuildContext context) {
    final roles = resource.maps('roles');
    if (roles.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: context.tr('roles'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final role in roles)
            Chip(
              avatar: const Icon(Icons.verified_user_outlined, size: 16),
              label: Text('${role['name'] ?? role['slug'] ?? '—'}'),
            ),
        ],
      ),
    );
  }
}

final tenantUserSpec = ResourceSpec(
  titleKey: 'teamMembers',
  path: ApiPaths.users,
  icon: Icons.people_outline,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'email', labelKey: 'email'),
    ResourceFieldSpec(key: 'phone', labelKey: 'phone'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: [
        ResourceOption('active', 'active'),
        ResourceOption('invited', 'invited'),
        ResourceOption('suspended', 'suspended'),
      ],
    ),
    ResourceFieldSpec(
      key: 'last_login_at',
      labelKey: 'lastLogin',
      type: ResourceFieldType.date,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) => resource.text('email'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.userDetail(resource.id),
  canCreate: true,
  createPath: RoutePaths.createUser,
  createLabelKey: 'inviteTeamMember',
  canEdit: true,
  editPath: (resource) => RoutePaths.userEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.users}/${resource.id}',
  extraDetail: (context, resource) => UserRolesSection(resource: resource),
  emptyIcon: Icons.people_outline,
  emptyTitleKey: 'noTeamMembers',
);

final tenantRoleSpec = ResourceSpec(
  titleKey: 'roles',
  path: ApiPaths.roles,
  icon: Icons.verified_user_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug', showInForm: false),
    ResourceFieldSpec(
      key: 'scope',
      labelKey: 'scope',
      type: ResourceFieldType.select,
      options: [ResourceOption('tenant', 'tenantScope')],
      required: true,
    ),
    ResourceFieldSpec(key: 'description', labelKey: 'description'),
    ResourceFieldSpec(
      key: 'is_system',
      labelKey: 'system',
      type: ResourceFieldType.boolean,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) => resource.text('slug'),
  detailRoute: (resource) => RoutePaths.roleDetail(resource.id),
  canCreate: true,
  createPath: RoutePaths.createRole,
  createLabelKey: 'createRole',
  canEdit: true,
  editPath: (resource) => RoutePaths.roleEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.roles}/${resource.id}',
  emptyIcon: Icons.verified_user_outlined,
  emptyTitleKey: 'noRoles',
);

final tenantAuditSpec = ResourceSpec(
  titleKey: 'auditLog',
  path: ApiPaths.auditLogs,
  icon: Icons.history,
  searchable: false,
  fields: const [
    ResourceFieldSpec(key: 'action_label', labelKey: 'action'),
    ResourceFieldSpec(key: 'auditable_type', labelKey: 'resourceType'),
    ResourceFieldSpec(key: 'auditable_id', labelKey: 'reference'),
    ResourceFieldSpec(key: 'ip_address', labelKey: 'ipAddress'),
    ResourceFieldSpec(
      key: 'old_values',
      labelKey: 'oldValues',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'new_values',
      labelKey: 'newValues',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
    ),
  ],
  title: (resource) =>
      resource.text('action_label', fallback: resource.text('action')),
  subtitle: (resource) => _nestedName(resource, 'user'),
  detailRoute: (resource) => RoutePaths.auditEntry(resource.id),
  detailPath: (resource) => '${ApiPaths.auditLogs}/${resource.id}',
  emptyIcon: Icons.history,
  emptyTitleKey: 'noAuditEntries',
);

final bundleSpec = ResourceSpec(
  titleKey: 'bundles',
  path: ApiPaths.bundles,
  icon: Icons.inventory_2_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(
      key: 'description',
      labelKey: 'description',
      type: ResourceFieldType.multiline,
      maxLines: 4,
    ),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: bundleStatusOptions,
    ),
    ResourceFieldSpec(
      key: 'discount_type',
      labelKey: 'discountType',
      type: ResourceFieldType.select,
      options: bundleDiscountOptions,
    ),
    ResourceFieldSpec(
      key: 'discount_value',
      labelKey: 'discountValue',
      type: ResourceFieldType.decimal,
    ),
    ResourceFieldSpec(key: 'currency', labelKey: 'currency'),
    ResourceFieldSpec(
      key: 'store_id',
      labelKey: 'storeId',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
      key: 'items',
      labelKey: 'bundleItems',
      type: ResourceFieldType.json,
      helperKey: 'bundleItemsHint',
      maxLines: 12,
      required: true,
      showInDetail: false,
    ),
    ResourceFieldSpec(
      key: 'item_count',
      labelKey: 'itemCount',
      type: ResourceFieldType.integer,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) {
    final count = resource.number('item_count');
    final discount = resource.text('discount_type_label');
    return [
      if (count != null)
        '$count ${resource.text('item_count') == '1' ? 'item' : 'items'}',
      if (discount.isNotEmpty) discount,
    ].join(' · ');
  },
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.bundle(resource.id),
  canCreate: true,
  createPath: RoutePaths.createBundle,
  createLabelKey: 'createBundle',
  canEdit: true,
  editPath: (resource) => RoutePaths.bundleEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.bundles}/${resource.id}',
  emptyIcon: Icons.inventory_2_outlined,
  emptyTitleKey: 'noBundles',
);

final whatsappSpec = ResourceSpec(
  titleKey: 'whatsappAccounts',
  path: ApiPaths.whatsappAccounts,
  icon: Icons.chat_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(
      key: 'store_id',
      labelKey: 'storeId',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(key: 'phone_number_id', labelKey: 'phoneNumberId'),
    ResourceFieldSpec(
      key: 'business_account_id',
      labelKey: 'businessAccountId',
    ),
    ResourceFieldSpec(
      key: 'access_token',
      labelKey: 'accessToken',
      type: ResourceFieldType.password,
      showInDetail: false,
      helperKey: 'accessTokenHint',
    ),
    ResourceFieldSpec(
      key: 'webhook_verify_token',
      labelKey: 'webhookVerifyToken',
      helperKey: 'webhookVerifyTokenHint',
    ),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: whatsappStatusOptions,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'error_message',
      labelKey: 'errorMessage',
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'connected_at',
      labelKey: 'connectedAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) => resource.text('phone_number_id'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.whatsappAccount(resource.id),
  canCreate: true,
  createPath: RoutePaths.createWhatsapp,
  createLabelKey: 'connectWhatsapp',
  canEdit: true,
  editPath: (resource) => RoutePaths.whatsappEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.whatsappAccounts}/${resource.id}',
  actions: [
    ResourceActionSpec(
      labelKey: 'verifyAccount',
      path: (resource) => ApiPaths.whatsappVerify(resource.id),
      confirmKey: 'verifyAccountMessage',
      icon: Icons.verified_outlined,
      visible: (resource) => resource.text('status') != 'connected',
    ),
    ResourceActionSpec(
      labelKey: 'disconnectAccount',
      path: (resource) => ApiPaths.whatsappDisconnect(resource.id),
      confirmKey: 'disconnectAccountMessage',
      icon: Icons.link_off,
      destructive: true,
      visible: (resource) => resource.text('status') == 'connected',
    ),
  ],
  emptyIcon: Icons.chat_outlined,
  emptyTitleKey: 'noWhatsappAccounts',
);

final aiActionSpec = ResourceSpec(
  titleKey: 'aiActions',
  path: ApiPaths.aiActions,
  icon: Icons.auto_awesome_outlined,
  fields: const [
    ResourceFieldSpec(key: 'action_type', labelKey: 'actionType'),
    ResourceFieldSpec(key: 'classification_label', labelKey: 'classification'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: aiActionStatusOptions,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'summary',
      labelKey: 'summary',
      type: ResourceFieldType.multiline,
      maxLines: 4,
    ),
    ResourceFieldSpec(
      key: 'resolved_payload',
      labelKey: 'payload',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'result',
      labelKey: 'result',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'rejection_reason',
      labelKey: 'rejectionReason',
    ),
    ResourceFieldSpec(key: 'error', labelKey: 'errorMessage'),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
    ),
  ],
  title: (resource) =>
      resource.text('summary', fallback: resource.text('action_type')),
  subtitle: (resource) => resource.text('action_type'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.aiAction(resource.id),
  actions: [
    ResourceActionSpec(
      labelKey: 'submitForApproval',
      path: (resource) => ApiPaths.aiActionSubmit(resource.id),
      confirmKey: 'submitForApprovalMessage',
      icon: Icons.send_outlined,
      visible: (resource) => resource.text('status') == 'draft',
    ),
    ResourceActionSpec(
      labelKey: 'approve',
      path: (resource) => ApiPaths.aiActionApprove(resource.id),
      confirmKey: 'approveAiActionMessage',
      icon: Icons.check_circle_outline,
      visible: (resource) => resource.text('status') == 'pending_approval',
    ),
    ResourceActionSpec(
      labelKey: 'reject',
      path: (resource) => ApiPaths.aiActionReject(resource.id),
      body: (resource) => const {'reason': 'Rejected from the mobile console.'},
      confirmKey: 'rejectAiActionMessage',
      icon: Icons.cancel_outlined,
      destructive: true,
      visible: (resource) => resource.text('status') == 'pending_approval',
    ),
    ResourceActionSpec(
      labelKey: 'execute',
      path: (resource) => ApiPaths.aiActionExecute(resource.id),
      body: (resource) => const {'confirmed': true},
      confirmKey: 'executeAiActionMessage',
      icon: Icons.play_circle_outline,
      visible: (resource) => resource.text('status') == 'approved',
    ),
  ],
  emptyIcon: Icons.auto_awesome_outlined,
  emptyTitleKey: 'noAiActions',
);

final automationRuleSpec = ResourceSpec(
  titleKey: 'automationRules',
  path: ApiPaths.automationRules,
  icon: Icons.bolt_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(
      key: 'description',
      labelKey: 'description',
      type: ResourceFieldType.multiline,
      maxLines: 4,
    ),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: automationStatusOptions,
    ),
    ResourceFieldSpec(
      key: 'trigger',
      labelKey: 'trigger',
      type: ResourceFieldType.select,
      options: automationTriggerOptions,
      required: true,
    ),
    ResourceFieldSpec(
      key: 'store_id',
      labelKey: 'storeId',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
      key: 'cooldown_seconds',
      labelKey: 'cooldownSeconds',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
      key: 'conditions',
      labelKey: 'conditions',
      type: ResourceFieldType.json,
      helperKey: 'conditionsHint',
      maxLines: 10,
    ),
    ResourceFieldSpec(
      key: 'actions',
      labelKey: 'actions',
      type: ResourceFieldType.json,
      helperKey: 'automationActionsHint',
      maxLines: 10,
      required: true,
    ),
    ResourceFieldSpec(
      key: 'run_count',
      labelKey: 'runCount',
      type: ResourceFieldType.integer,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'last_triggered_at',
      labelKey: 'lastTriggered',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) => resource.text('trigger_label'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.automationRule(resource.id),
  canCreate: true,
  createPath: RoutePaths.createAutomation,
  createLabelKey: 'createAutomation',
  canEdit: true,
  editPath: (resource) => RoutePaths.automationEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.automationRules}/${resource.id}',
  emptyIcon: Icons.bolt_outlined,
  emptyTitleKey: 'noAutomationRules',
);

final automationRunSpec = ResourceSpec(
  titleKey: 'automationRuns',
  path: ApiPaths.automationRuns,
  icon: Icons.play_circle_outline,
  searchable: false,
  fields: const [
    ResourceFieldSpec(key: 'trigger_label', labelKey: 'trigger'),
    ResourceFieldSpec(key: 'event_key', labelKey: 'event'),
    ResourceFieldSpec(key: 'status_label', labelKey: 'status'),
    ResourceFieldSpec(
      key: 'matched',
      labelKey: 'matched',
      type: ResourceFieldType.boolean,
    ),
    ResourceFieldSpec(
      key: 'context',
      labelKey: 'context',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'actions',
      labelKey: 'actions',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(key: 'error', labelKey: 'errorMessage'),
    ResourceFieldSpec(
      key: 'started_at',
      labelKey: 'startedAt',
      type: ResourceFieldType.date,
    ),
    ResourceFieldSpec(
      key: 'finished_at',
      labelKey: 'finishedAt',
      type: ResourceFieldType.date,
    ),
  ],
  title: (resource) =>
      resource.text('event_key', fallback: resource.text('trigger_label')),
  subtitle: (resource) => _nestedName(resource, 'rule'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.automationRun(resource.id),
  emptyIcon: Icons.play_circle_outline,
  emptyTitleKey: 'noAutomationRuns',
);

final automationTaskSpec = ResourceSpec(
  titleKey: 'automationTasks',
  path: ApiPaths.automationTasks,
  icon: Icons.task_alt_outlined,
  fields: const [
    ResourceFieldSpec(key: 'title', labelKey: 'title'),
    ResourceFieldSpec(
      key: 'description',
      labelKey: 'description',
      type: ResourceFieldType.multiline,
      maxLines: 4,
    ),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: automationTaskStatusOptions,
    ),
    ResourceFieldSpec(
      key: 'priority',
      labelKey: 'priority',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
        key: 'due_at', labelKey: 'dueAt', type: ResourceFieldType.date),
    ResourceFieldSpec(
      key: 'completed_at',
      labelKey: 'completedAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('title', fallback: '—'),
  subtitle: (resource) => _nestedName(resource, 'rule'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.automationTask(resource.id),
  actions: [
    ResourceActionSpec(
      labelKey: 'markCompleted',
      path: (resource) => '${ApiPaths.automationTasks}/${resource.id}',
      method: 'PATCH',
      body: (resource) => const {'status': 'completed'},
      confirmKey: 'markCompletedMessage',
      icon: Icons.check_circle_outline,
      visible: (resource) => resource.text('status') == 'open',
    ),
    ResourceActionSpec(
      labelKey: 'dismiss',
      path: (resource) => '${ApiPaths.automationTasks}/${resource.id}',
      method: 'PATCH',
      body: (resource) => const {'status': 'dismissed'},
      confirmKey: 'dismissTaskMessage',
      icon: Icons.remove_circle_outline,
      destructive: true,
      visible: (resource) => resource.text('status') == 'open',
    ),
  ],
  emptyIcon: Icons.task_alt_outlined,
  emptyTitleKey: 'noAutomationTasks',
);

final recoverySpec = ResourceSpec(
  titleKey: 'recoveryOpportunities',
  path: ApiPaths.recoveryOpportunities,
  icon: Icons.replay_outlined,
  filters: const [
    ResourceFilterSpec(
      param: 'status',
      labelKey: 'status',
      options: [
        ResourceOption('open', 'open'),
        ResourceOption('eligible', 'readyToRecover'),
        ResourceOption('contacted', 'followUpSent'),
        ResourceOption('snoozed', 'snoozed'),
        ResourceOption('recovered', 'recovered'),
        ResourceOption('dismissed', 'dismissed'),
        ResourceOption('expired', 'expired'),
      ],
    ),
  ],
  fields: const [
    ResourceFieldSpec(key: 'reason_label', labelKey: 'reason'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: [
        ResourceOption('eligible', 'readyToRecover'),
        ResourceOption('contacted', 'followUpSent'),
        ResourceOption('snoozed', 'snoozed'),
        ResourceOption('recovered', 'recovered'),
        ResourceOption('dismissed', 'dismissed'),
        ResourceOption('expired', 'expired'),
      ],
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'estimated_value',
      labelKey: 'estimatedValue',
      type: ResourceFieldType.decimal,
      showInForm: false,
    ),
    ResourceFieldSpec(key: 'currency', labelKey: 'currency', showInForm: false),
    ResourceFieldSpec(
      key: 'recovered_value',
      labelKey: 'recoveredValue',
      type: ResourceFieldType.decimal,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'contact_attempts',
      labelKey: 'contactAttempts',
      type: ResourceFieldType.integer,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'detected_at',
      labelKey: 'detectedAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'last_contacted_at',
      labelKey: 'lastContactedAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'next_follow_up_at',
      labelKey: 'nextFollowUpAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'dismissal_reason',
      labelKey: 'dismissalReason',
      showInForm: false,
    ),
  ],
  title: (resource) {
    final customer = resource.map('customer');
    return '${customer?['name'] ?? resource.text('reason_label', fallback: '—')}';
  },
  subtitle: (resource) {
    final value = resource.number('estimated_value');
    final currency = resource.text('currency');
    if (value == null) return resource.text('reason_label');
    return Formatters.currency(value, currency);
  },
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.recoveryDetail(resource.id),
  actions: [
    ResourceActionSpec(
      labelKey: 'draftMessage',
      path: (resource) => ApiPaths.recoveryAiDraft(resource.id),
      confirmKey: 'draftMessageMessage',
      icon: Icons.auto_awesome_outlined,
      visible: (resource) => resource.text('status') != 'recovered',
    ),
    ResourceActionSpec(
      labelKey: 'dismiss',
      path: (resource) => ApiPaths.recoveryDismiss(resource.id),
      body: (resource) =>
          const {'reason': 'Dismissed from the mobile console.'},
      confirmKey: 'dismissRecoveryMessage',
      icon: Icons.remove_circle_outline,
      destructive: true,
      visible: (resource) => resource.text('status') != 'dismissed',
    ),
    ResourceActionSpec(
      labelKey: 'doNotContact',
      path: (resource) => ApiPaths.recoveryDoNotContact(resource.id),
      body: (resource) =>
          const {'reason': 'Customer asked not to be contacted.'},
      confirmKey: 'doNotContactMessage',
      icon: Icons.block,
      destructive: true,
      visible: (resource) => resource.text('status') != 'recovered',
    ),
  ],
  emptyIcon: Icons.replay_outlined,
  emptyTitleKey: 'noRecoveryOpportunities',
);

final storeSpec = ResourceSpec(
  titleKey: 'stores',
  path: ApiPaths.stores,
  icon: Icons.store_mall_directory_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: [
        ResourceOption('active', 'active'),
        ResourceOption('inactive', 'inactive'),
      ],
    ),
    ResourceFieldSpec(key: 'email', labelKey: 'email'),
    ResourceFieldSpec(key: 'phone', labelKey: 'phone'),
    ResourceFieldSpec(key: 'currency', labelKey: 'currency'),
    ResourceFieldSpec(key: 'timezone', labelKey: 'timezone'),
    ResourceFieldSpec(
      key: 'is_default',
      labelKey: 'defaultStore',
      type: ResourceFieldType.boolean,
    ),
    ResourceFieldSpec(
      key: 'products_count',
      labelKey: 'productsCount',
      type: ResourceFieldType.integer,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) => resource.text('slug'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.storeDetail(resource.id),
  canCreate: true,
  createPath: RoutePaths.createStore,
  createLabelKey: 'createStore',
  canEdit: true,
  editPath: (resource) => RoutePaths.storeEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.stores}/${resource.id}',
  actions: [
    ResourceActionSpec(
      labelKey: 'makeDefault',
      path: (resource) => '${ApiPaths.stores}/${resource.id}/default',
      confirmKey: 'makeDefaultMessage',
      icon: Icons.star_outline,
      visible: (resource) => !resource.flag('is_default'),
    ),
  ],
  extraDetail: (context, resource) => Card(
    child: ListTile(
      leading: const Icon(Icons.currency_exchange),
      title: Text(context.tr('storeCurrency')),
      subtitle: Text(context.tr('storeCurrencyHelp')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(RoutePaths.storeCurrency(resource.id)),
    ),
  ),
  emptyIcon: Icons.store_mall_directory_outlined,
  emptyTitleKey: 'noStores',
);
