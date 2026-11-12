import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/currency/currency_catalogue.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/currency_picker.dart';
import '../../../core/widgets/search_picker.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import '../domain/profile_domain.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profileTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('settings'),
            onPressed: () => context.push(RoutePaths.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (data) => _ProfileBody(profile: data),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.dukavo;

    return ListView(
      padding: AppSpacing.page,
      children: [
        if (profile.needsOnboarding) ...[
          InfoBanner(
            message: context.tr('onboardingPromptBody'),
            tone: InfoBannerTone.info,
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: context.tr('onboardingPromptAction'),
              variant: AppButtonVariant.outlined,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.push(RoutePaths.welcome),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppCard(
          tone: AppCardTone.low,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Stack(
                children: [
                  AppAvatar(
                    url: profile.avatarUrl,
                    name: profile.name,
                    size: 92,
                  ),
                  PositionedDirectional(
                    bottom: -4,
                    end: -4,
                    child: Material(
                      color: theme.colorScheme.primary,
                      shape: CircleBorder(
                        side: BorderSide(color: colors.surface, width: 2),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _pickAvatar(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                profile.name,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                profile.email,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              StatusChip(status: profile.status),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${context.tr('lastLogin')}: '
                '${Formatters.dateTime(profile.lastLoginAt)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              if (profile.avatarUrl != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                TextButton.icon(
                  onPressed: () => _removeAvatar(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.danger,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(context.tr('removePhoto')),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppListGroup(
          title: context.tr('account'),
          children: [
            _ProfileTile(
              icon: Icons.person_outline,
              label: context.tr('editProfile'),
              subtitle: context.tr('editProfileHint'),
              onTap: () => _editProfile(context, ref),
            ),
            _ProfileTile(
              icon: Icons.currency_exchange_rounded,
              label: context.tr('displayCurrency'),
              subtitle: profile.preferredCurrencyName.isEmpty
                  ? profile.preferredCurrency
                  : '${profile.preferredCurrency} · '
                      '${profile.preferredCurrencyName}',
              onTap: () => _editCurrency(context, ref),
            ),
            _ProfileTile(
              icon: Icons.shield_outlined,
              label: context.tr('securityCenter'),
              subtitle: profile.twoFactor.enabled
                  ? context.tr('twoFactorOn')
                  : context.tr('twoFactorOff'),
              onTap: () => context.push(RoutePaths.security),
            ),
            _ProfileTile(
              icon: Icons.notifications_outlined,
              label: context.tr('notificationPreferences'),
              onTap: () => context.push(RoutePaths.settings),
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              label: context.tr('settings'),
              onTap: () => context.push(RoutePaths.settings),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _LocationCard(profile: profile),
        const SizedBox(height: AppSpacing.sm),
        _AccountMetaCard(profile: profile),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: context.tr('logout'),
          variant: AppButtonVariant.outlined,
          icon: Icons.logout,
          expand: true,
          onPressed: () => _signOut(context, ref),
        ),
      ],
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!context.mounted) return;
        AppSnack.show(context, context.tr('imageUploadFailed'), isError: true);
        return;
      }
      await ref.read(profileActionsProvider).uploadAvatar(bytes, file.name);
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('avatarUpdated'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _removeAvatar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(profileActionsProvider).removeAvatar();
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('avatarRemoved'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final updated = await showModalBottomSheet<ProfileUpdateDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ProfileEditSheet(profile: profile),
    );
    if (updated == null) return;
    try {
      await ref.read(profileActionsProvider).update(updated);
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('profileUpdated'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _editCurrency(BuildContext context, WidgetRef ref) async {
    try {
      final catalogue = await ref.read(currencyCatalogueProvider.future);
      if (!context.mounted) return;

      final choice = await showCurrencyPicker(
        context,
        currencies: catalogue.currencies,
        selected: profile.preferredCurrency,
        title: context.tr('displayCurrency'),
      );
      if (choice == null || choice.code == profile.preferredCurrency) return;

      await ref.read(profileActionsProvider).update(
            ProfileUpdateDraft(preferredCurrency: choice.code),
          );
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('profileUpdated'));
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('logout'),
      message: context.tr('signOutMessage'),
      confirmLabel: context.tr('logout'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).logout();
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: Icon(
          icon,
          size: 19,
          color: context.scheme.onPrimaryContainer,
        ),
      ),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: context.dukavo.textMuted,
      ),
      onTap: onTap,
    );
  }
}

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController _bio =
      TextEditingController(text: widget.profile.bio ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone ?? '');
  late final TextEditingController _city =
      TextEditingController(text: widget.profile.city ?? '');
  late String? _country = widget.profile.countryCode;
  late String? _timezone = widget.profile.timezone;
  late String? _phoneCountry = widget.profile.phoneCountryCode;
  late String _locale = widget.profile.locale ?? 'en';
  late String _theme = widget.profile.theme;
  late String _dateFormat = widget.profile.dateFormat;
  late String _timeFormat = widget.profile.timeFormat;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countries = ref.watch(countriesProvider);
    final timezones = ref.watch(timezonesProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('editProfile'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _name,
                    label: context.tr('name'),
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.tr('requiredField')
                        : null,
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _bio,
                    label: context.tr('bio'),
                    hint: context.tr('bioHint'),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 10),
                  countries.when(
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (error, stack) => Text(error.toString()),
                    data: (catalogue) {
                      CountryOption? selected;
                      for (final country in catalogue.countries) {
                        if (country.iso2 == _country) selected = country;
                      }
                      return SearchPickerField<CountryOption>(
                        label: context.tr('country'),
                        hint: context.tr('countryPlaceholder'),
                        searchHint: context.tr('countrySearch'),
                        prefixIcon: Icons.public_rounded,
                        value: selected,
                        options: catalogue.countries,
                        labelOf: (country) =>
                            '${country.flag}  ${country.name}',
                        subtitleOf: (country) =>
                            '${country.iso2} · +${country.dialCode}',
                        searchTermsOf: (country) =>
                            '${country.name} ${country.nameEn} '
                            '${country.nameAr} ${country.native} '
                            '${country.iso2} ${country.dialCode}',
                        onSelected: (country) {
                          setState(() {
                            if (_country != country.iso2) {
                              _city.clear();
                            }
                            _country = country.iso2;
                            _phoneCountry ??= country.iso2;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _city,
                    label: context.tr('city'),
                    hint: context.tr('cityHint'),
                    helper: context.tr('cityManualHint'),
                    prefixIcon: Icons.location_city_rounded,
                  ),
                  const SizedBox(height: 10),
                  timezones.when(
                    loading: () => const LinearProgressIndicator(minHeight: 2),
                    error: (error, stack) => Text(error.toString()),
                    data: (catalogue) {
                      TimezoneOption? selected;
                      for (final zone in catalogue.timezones) {
                        if (zone.value == _timezone) selected = zone;
                      }
                      return SearchPickerField<TimezoneOption>(
                        label: context.tr('timezone'),
                        hint: context.tr('timezonePlaceholder'),
                        searchHint: context.tr('timezoneSearch'),
                        prefixIcon: Icons.schedule_rounded,
                        value: selected,
                        options: catalogue.timezones,
                        labelOf: (zone) => zone.label,
                        searchTermsOf: (zone) =>
                            '${zone.label} ${zone.value}',
                        onSelected: (zone) =>
                            setState(() => _timezone = zone.value),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  countries.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                    data: (catalogue) {
                      CountryOption? selected;
                      for (final country in catalogue.countries) {
                        if (country.iso2 == _phoneCountry) selected = country;
                      }
                      return SearchPickerField<CountryOption>(
                        label: context.tr('phoneCountry'),
                        hint: context.tr('phoneCountryHint'),
                        searchHint: context.tr('countrySearch'),
                        prefixIcon: Icons.call_outlined,
                        value: selected,
                        options: catalogue.countries,
                        labelOf: (country) =>
                            '${country.flag}  ${country.name} '
                            '(+${country.dialCode})',
                        searchTermsOf: (country) =>
                            '${country.name} ${country.nameEn} '
                            '${country.nameAr} ${country.native} '
                            '${country.iso2} ${country.dialCode}',
                        onSelected: (country) =>
                            setState(() => _phoneCountry = country.iso2),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _phone,
                    label: context.tr('phone'),
                    helper: context.tr('optional'),
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _locale,
                    decoration:
                        InputDecoration(labelText: context.tr('language')),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(context.tr('english')),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(context.tr('arabic')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _locale = value ?? 'en'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _theme,
                    decoration:
                        InputDecoration(labelText: context.tr('theme')),
                    items: [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text(context.tr('themeSystem')),
                      ),
                      DropdownMenuItem(
                        value: 'light',
                        child: Text(context.tr('themeLight')),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text(context.tr('themeDark')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _theme = value ?? 'system'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _dateFormat,
                    decoration:
                        InputDecoration(labelText: context.tr('dateFormat')),
                    items: const [
                      DropdownMenuItem(
                        value: 'DD/MM/YYYY',
                        child: Text('DD/MM/YYYY'),
                      ),
                      DropdownMenuItem(
                        value: 'MM/DD/YYYY',
                        child: Text('MM/DD/YYYY'),
                      ),
                      DropdownMenuItem(
                        value: 'YYYY-MM-DD',
                        child: Text('YYYY-MM-DD'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _dateFormat = value ?? 'DD/MM/YYYY'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _timeFormat,
                    decoration:
                        InputDecoration(labelText: context.tr('timeFormat')),
                    items: [
                      DropdownMenuItem(
                        value: '24h',
                        child: Text(context.tr('timeFormat24')),
                      ),
                      DropdownMenuItem(
                        value: '12h',
                        child: Text(context.tr('timeFormat12')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _timeFormat = value ?? '24h'),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: context.tr('saveChanges'),
                    expand: true,
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      Navigator.of(context).pop(
                        ProfileUpdateDraft(
                          name: _name.text.trim(),
                          bio: _bio.text.trim(),
                          phone: _phone.text.trim(),
                          phoneCountryCode: _phoneCountry,
                          countryCode: _country,
                          city: _city.text.trim(),
                          timezone: _timezone,
                          locale: _locale,
                          theme: _theme,
                          dateFormat: _dateFormat,
                          timeFormat: _timeFormat,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _LocationCard extends ConsumerWidget {
  const _LocationCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = profile.country;

    return SectionCard(
      title: context.tr('locationAndPreferences'),
      subtitle: context.tr('locationAndPreferencesDesc'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyValueRow(
            label: context.tr('country'),
            value: country == null
                ? '—'
                : '${country.flag}  ${country.name}',
          ),
          KeyValueRow(
            label: context.tr('city'),
            value: profile.city ?? '—',
          ),
          KeyValueRow(
            label: context.tr('timezone'),
            value: profile.timezone ?? '—',
          ),
          KeyValueRow(
            label: context.tr('language'),
            value: profile.locale == null
                ? '—'
                : context.tr(profile.locale == 'ar' ? 'arabic' : 'english'),
          ),
          KeyValueRow(
            label: context.tr('theme'),
            value: context.tr('theme${_capitalise(profile.theme)}'),
          ),
          KeyValueRow(
            label: context.tr('dateFormat'),
            value: profile.dateFormat,
          ),
          KeyValueRow(
            label: context.tr('timeFormat'),
            value: context.tr(
              profile.timeFormat == '12h' ? 'timeFormat12' : 'timeFormat24',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.tr('workspaceSeparationHint'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.dukavo.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  String _capitalise(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

class _AccountMetaCard extends ConsumerWidget {
  const _AccountMetaCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = profile.completion;

    return SectionCard(
      title: context.tr('accountInformation'),
      subtitle: context.tr('accountMetaDesc'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeyValueRow(
            label: context.tr('accountType'),
            value: context.tr('accountTypeMember'),
          ),
          KeyValueRow(
            label: context.tr('memberSince'),
            value: Formatters.date(profile.createdAt),
          ),
          KeyValueRow(
            label: context.tr('lastLogin'),
            value: Formatters.dateTime(profile.lastLoginAt),
          ),
          KeyValueRow(
            label: context.tr('passwordChanged'),
            value: profile.passwordChangedAt == null
                ? context.tr('passwordNever')
                : Formatters.date(profile.passwordChangedAt),
          ),
          KeyValueRow(
            label: context.tr('twoFactor'),
            value: context.tr(
              profile.twoFactor.enabled ? 'twoFactorOn' : 'twoFactorOff',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('profileCompletion'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: (completion.percentage / 100).clamp(0, 1),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            completion.missing.isEmpty
                ? context.tr('profileComplete')
                : context.tr(
                    'completionMissing',
                    args: {'count': completion.missing.length},
                  ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.dukavo.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}
