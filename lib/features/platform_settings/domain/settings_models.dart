/// Platform configuration, mirrored from the settings API.
///
/// A read returns the definition of every setting so the form can pick the
/// right control and show where the effective value came from. Secrets never
/// arrive: only [SettingDefinition.configured] and a last-four hint.
library;

class SettingsPermissions {
  const SettingsPermissions({
    this.view = false,
    this.update = false,
    this.secrets = false,
    this.test = false,
    this.security = false,
    this.features = false,
  });

  final bool view;
  final bool update;
  final bool secrets;
  final bool test;
  final bool security;
  final bool features;

  bool get canReadAny => view || security || features;

  factory SettingsPermissions.fromJson(Map<String, dynamic> json) {
    bool read(String key) => json[key] == true;

    return SettingsPermissions(
      view: read('view'),
      update: read('update'),
      secrets: read('secrets'),
      test: read('test'),
      security: read('security'),
      features: read('features'),
    );
  }
}

class SettingDefinition {
  const SettingDefinition({
    required this.key,
    required this.field,
    required this.category,
    required this.group,
    required this.type,
    required this.label,
    required this.labelAr,
    required this.description,
    required this.descriptionAr,
    required this.value,
    required this.source,
    required this.sourceLabel,
    required this.configured,
    required this.editable,
    required this.isSecret,
    required this.secretHint,
    required this.requiresRestart,
    required this.options,
    required this.min,
    required this.max,
    required this.maxLength,
    required this.defaultValue,
    required this.envKey,
  });

  final String key;
  final String field;
  final String category;
  final String group;
  final String type;
  final String label;
  final String labelAr;
  final String description;
  final String descriptionAr;
  final Object? value;
  final String source;
  final String sourceLabel;
  final bool configured;
  final bool editable;
  final bool isSecret;
  final String? secretHint;
  final bool requiresRestart;
  final List<String> options;
  final num? min;
  final num? max;
  final int? maxLength;
  final Object? defaultValue;
  final String? envKey;

  bool get isBoolean => type == 'boolean';
  bool get isInteger => type == 'integer';
  bool get isDecimal => type == 'decimal';
  bool get isMultiSelect => type == 'multi_select';
  bool get isSelect => type == 'select';
  bool get isText => type == 'text';
  bool get fromDatabase => source == 'database';

  String labelFor(bool arabic) => arabic && labelAr.isNotEmpty ? labelAr : label;
  String descriptionFor(bool arabic) =>
      arabic && descriptionAr.isNotEmpty ? descriptionAr : description;

  factory SettingDefinition.fromJson(Map<String, dynamic> json) {
    return SettingDefinition(
      key: _string(json['key']),
      field: _string(json['field']),
      category: _string(json['category']),
      group: _string(json['group']),
      type: _string(json['type'], fallback: 'string'),
      label: _string(json['label']),
      labelAr: _string(json['label_ar']),
      description: _string(json['description']),
      descriptionAr: _string(json['description_ar']),
      value: json['value'],
      source: _string(json['source'], fallback: 'default'),
      sourceLabel: _string(json['source_label']),
      configured: json['configured'] == true,
      editable: json['editable'] == true,
      isSecret: json['is_secret'] == true || json['type'] == 'secret',
      secretHint: _nullableString(json['secret_hint']),
      requiresRestart: json['requires_restart'] == true,
      options: _stringList(json['options']),
      min: _num(json['min']),
      max: _num(json['max']),
      maxLength: _intOrNull(json['max_length']),
      defaultValue: json['default'],
      envKey: _nullableString(json['env_key']),
    );
  }
}

class SettingsCategory {
  const SettingsCategory({
    required this.key,
    required this.label,
    required this.labelAr,
    required this.holdsSecrets,
    required this.settings,
  });

  final String key;
  final String label;
  final String labelAr;
  final bool holdsSecrets;
  final List<SettingDefinition> settings;

  String labelFor(bool arabic) => arabic && labelAr.isNotEmpty ? labelAr : label;

  int get overrideCount => settings.where((setting) => setting.fromDatabase).length;

  int get secretCount =>
      settings.where((setting) => setting.isSecret && setting.configured).length;

  factory SettingsCategory.fromJson(Map<String, dynamic> json) {
    final rawSettings = json['settings'];

    return SettingsCategory(
      key: _string(json['category']),
      label: _string(json['label']),
      labelAr: _string(json['label_ar']),
      holdsSecrets: json['holds_secrets'] == true,
      settings: rawSettings is List
          ? rawSettings
              .whereType<Map>()
              .map((entry) =>
                  SettingDefinition.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <SettingDefinition>[],
    );
  }
}

class SettingsCatalogue {
  const SettingsCatalogue({
    required this.categories,
    required this.permissions,
  });

  final List<SettingsCategory> categories;
  final SettingsPermissions permissions;

  SettingsCategory? category(String key) {
    for (final category in categories) {
      if (category.key == key) return category;
    }
    return null;
  }

  factory SettingsCatalogue.fromJson(Map<String, dynamic> json) {
    final raw = json['categories'];

    return SettingsCatalogue(
      categories: raw is List
          ? raw
              .whereType<Map>()
              .map((entry) =>
                  SettingsCategory.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
          : const <SettingsCategory>[],
      permissions: SettingsPermissions.fromJson(_asMap(json['permissions'])),
    );
  }
}

class SettingsSection {
  const SettingsSection({
    required this.category,
    required this.permissions,
  });

  final SettingsCategory category;
  final SettingsPermissions permissions;

  factory SettingsSection.fromJson(Map<String, dynamic> json) {
    return SettingsSection(
      category: SettingsCategory.fromJson(_asMap(json['category'])),
      permissions: SettingsPermissions.fromJson(_asMap(json['permissions'])),
    );
  }
}

class PlatformFeatureFlag {
  const PlatformFeatureFlag({
    required this.key,
    required this.label,
    required this.labelAr,
    required this.description,
    required this.descriptionAr,
    required this.group,
    required this.enabled,
    required this.defaultValue,
    required this.source,
  });

  final String key;
  final String label;
  final String labelAr;
  final String description;
  final String descriptionAr;
  final String group;
  final bool enabled;
  final bool defaultValue;
  final String source;

  String labelFor(bool arabic) => arabic && labelAr.isNotEmpty ? labelAr : label;
  String descriptionFor(bool arabic) =>
      arabic && descriptionAr.isNotEmpty ? descriptionAr : description;

  factory PlatformFeatureFlag.fromJson(Map<String, dynamic> json) {
    return PlatformFeatureFlag(
      key: _string(json['key']),
      label: _string(json['label']),
      labelAr: _string(json['label_ar']),
      description: _string(json['description']),
      descriptionAr: _string(json['description_ar']),
      group: _string(json['group'], fallback: 'operations'),
      enabled: json['enabled'] == true,
      defaultValue: json['default'] == true,
      source: _string(json['source'], fallback: 'default'),
    );
  }
}

class IntegrationHealth {
  const IntegrationHealth({
    required this.key,
    required this.label,
    required this.labelAr,
    required this.flag,
    required this.state,
    required this.tone,
    required this.summary,
    required this.checkedAt,
  });

  final String key;
  final String label;
  final String labelAr;
  final String? flag;
  final String state;
  final String tone;
  final String? summary;
  final String? checkedAt;

  String labelFor(bool arabic) => arabic && labelAr.isNotEmpty ? labelAr : label;

  factory IntegrationHealth.fromJson(Map<String, dynamic> json) {
    return IntegrationHealth(
      key: _string(json['key']),
      label: _string(json['label']),
      labelAr: _string(json['label_ar']),
      flag: _nullableString(json['flag']),
      state: _string(json['state'], fallback: 'not_tested'),
      tone: _string(json['tone'], fallback: 'neutral'),
      summary: _nullableString(json['summary']),
      checkedAt: _nullableString(json['checked_at']),
    );
  }
}

class SettingsHistoryEntry {
  const SettingsHistoryEntry({
    required this.id,
    required this.action,
    required this.actionLabel,
    required this.key,
    required this.oldValue,
    required this.newValue,
    required this.actorName,
    required this.createdAt,
  });

  final int id;
  final String action;
  final String actionLabel;
  final String? key;
  final SettingAuditValue? oldValue;
  final SettingAuditValue? newValue;
  final String? actorName;
  final String? createdAt;

  factory SettingsHistoryEntry.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];

    return SettingsHistoryEntry(
      id: _intOrNull(json['id']) ?? 0,
      action: _string(json['action']),
      actionLabel: _string(json['action_label']),
      key: _nullableString(json['key']),
      oldValue: SettingAuditValue.fromPayload(json['old_values'], 'old'),
      newValue: SettingAuditValue.fromPayload(json['new_values'], 'new'),
      actorName:
          actor is Map ? _nullableString(actor['name']) : null,
      createdAt: _nullableString(json['created_at']),
    );
  }
}

/// The redacted shape of one side of a change.
///
/// A secret arrives as `{ value: null, configured: true, secret_hint: '••••1234' }`,
/// so the history can describe a change without ever carrying the credential.
class SettingAuditValue {
  const SettingAuditValue({
    required this.value,
    required this.configured,
    required this.secretHint,
  });

  final Object? value;
  final bool configured;
  final String? secretHint;

  bool get isSecretHint => value == null && secretHint != null;

  factory SettingAuditValue.fromPayload(Object? payload, String key) {
    final side = payload is Map ? payload[key] : null;
    final map = side is Map ? Map<String, dynamic>.from(side) : null;

    return SettingAuditValue(
      value: map?['value'],
      configured: map?['configured'] == true,
      secretHint: _nullableString(map?['secret_hint']),
    );
  }
}

class PlatformSystemSummary {
  const PlatformSystemSummary({
    required this.environment,
    required this.phpVersion,
    required this.laravelVersion,
    required this.timezone,
    required this.database,
    required this.cache,
    required this.queue,
    required this.session,
    required this.mailer,
    required this.filesystem,
    required this.maintenanceEnabled,
    required this.maintenanceMessage,
    required this.retryAfterSeconds,
    required this.categories,
    required this.definitions,
    required this.overrides,
    required this.secretOverrides,
  });

  final String environment;
  final String phpVersion;
  final String laravelVersion;
  final String timezone;
  final String database;
  final String cache;
  final String queue;
  final String session;
  final String mailer;
  final String filesystem;
  final bool maintenanceEnabled;
  final String maintenanceMessage;
  final int retryAfterSeconds;
  final int categories;
  final int definitions;
  final int overrides;
  final int secretOverrides;

  factory PlatformSystemSummary.fromJson(Map<String, dynamic> json) {
    final maintenance = _asMap(json['maintenance']);
    final configuration = _asMap(json['configuration']);

    return PlatformSystemSummary(
      environment: _string(json['environment'], fallback: '—'),
      phpVersion: _string(json['php_version'], fallback: '—'),
      laravelVersion: _string(json['laravel_version'], fallback: '—'),
      timezone: _string(json['timezone'], fallback: '—'),
      database: _string(json['database'], fallback: '—'),
      cache: _string(json['cache'], fallback: '—'),
      queue: _string(json['queue'], fallback: '—'),
      session: _string(json['session'], fallback: '—'),
      mailer: _string(json['mailer'], fallback: '—'),
      filesystem: _string(json['filesystem'], fallback: '—'),
      maintenanceEnabled: maintenance['enabled'] == true,
      maintenanceMessage: _string(maintenance['message']),
      retryAfterSeconds: _intOrNull(maintenance['retry_after_seconds']) ?? 0,
      categories: _intOrNull(configuration['categories']) ?? 0,
      definitions: _intOrNull(configuration['definitions']) ?? 0,
      overrides: _intOrNull(configuration['overrides']) ?? 0,
      secretOverrides: _intOrNull(configuration['secret_overrides']) ?? 0,
    );
  }
}

/* ------------------------------------------------------------------ helpers */

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

String _string(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = '$value';
  return text.isEmpty ? null : text;
}

List<String> _stringList(Object? value) {
  if (value is List) return value.map((entry) => '$entry').toList();
  return const <String>[];
}

num? _num(Object? value) {
  if (value is num) return value;
  return num.tryParse('$value');
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}
