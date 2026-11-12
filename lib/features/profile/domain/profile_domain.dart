/// Where a detected or stored preference came from.
enum PreferenceSource {
  ip,
  device,
  browser,
  manual,
  defaultSource,
  existing;

  static PreferenceSource parse(String? raw) {
    switch (raw) {
      case 'ip':
        return PreferenceSource.ip;
      case 'device':
        return PreferenceSource.device;
      case 'browser':
        return PreferenceSource.browser;
      case 'manual':
        return PreferenceSource.manual;
      case 'existing':
        return PreferenceSource.existing;
      default:
        return PreferenceSource.defaultSource;
    }
  }

  bool get isApproximate =>
      this == PreferenceSource.ip || this == PreferenceSource.defaultSource;
}

/// A preference value plus its honest provenance.
class SourcedValue<T> {
  const SourcedValue({
    this.value,
    this.source = PreferenceSource.defaultSource,
    this.confidence = 0,
  });

  final T? value;
  final PreferenceSource source;
  final int confidence;
}

/// One country as the server's catalogue describes it.
class CountryOption {
  const CountryOption({
    required this.iso2,
    required this.name,
    required this.nameEn,
    required this.nameAr,
    required this.native,
    required this.dialCode,
    required this.currency,
    required this.flag,
  });

  final String iso2;
  final String name;
  final String nameEn;
  final String nameAr;
  final String native;
  final String dialCode;
  final String currency;
  final String flag;
}

class CountryCatalogue {
  const CountryCatalogue({this.defaultCountry, required this.countries});

  final String? defaultCountry;
  final List<CountryOption> countries;
}

class CitySuggestions {
  const CitySuggestions({
    required this.country,
    required this.cities,
    required this.manualEntry,
  });

  final CountryOption? country;
  final List<String> cities;
  final bool manualEntry;
}

class TimezoneOption {
  const TimezoneOption({
    required this.value,
    required this.label,
    required this.region,
  });

  final String value;
  final String label;
  final String region;
}

class TimezoneCatalogue {
  const TimezoneCatalogue({required this.fallback, required this.timezones});

  final String fallback;
  final List<TimezoneOption> timezones;
}

class ProfileCompletion {
  const ProfileCompletion({
    required this.percentage,
    required this.completed,
    required this.missing,
  });

  final int percentage;
  final List<String> completed;
  final List<String> missing;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.bio,
    this.phone,
    this.phoneCountryCode,
    this.phoneVerifiedAt,
    this.locale,
    this.theme = 'system',
    this.dateFormat = 'DD/MM/YYYY',
    this.timeFormat = '24h',
    this.countryCode,
    this.city,
    this.timezone,
    this.preferredCurrency = 'USD',
    this.preferredCurrencyName = '',
    this.preferredCurrencyNameEn = '',
    this.preferredCurrencyNameAr = '',
    this.preferredCurrencySymbol = '',
    this.preferredCurrencyDecimals = 2,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.lastLoginAt,
    this.passwordChangedAt,
    this.createdAt,
    this.preferencesInitializedAt,
    this.twoFactor = const TwoFactorStatus(),
    this.completion = const ProfileCompletion(
      percentage: 0,
      completed: [],
      missing: [],
    ),
    this.country,
  });

  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? phone;
  final String? phoneCountryCode;
  final String? phoneVerifiedAt;
  final String? locale;
  final String theme;
  final String dateFormat;
  final String timeFormat;
  final String? countryCode;
  final String? city;
  final String? timezone;
  final String preferredCurrency;
  final String preferredCurrencyName;
  final String preferredCurrencyNameEn;
  final String preferredCurrencyNameAr;
  final String preferredCurrencySymbol;
  final int preferredCurrencyDecimals;
  final String status;
  final String? avatarUrl;
  final String? emailVerifiedAt;
  final String? lastLoginAt;
  final String? passwordChangedAt;
  final String? createdAt;
  final String? preferencesInitializedAt;
  final TwoFactorStatus twoFactor;
  final ProfileCompletion completion;
  final CountryOption? country;

  bool get needsOnboarding => preferencesInitializedAt == null;
}

/// One Sanctum token, described as a signed-in device.
class ProfileSession {
  const ProfileSession({
    required this.id,
    required this.name,
    required this.isCurrent,
    this.device = '',
    this.browser = '',
    this.platform = '',
    this.deviceType = '',
    this.ipAddress,
    this.countryCode,
    this.countryName,
    this.firstLoginAt,
    this.lastUsedAt,
    this.lastActivityAt,
    this.expiresAt,
    this.createdAt,
  });

  final int id;
  final String name;
  final String device;
  final String browser;
  final String platform;
  final String deviceType;
  final bool isCurrent;
  final String? ipAddress;
  final String? countryCode;
  final String? countryName;
  final String? firstLoginAt;
  final String? lastUsedAt;
  final String? lastActivityAt;
  final String? expiresAt;
  final String? createdAt;
}

class TwoFactorStatus {
  const TwoFactorStatus({
    this.enabled = false,
    this.pending = false,
    this.confirmedAt,
    this.recoveryCodesCount = 0,
  });

  final bool enabled;
  final bool pending;
  final String? confirmedAt;
  final int recoveryCodesCount;
}

class TwoFactorSetup {
  const TwoFactorSetup({
    required this.secret,
    required this.provisioningUri,
    required this.qrSvg,
    required this.issuer,
    required this.account,
  });

  final String secret;
  final String provisioningUri;
  final String qrSvg;
  final String issuer;
  final String account;
}

class TwoFactorConfirmResult {
  const TwoFactorConfirmResult({
    required this.codes,
    required this.confirmedAt,
    required this.twoFactor,
  });

  final List<String> codes;
  final String? confirmedAt;
  final TwoFactorStatus twoFactor;
}

class SecurityEvent {
  const SecurityEvent({
    required this.id,
    required this.event,
    required this.label,
    required this.category,
    required this.status,
    this.ipAddress,
    this.device,
    this.countryCode,
    this.createdAt,
  });

  final int id;
  final String event;
  final String label;
  final String category;
  final String status;
  final String? ipAddress;
  final String? device;
  final String? countryCode;
  final String? createdAt;

  bool get isSuccess => status == 'success';
}

class AccountOverview {
  const AccountOverview({
    required this.memberSince,
    required this.ageDays,
    required this.status,
    required this.type,
    required this.emailVerified,
    required this.phoneVerified,
    required this.twoFactorEnabled,
    required this.passwordChangedAt,
    required this.lastLoginAt,
    required this.completion,
    required this.workspaceCount,
    required this.storesCount,
    required this.workspaces,
    required this.activeSessions,
    required this.recentEvents,
  });

  final String? memberSince;
  final int ageDays;
  final String status;
  final String type;
  final bool emailVerified;
  final bool phoneVerified;
  final bool twoFactorEnabled;
  final String? passwordChangedAt;
  final String? lastLoginAt;
  final ProfileCompletion completion;
  final int workspaceCount;
  final int storesCount;
  final List<WorkspaceMembershipSummary> workspaces;
  final int activeSessions;
  final int recentEvents;
}

class WorkspaceMembershipSummary {
  const WorkspaceMembershipSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.roles,
    required this.isOwner,
  });

  final int id;
  final String name;
  final String slug;
  final List<String> roles;
  final bool isOwner;
}

class DetectedPreferences {
  const DetectedPreferences({
    required this.country,
    required this.city,
    required this.timezone,
    required this.locale,
    required this.theme,
    required this.currency,
    required this.dateFormat,
    required this.timeFormat,
    required this.phoneCountryCode,
  });

  final SourcedValue<CountryOption> country;
  final SourcedValue<String> city;
  final SourcedValue<String> timezone;
  final SourcedValue<String> locale;
  final SourcedValue<String> theme;
  final SourcedValue<CurrencySuggestion> currency;
  final SourcedValue<String> dateFormat;
  final SourcedValue<String> timeFormat;
  final SourcedValue<String> phoneCountryCode;
}

class CurrencySuggestion {
  const CurrencySuggestion({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimals,
  });

  final String code;
  final String name;
  final String symbol;
  final int decimals;
}

class OnboardingStatus {
  const OnboardingStatus({
    required this.required,
    this.completedAt,
    required this.detected,
  });

  final bool required;
  final String? completedAt;
  final DetectedPreferences detected;
}

class NotificationChannelState {
  const NotificationChannelState({
    required this.available,
    required this.label,
    this.reason,
  });

  final bool available;
  final String label;
  final String? reason;
}

/// Channel -> event -> enabled.
class NotificationPreferences {
  const NotificationPreferences(this.values);

  final Map<String, Map<String, bool>> values;

  bool isEnabled(String channel, String event) =>
      values[channel]?[event] ?? false;

  NotificationPreferences copyWithEvent(
    String channel,
    String event,
    bool enabled,
  ) {
    final next = <String, Map<String, bool>>{
      for (final entry in values.entries)
        entry.key: Map<String, bool>.from(entry.value),
    };
    next.putIfAbsent(channel, () => <String, bool>{})[event] = enabled;
    return NotificationPreferences(next);
  }

  Map<String, dynamic> toJson() => {
        for (final entry in values.entries) entry.key: entry.value,
      };
}

class ProfileUpdateDraft {
  const ProfileUpdateDraft({
    this.name,
    this.bio,
    this.phone,
    this.phoneCountryCode,
    this.countryCode,
    this.city,
    this.timezone,
    this.locale,
    this.theme,
    this.preferredCurrency,
    this.dateFormat,
    this.timeFormat,
  });

  final String? name;
  final String? bio;
  final String? phone;
  final String? phoneCountryCode;
  final String? countryCode;
  final String? city;
  final String? timezone;
  final String? locale;
  final String? theme;
  final String? preferredCurrency;
  final String? dateFormat;
  final String? timeFormat;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
        if (phoneCountryCode != null) 'phone_country_code': phoneCountryCode,
        if (countryCode != null) 'country_code': countryCode,
        if (city != null) 'city': city,
        if (timezone != null) 'timezone': timezone,
        if (locale != null) 'locale': locale,
        if (theme != null) 'theme': theme,
        if (preferredCurrency != null) 'preferred_currency': preferredCurrency,
        if (dateFormat != null) 'date_format': dateFormat,
        if (timeFormat != null) 'time_format': timeFormat,
      };
}

class OnboardingDraft {
  const OnboardingDraft({
    this.name,
    this.bio,
    this.phone,
    this.phoneCountryCode,
    this.countryCode,
    this.city,
    this.timezone,
    this.locale,
    this.theme,
    this.preferredCurrency,
    this.dateFormat,
    this.timeFormat,
  });

  final String? name;
  final String? bio;
  final String? phone;
  final String? phoneCountryCode;
  final String? countryCode;
  final String? city;
  final String? timezone;
  final String? locale;
  final String? theme;
  final String? preferredCurrency;
  final String? dateFormat;
  final String? timeFormat;

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (bio != null) 'bio': bio,
        if (phone != null) 'phone': phone,
        if (phoneCountryCode != null) 'phone_country_code': phoneCountryCode,
        if (countryCode != null) 'country_code': countryCode,
        if (city != null) 'city': city,
        if (timezone != null) 'timezone': timezone,
        if (locale != null) 'locale': locale,
        if (theme != null) 'theme': theme,
        if (preferredCurrency != null) 'preferred_currency': preferredCurrency,
        if (dateFormat != null) 'date_format': dateFormat,
        if (timeFormat != null) 'time_format': timeFormat,
      };
}

abstract class ProfileRepository {
  Future<UserProfile> get();

  Future<UserProfile> update(ProfileUpdateDraft draft);

  Future<AccountOverview> overview();

  Future<UserProfile> uploadAvatar(List<int> bytes, String filename);

  Future<UserProfile> removeAvatar();

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<List<ProfileSession>> sessions();

  Future<void> revokeSession(int id);

  Future<void> revokeOtherSessions();

  Future<NotificationPreferences> notificationPreferences();

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  );

  Future<Map<String, NotificationChannelState>> notificationChannels();

  /* First-login preferences */

  Future<OnboardingStatus> onboardingStatus();

  Future<UserProfile> completeOnboarding(OnboardingDraft draft);

  Future<void> skipOnboarding();

  /* Location catalogues */

  Future<CountryCatalogue> countries();

  Future<CitySuggestions> cities(String iso2, {String query = ''});

  Future<TimezoneCatalogue> timezones();

  /* Two-factor authentication */

  Future<TwoFactorStatus> twoFactorStatus();

  Future<TwoFactorSetup> startTwoFactorSetup();

  Future<TwoFactorConfirmResult> confirmTwoFactor(String code);

  Future<List<String>> regenerateRecoveryCodes(String code);

  Future<TwoFactorStatus> disableTwoFactor({
    required String password,
    String? code,
    String? recoveryCode,
  });

  /* Security history */

  Future<List<SecurityEvent>> securityActivity({int page = 1, int perPage = 20});
}
