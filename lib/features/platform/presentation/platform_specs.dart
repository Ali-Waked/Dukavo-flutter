import 'package:flutter/material.dart';

import '../../../app/router/route_paths.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/resources/resource_spec.dart';
import 'platform_detail_sections.dart';

/// Shared select options for platform resources. Values are the enum values the
/// Laravel API validates against; labels are localization keys.
const tenantStatusOptions = <ResourceOption>[
  ResourceOption('active', 'active'),
  ResourceOption('suspended', 'suspended'),
];

const userStatusOptions = <ResourceOption>[
  ResourceOption('active', 'active'),
  ResourceOption('invited', 'invited'),
  ResourceOption('suspended', 'suspended'),
];

const roleScopeOptions = <ResourceOption>[
  ResourceOption('platform', 'platformScope'),
  ResourceOption('tenant', 'tenantScope'),
];

const waitlistStatusOptions = <ResourceOption>[
  ResourceOption('pending', 'pending'),
  ResourceOption('invited', 'invited'),
  ResourceOption('joined', 'joined'),
  ResourceOption('disqualified', 'disqualified'),
];

const contactStatusOptions = <ResourceOption>[
  ResourceOption('new', 'newStatus'),
  ResourceOption('read', 'read'),
  ResourceOption('replied', 'replied'),
  ResourceOption('closed', 'closed'),
];

const subscriberStatusOptions = <ResourceOption>[
  ResourceOption('subscribed', 'subscribed'),
  ResourceOption('unsubscribed', 'unsubscribed'),
];

const newsletterStatusOptions = <ResourceOption>[
  ResourceOption('draft', 'draft'),
  ResourceOption('published', 'published'),
];

const billingIntervalOptions = <ResourceOption>[
  ResourceOption('monthly', 'monthly'),
  ResourceOption('yearly', 'yearly'),
  ResourceOption('one_time', 'oneTime'),
];

String _userName(JsonResource resource) {
  final user = resource.map('user');
  if (user == null) return '—';
  return '${user['name'] ?? user['email'] ?? '—'}';
}

String _text(JsonResource resource, String key) =>
    resource.text(key).isEmpty ? '—' : resource.text(key);

final platformTenantSpec = ResourceSpec(
  titleKey: 'tenants',
  path: ApiPaths.platformTenants,
  icon: Icons.business_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: tenantStatusOptions,
    ),
    ResourceFieldSpec(key: 'contact_email', labelKey: 'contactEmail'),
    ResourceFieldSpec(key: 'phone', labelKey: 'phone'),
    ResourceFieldSpec(key: 'currency', labelKey: 'currency'),
    ResourceFieldSpec(key: 'timezone', labelKey: 'timezone'),
    ResourceFieldSpec(key: 'locale', labelKey: 'locale'),
    ResourceFieldSpec(
      key: 'stores_count',
      labelKey: 'storesCount',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
      key: 'users_count',
      labelKey: 'usersCount',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) => resource.text('slug'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.platformTenant(resource.id),
  canCreate: true,
  createPath: RoutePaths.platformCreateTenant,
  createLabelKey: 'createTenant',
  canEdit: true,
  editPath: (resource) => RoutePaths.platformTenantEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.platformTenants}/${resource.id}',
  extraDetail: (context, resource) =>
      PlatformTenantMembersSection(tenantId: resource.id),
  actions: [
    ResourceActionSpec(
      labelKey: 'suspendTenant',
      path: (resource) => ApiPaths.platformTenantSuspend(resource.id),
      confirmKey: 'suspendTenantMessage',
      icon: Icons.pause_circle_outline,
      destructive: true,
      visible: (resource) => resource.text('status') == 'active',
    ),
    ResourceActionSpec(
      labelKey: 'activateTenant',
      path: (resource) => ApiPaths.platformTenantActivate(resource.id),
      confirmKey: 'activateTenantMessage',
      icon: Icons.play_circle_outline,
      visible: (resource) => resource.text('status') != 'active',
    ),
  ],
  emptyIcon: Icons.business_outlined,
  emptyTitleKey: 'noTenants',
);

/// Fields accepted by `POST/PATCH /platform/tenants`.
///
/// `store_name` only applies on create and `status` only on update, but sending
/// the extra key is harmless: both requests validate the keys they know about
/// and ignore the rest. Keeping one spec means the create and edit forms cannot
/// drift apart.
final platformTenantFormSpec = ResourceSpec(
  titleKey: 'tenants',
  path: ApiPaths.platformTenants,
  icon: Icons.business_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name', required: true),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug', helperKey: 'slugHint'),
    ResourceFieldSpec(key: 'contact_email', labelKey: 'contactEmail'),
    ResourceFieldSpec(key: 'phone', labelKey: 'phone'),
    ResourceFieldSpec(
      key: 'currency',
      labelKey: 'currency',
      helperKey: 'currencyCodeHint',
    ),
    ResourceFieldSpec(
      key: 'timezone',
      labelKey: 'timezone',
      helperKey: 'timezoneHint',
    ),
    ResourceFieldSpec(
        key: 'locale', labelKey: 'locale', helperKey: 'localeHint'),
    ResourceFieldSpec(
      key: 'store_name',
      labelKey: 'firstStoreName',
      helperKey: 'firstStoreNameHint',
    ),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: tenantStatusOptions,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  createLabelKey: 'createTenant',
  canCreate: false,
);

final platformUserSpec = ResourceSpec(
  titleKey: 'platformUsers',
  path: ApiPaths.platformUsers,
  icon: Icons.admin_panel_settings_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'email', labelKey: 'email'),
    ResourceFieldSpec(key: 'phone', labelKey: 'phone'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: userStatusOptions,
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
  detailRoute: (resource) => RoutePaths.platformUser(resource.id),
  canCreate: true,
  createPath: RoutePaths.platformCreateUser,
  createLabelKey: 'createPlatformUser',
  canEdit: true,
  editPath: (resource) => RoutePaths.platformUserEdit(resource.id),
  extraDetail: (context, resource) =>
      PlatformUserRolesSection(resource: resource),
  emptyIcon: Icons.admin_panel_settings_outlined,
  emptyTitleKey: 'noPlatformUsers',
);

final platformRoleSpec = ResourceSpec(
  titleKey: 'platformRoles',
  path: ApiPaths.platformRoles,
  icon: Icons.verified_user_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug', showInForm: false),
    ResourceFieldSpec(
      key: 'scope',
      labelKey: 'scope',
      type: ResourceFieldType.select,
      options: roleScopeOptions,
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
  detailRoute: (resource) => RoutePaths.platformRole(resource.id),
  canCreate: true,
  createPath: RoutePaths.platformCreateRole,
  createLabelKey: 'createRole',
  canEdit: true,
  editPath: (resource) => RoutePaths.platformRoleEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.platformRoles}/${resource.id}',
  emptyIcon: Icons.verified_user_outlined,
  emptyTitleKey: 'noRoles',
);

final platformAuditSpec = ResourceSpec(
  titleKey: 'auditLog',
  path: ApiPaths.platformAuditLogs,
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
  subtitle: _userName,
  detailRoute: (resource) => RoutePaths.platformAuditEntry(resource.id),
  detailPath: (resource) => '${ApiPaths.platformAuditLogs}/${resource.id}',
  emptyIcon: Icons.history,
  emptyTitleKey: 'noAuditEntries',
);

final platformPricingSpec = ResourceSpec(
  titleKey: 'pricingPlans',
  path: ApiPaths.platformPricingPlans,
  icon: Icons.sell_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name'),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug'),
    ResourceFieldSpec(
      key: 'price',
      labelKey: 'price',
      type: ResourceFieldType.decimal,
      helperKey: 'priceComingSoonHint',
    ),
    ResourceFieldSpec(
      key: 'currency',
      labelKey: 'currency',
      required: true,
    ),
    ResourceFieldSpec(
      key: 'billing_interval',
      labelKey: 'billingInterval',
      type: ResourceFieldType.select,
      options: billingIntervalOptions,
      required: true,
      showInDetail: false,
    ),
    ResourceFieldSpec(
      key: 'billing_interval_label',
      labelKey: 'billingInterval',
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'features',
      labelKey: 'features',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'limits',
      labelKey: 'limits',
      type: ResourceFieldType.json,
    ),
    ResourceFieldSpec(
      key: 'highlighted',
      labelKey: 'highlighted',
      type: ResourceFieldType.boolean,
    ),
    ResourceFieldSpec(
      key: 'active',
      labelKey: 'active',
      type: ResourceFieldType.boolean,
    ),
    ResourceFieldSpec(
      key: 'sort_order',
      labelKey: 'sortOrder',
      type: ResourceFieldType.integer,
    ),
  ],
  title: (resource) => resource.text('name', fallback: '—'),
  subtitle: (resource) {
    final interval = resource.text('billing_interval_label');
    return interval.isEmpty ? null : interval;
  },
  status: (resource) => resource.flag('active') ? 'active' : 'inactive',
  detailRoute: (resource) => RoutePaths.platformPricingPlan(resource.id),
  canCreate: true,
  createPath: RoutePaths.platformCreatePricing,
  createLabelKey: 'createPlan',
  canEdit: true,
  editPath: (resource) => RoutePaths.platformPricingEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.platformPricingPlans}/${resource.id}',
  emptyIcon: Icons.sell_outlined,
  emptyTitleKey: 'noPricingPlans',
);

final platformFaqSpec = ResourceSpec(
  titleKey: 'faqEntries',
  path: ApiPaths.platformFaqEntries,
  icon: Icons.help_outline,
  fields: const [
    ResourceFieldSpec(key: 'question', labelKey: 'question'),
    ResourceFieldSpec(key: 'question_ar', labelKey: 'questionAr'),
    ResourceFieldSpec(
      key: 'answer',
      labelKey: 'answer',
      type: ResourceFieldType.multiline,
      maxLines: 5,
    ),
    ResourceFieldSpec(
      key: 'answer_ar',
      labelKey: 'answerAr',
      type: ResourceFieldType.multiline,
      maxLines: 5,
    ),
    ResourceFieldSpec(key: 'category', labelKey: 'category'),
    ResourceFieldSpec(
      key: 'sort_order',
      labelKey: 'sortOrder',
      type: ResourceFieldType.integer,
    ),
    ResourceFieldSpec(
      key: 'active',
      labelKey: 'active',
      type: ResourceFieldType.boolean,
    ),
  ],
  title: (resource) => resource.text('question', fallback: '—'),
  subtitle: (resource) => resource.text('category'),
  status: (resource) => resource.flag('active') ? 'active' : 'inactive',
  detailRoute: (resource) => RoutePaths.platformFaqEntry(resource.id),
  canCreate: true,
  createPath: RoutePaths.platformCreateFaq,
  createLabelKey: 'createFaqEntry',
  canEdit: true,
  editPath: (resource) => RoutePaths.platformFaqEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.platformFaqEntries}/${resource.id}',
  emptyIcon: Icons.help_outline,
  emptyTitleKey: 'noFaqEntries',
);

final platformContentPageSpec = ResourceSpec(
  titleKey: 'contentPages',
  path: ApiPaths.platformContentPages,
  icon: Icons.article_outlined,
  fields: const [
    ResourceFieldSpec(key: 'title', labelKey: 'title'),
    ResourceFieldSpec(key: 'key', labelKey: 'pageKey', showInForm: false),
    ResourceFieldSpec(key: 'locale', labelKey: 'locale', showInForm: false),
    ResourceFieldSpec(
      key: 'intro',
      labelKey: 'intro',
      type: ResourceFieldType.multiline,
      maxLines: 4,
    ),
    ResourceFieldSpec(
      key: 'sections',
      labelKey: 'sectionsJson',
      type: ResourceFieldType.json,
      helperKey: 'sectionsJsonHint',
      maxLines: 14,
    ),
    ResourceFieldSpec(key: 'meta_title', labelKey: 'metaTitle'),
    ResourceFieldSpec(key: 'meta_description', labelKey: 'metaDescription'),
    ResourceFieldSpec(
      key: 'active',
      labelKey: 'active',
      type: ResourceFieldType.boolean,
    ),
    ResourceFieldSpec(
      key: 'published_at',
      labelKey: 'publishedAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('title', fallback: '—'),
  subtitle: (resource) => resource.text('key'),
  status: (resource) => resource.flag('active') ? 'active' : 'inactive',
  detailRoute: (resource) => RoutePaths.platformContentPage(resource.id),
  canEdit: true,
  editPath: (resource) => RoutePaths.platformContentPageEdit(resource.id),
  emptyIcon: Icons.article_outlined,
  emptyTitleKey: 'noContentPages',
);

final platformWaitlistSpec = ResourceSpec(
  titleKey: 'waitlist',
  path: ApiPaths.platformWaitlist,
  icon: Icons.hourglass_empty,
  fields: const [
    ResourceFieldSpec(key: 'email', labelKey: 'email', showInForm: false),
    ResourceFieldSpec(key: 'name', labelKey: 'name', showInForm: false),
    ResourceFieldSpec(
      key: 'business_type',
      labelKey: 'businessType',
      showInForm: false,
    ),
    ResourceFieldSpec(key: 'source', labelKey: 'source', showInForm: false),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: waitlistStatusOptions,
      required: true,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('email', fallback: '—'),
  subtitle: (resource) => resource.text('name'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.platformWaitlistEntry(resource.id),
  canEdit: true,
  editPath: (resource) => RoutePaths.platformWaitlistEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.platformWaitlist}/${resource.id}',
  emptyIcon: Icons.hourglass_empty,
  emptyTitleKey: 'noWaitlistEntries',
);

final platformContactSpec = ResourceSpec(
  titleKey: 'contactMessages',
  path: ApiPaths.platformContactMessages,
  icon: Icons.mark_email_unread_outlined,
  fields: const [
    ResourceFieldSpec(key: 'name', labelKey: 'name', showInForm: false),
    ResourceFieldSpec(key: 'email', labelKey: 'email', showInForm: false),
    ResourceFieldSpec(key: 'subject', labelKey: 'subject', showInForm: false),
    ResourceFieldSpec(
      key: 'message',
      labelKey: 'message',
      type: ResourceFieldType.multiline,
      maxLines: 8,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: contactStatusOptions,
      required: true,
    ),
    ResourceFieldSpec(
      key: 'created_at',
      labelKey: 'createdAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
  ],
  title: (resource) => resource.text('subject', fallback: '—'),
  subtitle: (resource) => resource.text('email'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.platformContactMessage(resource.id),
  canEdit: true,
  editPath: (resource) => RoutePaths.platformContactEdit(resource.id),
  canDelete: true,
  deletePath: (resource) =>
      '${ApiPaths.platformContactMessages}/${resource.id}',
  emptyIcon: Icons.mark_email_unread_outlined,
  emptyTitleKey: 'noContactMessages',
);

final platformSubscriberSpec = ResourceSpec(
  titleKey: 'subscribers',
  path: ApiPaths.platformNewsletterSubscribers,
  icon: Icons.mark_email_read_outlined,
  fields: const [
    ResourceFieldSpec(key: 'email', labelKey: 'email', showInForm: false),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: subscriberStatusOptions,
      required: true,
    ),
    ResourceFieldSpec(key: 'source', labelKey: 'source', showInForm: false),
    ResourceFieldSpec(
      key: 'consented_at',
      labelKey: 'subscribedAt',
      type: ResourceFieldType.date,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'unsubscribed_at',
      labelKey: 'unsubscribedAt',
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
  title: (resource) => resource.text('email', fallback: '—'),
  subtitle: (resource) => resource.text('source'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.platformSubscriber(resource.id),
  canEdit: true,
  editPath: (resource) => RoutePaths.platformSubscriberEdit(resource.id),
  canDelete: true,
  deletePath: (resource) =>
      '${ApiPaths.platformNewsletterSubscribers}/${resource.id}',
  emptyIcon: Icons.mark_email_read_outlined,
  emptyTitleKey: 'noSubscribers',
);

final platformNewsletterSpec = ResourceSpec(
  titleKey: 'newsletters',
  path: ApiPaths.platformNewsletters,
  icon: Icons.newspaper_outlined,
  fields: const [
    ResourceFieldSpec(key: 'title', labelKey: 'title'),
    ResourceFieldSpec(key: 'title_ar', labelKey: 'titleAr'),
    ResourceFieldSpec(key: 'slug', labelKey: 'slug'),
    ResourceFieldSpec(
      key: 'excerpt',
      labelKey: 'excerpt',
      type: ResourceFieldType.multiline,
      maxLines: 3,
    ),
    ResourceFieldSpec(
      key: 'excerpt_ar',
      labelKey: 'excerptAr',
      type: ResourceFieldType.multiline,
      maxLines: 3,
    ),
    ResourceFieldSpec(
      key: 'body',
      labelKey: 'bodyHtml',
      type: ResourceFieldType.multiline,
      maxLines: 12,
      helperKey: 'bodyHtmlHint',
    ),
    ResourceFieldSpec(
      key: 'body_ar',
      labelKey: 'bodyHtmlAr',
      type: ResourceFieldType.multiline,
      maxLines: 12,
      helperKey: 'bodyHtmlHint',
    ),
    ResourceFieldSpec(key: 'meta_title', labelKey: 'metaTitle'),
    ResourceFieldSpec(key: 'meta_description', labelKey: 'metaDescription'),
    ResourceFieldSpec(
      key: 'status',
      labelKey: 'status',
      type: ResourceFieldType.select,
      options: newsletterStatusOptions,
    ),
    ResourceFieldSpec(
      key: 'reading_minutes',
      labelKey: 'readingMinutes',
      type: ResourceFieldType.integer,
      showInForm: false,
    ),
    ResourceFieldSpec(
      key: 'published_at',
      labelKey: 'publishedAt',
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
  subtitle: (resource) => resource.text('slug'),
  status: (resource) => resource.text('status'),
  detailRoute: (resource) => RoutePaths.platformNewsletter(resource.id),
  canCreate: true,
  createPath: RoutePaths.platformCreateNewsletter,
  createLabelKey: 'createNewsletter',
  canEdit: true,
  editPath: (resource) => RoutePaths.platformNewsletterEdit(resource.id),
  canDelete: true,
  deletePath: (resource) => '${ApiPaths.platformNewsletters}/${resource.id}',
  emptyIcon: Icons.newspaper_outlined,
  emptyTitleKey: 'noNewsletters',
);

/// Form-only specs that reuse the same field descriptions.
final platformFaqFormSpec = platformFaqSpec;
final platformNewsletterFormSpec = platformNewsletterSpec;

String displayOrDash(JsonResource resource, String key) => _text(resource, key);
