import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../domain/profile_domain.dart';

/* ------------------------------------------------------------------ parsing */

Map<String, dynamic> _map(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

int _int(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

String? _string(Object? value) {
  if (value is String) return value.isEmpty ? null : value;
  return null;
}

List<String> _strings(Object? value) {
  if (value is List) {
    return value.map((entry) => '$entry').toList(growable: false);
  }
  return const <String>[];
}

SourcedValue<T> _sourced<T>(
  Object? raw,
  T? Function(Map<String, dynamic> json) read,
) {
  final json = _map(raw);
  if (json.isEmpty) return const SourcedValue();
  return SourcedValue<T>(
    value: read(json),
    source: PreferenceSource.parse(_string(json['source'])),
    confidence: _int(json['confidence']),
  );
}

CountryOption _country(Map<String, dynamic> json) {
  final iso2 = '${json['iso2'] ?? ''}';
  return CountryOption(
    iso2: iso2,
    name: '${json['name'] ?? json['name_en'] ?? iso2}',
    nameEn: '${json['name_en'] ?? json['name'] ?? iso2}',
    nameAr: '${json['name_ar'] ?? json['name_en'] ?? iso2}',
    native: '${json['native'] ?? json['name_en'] ?? iso2}',
    dialCode: '${json['dial_code'] ?? ''}',
    currency: '${json['currency'] ?? ''}',
    flag: '${json['flag'] ?? ''}',
  );
}

ProfileCompletion _completion(Object? raw) {
  final json = _map(raw);
  return ProfileCompletion(
    percentage: _int(json['percentage']),
    completed: _strings(json['completed']),
    missing: _strings(json['missing']),
  );
}

TwoFactorStatus _twoFactor(Object? raw) {
  final json = _map(raw);
  return TwoFactorStatus(
    enabled: json['enabled'] == true,
    pending: json['pending'] == true,
    confirmedAt: _string(json['confirmed_at']),
    recoveryCodesCount: _int(json['recovery_codes_count']),
  );
}

ProfileSession _session(Map<String, dynamic> json) {
  return ProfileSession(
    id: _int(json['id']),
    name: '${json['name'] ?? json['device'] ?? ''}',
    device: '${json['device'] ?? json['name'] ?? ''}',
    browser: '${json['browser'] ?? ''}',
    platform: '${json['platform'] ?? ''}',
    deviceType: '${json['device_type'] ?? ''}',
    isCurrent: json['is_current'] == true,
    ipAddress: _string(json['ip_address']),
    countryCode: _string(json['country_code']),
    countryName: _string(json['country_name']),
    firstLoginAt: _string(json['first_login_at']),
    lastUsedAt: _string(json['last_used_at']),
    lastActivityAt: _string(json['last_activity_at']),
    expiresAt: _string(json['expires_at']),
    createdAt: _string(json['created_at']),
  );
}

SecurityEvent _event(Map<String, dynamic> json) {
  return SecurityEvent(
    id: _int(json['id']),
    event: '${json['event'] ?? ''}',
    label: '${json['label'] ?? json['event'] ?? ''}',
    category: '${json['category'] ?? 'account'}',
    status: '${json['status'] ?? 'success'}',
    ipAddress: _string(json['ip_address']),
    device: _string(json['device']),
    countryCode: _string(json['country_code']),
    createdAt: _string(json['created_at']),
  );
}

/* ------------------------------------------------------------------- models */

class ProfileModel {
  const ProfileModel._();

  static UserProfile fromJson(Map<String, dynamic> json) {
    final location = _map(json['location']);
    final display = _map(json['display']);
    final countryRaw = location['country'];

    return UserProfile(
      id: _int(json['id']),
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      bio: _string(json['bio']),
      phone: _string(json['phone']),
      phoneCountryCode: _string(json['phone_country_code']),
      phoneVerifiedAt: _string(json['phone_verified_at']),
      locale: _string(json['locale']),
      theme: '${display['theme'] ?? json['theme'] ?? 'system'}',
      dateFormat: '${display['date_format'] ?? 'DD/MM/YYYY'}',
      timeFormat: '${display['time_format'] ?? '24h'}',
      countryCode: _string(location['country_code']),
      city: _string(location['city']),
      timezone: _string(location['timezone']),
      preferredCurrency: '${json['preferred_currency'] ?? 'USD'}',
      preferredCurrencyName: '${json['preferred_currency_name'] ?? ''}',
      preferredCurrencyNameEn: '${json['preferred_currency_name_en'] ?? ''}',
      preferredCurrencyNameAr: '${json['preferred_currency_name_ar'] ?? ''}',
      preferredCurrencySymbol: '${json['preferred_currency_symbol'] ?? ''}',
      preferredCurrencyDecimals:
          _int(json['preferred_currency_decimals'], fallback: 2),
      status: '${json['status'] ?? 'active'}',
      avatarUrl: _string(json['avatar_url']),
      emailVerifiedAt: _string(json['email_verified_at']),
      lastLoginAt: _string(json['last_login_at']),
      passwordChangedAt: _string(json['password_changed_at']),
      createdAt: _string(json['created_at']),
      preferencesInitializedAt: _string(json['preferences_initialized_at']),
      twoFactor: _twoFactor(json['two_factor']),
      completion: _completion(json['profile_completion']),
      country: countryRaw is Map
          ? _country(Map<String, dynamic>.from(countryRaw))
          : null,
    );
  }
}

class OnboardingModel {
  const OnboardingModel._();

  static OnboardingStatus status(Map<String, dynamic> json) {
    final detected = _map(json['detected']);

    return OnboardingStatus(
      required: json['required'] == true,
      completedAt: _string(json['completed_at']),
      detected: DetectedPreferences(
        country: _sourced<CountryOption>(
          detected['country'],
          (entry) => entry['country'] is Map
              ? _country(_map(entry['country']))
              : null,
        ),
        city: _sourced<String>(detected['city'], _string),
        timezone: _sourced<String>(detected['timezone'], _string),
        locale: _sourced<String>(detected['locale'], _string),
        theme: _sourced<String>(detected['theme'], _string),
        currency: _sourced<CurrencySuggestion>(
          detected['currency'],
          (entry) {
            final value = _string(entry['value']);
            if (value == null) return null;
            return CurrencySuggestion(
              code: value,
              name: '${entry['name'] ?? value}',
              symbol: '${entry['symbol'] ?? ''}',
              decimals: _int(entry['decimals'], fallback: 2),
            );
          },
        ),
        dateFormat: _sourced<String>(detected['date_format'], _string),
        timeFormat: _sourced<String>(detected['time_format'], _string),
        phoneCountryCode:
            _sourced<String>(detected['phone_country_code'], _string),
      ),
    );
  }

  static CountryCatalogue countries(Map<String, dynamic> json) {
    final raw = json['countries'];
    return CountryCatalogue(
      defaultCountry: _string(json['default']),
      countries: raw is List
          ? raw
              .whereType<Map>()
              .map((entry) => _country(Map<String, dynamic>.from(entry)))
              .toList(growable: false)
          : const <CountryOption>[],
    );
  }

  static CitySuggestions cities(Map<String, dynamic> json) {
    return CitySuggestions(
      country: json['country'] is Map
          ? _country(Map<String, dynamic>.from(json['country'] as Map))
          : null,
      cities: _strings(json['cities']),
      manualEntry: json['manual_entry'] != false,
    );
  }

  static TimezoneCatalogue timezones(Map<String, dynamic> json) {
    final raw = json['timezones'];
    return TimezoneCatalogue(
      fallback: '${json['fallback'] ?? 'UTC'}',
      timezones: raw is List
          ? raw.whereType<Map>().map((entry) {
              final map = Map<String, dynamic>.from(entry);
              return TimezoneOption(
                value: '${map['value'] ?? map['label'] ?? ''}',
                label: '${map['label'] ?? map['value'] ?? ''}',
                region: '${map['region'] ?? ''}',
              );
            }).toList(growable: false)
          : const <TimezoneOption>[],
    );
  }

  static AccountOverview overview(Map<String, dynamic> json) {
    final account = _map(json['account']);
    final workspaces = _map(json['workspaces']);
    final security = _map(json['security']);
    final items = workspaces['items'];

    return AccountOverview(
      memberSince: _string(account['member_since']),
      ageDays: _int(account['age_days']),
      status: '${account['status'] ?? ''}',
      type: '${account['type'] ?? 'member'}',
      emailVerified: account['email_verified'] == true,
      phoneVerified: account['phone_verified'] == true,
      twoFactorEnabled: account['two_factor_enabled'] == true,
      passwordChangedAt: _string(account['password_changed_at']),
      lastLoginAt: _string(account['last_login_at']),
      completion: _completion(json['profile']),
      workspaceCount: _int(workspaces['count']),
      storesCount: _int(workspaces['stores_count']),
      workspaces: items is List
          ? items.whereType<Map>().map((entry) {
              final map = Map<String, dynamic>.from(entry);
              return WorkspaceMembershipSummary(
                id: _int(map['id']),
                name: '${map['name'] ?? ''}',
                slug: '${map['slug'] ?? ''}',
                roles: _strings(map['roles']),
                isOwner: map['is_owner'] == true,
              );
            }).toList(growable: false)
          : const <WorkspaceMembershipSummary>[],
      activeSessions: _int(security['active_sessions']),
      recentEvents: _int(security['recent_events']),
    );
  }
}

/* -------------------------------------------------------------- data source */

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._api);

  final ApiClient _api;

  Future<UserProfile> get() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profile,
      decode: _map,
    );
    return ProfileModel.fromJson(data);
  }

  Future<AccountOverview> overview() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileOverview,
      decode: _map,
    );
    return OnboardingModel.overview(data);
  }

  Future<UserProfile> update(ProfileUpdateDraft draft) async {
    final data = await _api.patch<Map<String, dynamic>>(
      ApiPaths.profile,
      body: draft.toJson(),
      decode: _map,
    );
    return ProfileModel.fromJson(data);
  }

  Future<UserProfile> uploadAvatar(List<int> bytes, String filename) async {
    final form = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.profileAvatar,
      body: form,
      decode: _map,
    );
    return ProfileModel.fromJson(data);
  }

  Future<UserProfile> removeAvatar() async {
    final data = await _api.deleteJson<Map<String, dynamic>>(
      ApiPaths.profileAvatar,
      decode: _map,
    );
    return ProfileModel.fromJson(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _api.putVoid(
      ApiPaths.profilePassword,
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<List<ProfileSession>> sessions() async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.profileSessions,
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) => _session(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }

  Future<void> revokeSession(int id) {
    return _api.delete(ApiPaths.profileSession('$id'));
  }

  Future<void> revokeOtherSessions() {
    return _api.delete(ApiPaths.profileSessions);
  }

  Future<NotificationPreferences> notificationPreferences() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileNotifications,
      decode: _map,
    );
    return _preferences(data);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final data = await _api.put<Map<String, dynamic>>(
      ApiPaths.profileNotifications,
      body: preferences.toJson(),
      decode: _map,
    );
    return _preferences(data);
  }

  Future<Map<String, NotificationChannelState>> notificationChannels() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileNotificationChannels,
      decode: _map,
    );
    return {
      for (final entry in data.entries)
        if (entry.value is Map)
          entry.key: NotificationChannelState(
            available: _map(entry.value)['available'] == true,
            label: '${_map(entry.value)['label'] ?? entry.key}',
            reason: _string(_map(entry.value)['reason']),
          ),
    };
  }

  /* First-login preferences */

  Future<OnboardingStatus> onboardingStatus() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileOnboarding,
      decode: _map,
    );
    return OnboardingModel.status(data);
  }

  Future<UserProfile> completeOnboarding(OnboardingDraft draft) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.profileOnboarding,
      body: draft.toJson(),
      decode: _map,
    );
    return ProfileModel.fromJson(data);
  }

  Future<void> skipOnboarding() {
    return _api.postVoid(ApiPaths.profileOnboardingSkip);
  }

  /* Location catalogues */

  Future<CountryCatalogue> countries() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileCountries,
      decode: _map,
    );
    return OnboardingModel.countries(data);
  }

  Future<CitySuggestions> cities(String iso2, {String query = ''}) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileCities(iso2),
      query: {if (query.trim().isNotEmpty) 'q': query.trim()},
      decode: _map,
    );
    return OnboardingModel.cities(data);
  }

  Future<TimezoneCatalogue> timezones() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileTimezones,
      decode: _map,
    );
    return OnboardingModel.timezones(data);
  }

  /* Two-factor authentication */

  Future<TwoFactorStatus> twoFactorStatus() async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiPaths.profileTwoFactor,
      decode: _map,
    );
    return _twoFactor(data);
  }

  Future<TwoFactorSetup> startTwoFactorSetup() async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.profileTwoFactorSetup,
      decode: _map,
    );
    return TwoFactorSetup(
      secret: '${data['secret'] ?? ''}',
      provisioningUri: '${data['provisioning_uri'] ?? ''}',
      qrSvg: '${data['qr_svg'] ?? ''}',
      issuer: '${data['issuer'] ?? ''}',
      account: '${data['account'] ?? ''}',
    );
  }

  Future<TwoFactorConfirmResult> confirmTwoFactor(String code) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.profileTwoFactorConfirm,
      body: {'code': code},
      decode: _map,
    );
    return TwoFactorConfirmResult(
      codes: _strings(data['codes']),
      confirmedAt: _string(data['confirmed_at']),
      twoFactor: _twoFactor(data['two_factor']),
    );
  }

  Future<List<String>> regenerateRecoveryCodes(String code) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiPaths.profileTwoFactorRecoveryCodes,
      body: {'code': code},
      decode: _map,
    );
    return _strings(data['codes']);
  }

  Future<TwoFactorStatus> disableTwoFactor({
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    final data = await _api.deleteJson<Map<String, dynamic>>(
      ApiPaths.profileTwoFactor,
      body: {
        'password': password,
        if (code != null && code.isNotEmpty) 'code': code,
        if (recoveryCode != null && recoveryCode.isNotEmpty)
          'recovery_code': recoveryCode,
      },
      decode: _map,
    );
    return _twoFactor(data['two_factor']);
  }

  /* Security history */

  Future<List<SecurityEvent>> securityActivity({
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _api.get<List<dynamic>>(
      ApiPaths.profileSecurityActivity,
      query: {'page': page, 'per_page': perPage},
      decode: (raw) => raw is List ? raw : const <dynamic>[],
    );
    return data
        .whereType<Map>()
        .map((entry) => _event(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
  }

  static NotificationPreferences _preferences(Map<String, dynamic> data) {
    return NotificationPreferences({
      for (final channel in data.entries)
        if (channel.value is Map)
          channel.key: {
            for (final event in (channel.value as Map).entries)
              if (event.value is bool) '${event.key}': event.value as bool,
          },
    });
  }
}

/* -------------------------------------------------------------- repository */

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<UserProfile> get() => _remote.get();

  @override
  Future<AccountOverview> overview() => _remote.overview();

  @override
  Future<UserProfile> update(ProfileUpdateDraft draft) => _remote.update(draft);

  @override
  Future<UserProfile> uploadAvatar(List<int> bytes, String filename) =>
      _remote.uploadAvatar(bytes, filename);

  @override
  Future<UserProfile> removeAvatar() => _remote.removeAvatar();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remote.changePassword(
      currentPassword: currentPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<List<ProfileSession>> sessions() => _remote.sessions();

  @override
  Future<void> revokeSession(int id) => _remote.revokeSession(id);

  @override
  Future<void> revokeOtherSessions() => _remote.revokeOtherSessions();

  @override
  Future<NotificationPreferences> notificationPreferences() =>
      _remote.notificationPreferences();

  @override
  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) {
    return _remote.updateNotificationPreferences(preferences);
  }

  @override
  Future<Map<String, NotificationChannelState>> notificationChannels() =>
      _remote.notificationChannels();

  @override
  Future<OnboardingStatus> onboardingStatus() => _remote.onboardingStatus();

  @override
  Future<UserProfile> completeOnboarding(OnboardingDraft draft) =>
      _remote.completeOnboarding(draft);

  @override
  Future<void> skipOnboarding() => _remote.skipOnboarding();

  @override
  Future<CountryCatalogue> countries() => _remote.countries();

  @override
  Future<CitySuggestions> cities(String iso2, {String query = ''}) =>
      _remote.cities(iso2, query: query);

  @override
  Future<TimezoneCatalogue> timezones() => _remote.timezones();

  @override
  Future<TwoFactorStatus> twoFactorStatus() => _remote.twoFactorStatus();

  @override
  Future<TwoFactorSetup> startTwoFactorSetup() =>
      _remote.startTwoFactorSetup();

  @override
  Future<TwoFactorConfirmResult> confirmTwoFactor(String code) =>
      _remote.confirmTwoFactor(code);

  @override
  Future<List<String>> regenerateRecoveryCodes(String code) =>
      _remote.regenerateRecoveryCodes(code);

  @override
  Future<TwoFactorStatus> disableTwoFactor({
    required String password,
    String? code,
    String? recoveryCode,
  }) {
    return _remote.disableTwoFactor(
      password: password,
      code: code,
      recoveryCode: recoveryCode,
    );
  }

  @override
  Future<List<SecurityEvent>> securityActivity({
    int page = 1,
    int perPage = 20,
  }) {
    return _remote.securityActivity(page: page, perPage: perPage);
  }
}
