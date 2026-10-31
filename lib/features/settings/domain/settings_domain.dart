/// The active workspace's editable settings, from `TenantResource`.
class WorkspaceSettings {
  const WorkspaceSettings({
    required this.id,
    required this.name,
    required this.slug,
    required this.currency,
    required this.timezone,
    this.contactEmail,
    this.phone,
    this.locale,
  });

  final int id;
  final String name;
  final String slug;
  final String currency;
  final String timezone;
  final String? contactEmail;
  final String? phone;
  final String? locale;
}

class WorkspaceSettingsDraft {
  const WorkspaceSettingsDraft({
    this.name,
    this.contactEmail,
    this.phone,
    this.currency,
    this.timezone,
    this.locale,
  });

  final String? name;
  final String? contactEmail;
  final String? phone;
  final String? currency;
  final String? timezone;
  final String? locale;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (contactEmail != null) 'contact_email': contactEmail,
        if (phone != null) 'phone': phone,
        if (currency != null) 'currency': currency,
        if (timezone != null) 'timezone': timezone,
        if (locale != null) 'locale': locale,
      };
}

abstract class SettingsRepository {
  Future<WorkspaceSettings> get();

  Future<WorkspaceSettings> update(WorkspaceSettingsDraft draft);
}
