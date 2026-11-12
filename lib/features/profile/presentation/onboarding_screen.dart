import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/currency/currency_catalogue.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/currency_picker.dart';
import '../../../core/widgets/search_picker.dart';
import '../application/profile_controller.dart';
import '../domain/profile_domain.dart';

/// The once-only first-login preference confirmation.
///
/// It is an invitation, not a gate: saving and skipping both mark the account
/// done, and both leave every value editable on the profile screen. Detected
/// values are shown with their provenance so a network guess is never dressed
/// up as something the person verified.
class PreferencesOnboardingPage extends ConsumerWidget {
  const PreferencesOnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingStatusProvider);
    final countries = ref.watch(countriesProvider);
    final timezones = ref.watch(timezonesProvider);
    final currencies = ref.watch(currencyCatalogueProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('onboardingPreferencesTitle'))),
      body: status.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(onboardingStatusProvider),
        ),
        data: (value) => countries.when(
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(countriesProvider),
          ),
          data: (catalogue) => timezones.when(
            loading: () => const LoadingView(),
            error: (error, stack) => ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(timezonesProvider),
            ),
            data: (zoneCatalogue) => currencies.when(
              loading: () => const LoadingView(),
              error: (error, stack) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(currencyCatalogueProvider),
              ),
              data: (currencyCatalogue) => _OnboardingForm(
                key: ValueKey(value.completedAt ?? 'onboarding'),
                status: value,
                countries: catalogue,
                timezones: zoneCatalogue,
                currencies: currencyCatalogue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingForm extends ConsumerStatefulWidget {
  const _OnboardingForm({
    super.key,
    required this.status,
    required this.countries,
    required this.timezones,
    required this.currencies,
  });

  final OnboardingStatus status;
  final CountryCatalogue countries;
  final TimezoneCatalogue timezones;
  final CurrencyCatalogue currencies;

  @override
  ConsumerState<_OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends ConsumerState<_OnboardingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  Timer? _cityDebounce;
  List<String> _citySuggestions = const [];
  bool _searchingCities = false;
  bool _submitting = false;

  late String? _country;
  late String? _timezone;
  late String? _locale;
  late String? _theme;
  late String? _currency;
  late String? _dateFormat;
  late String? _timeFormat;
  late String? _phoneCountry;

  DetectedPreferences get _detected => widget.status.detected;

  @override
  void initState() {
    super.initState();
    final detected = _detected;
    _name = TextEditingController();
    _bio = TextEditingController();
    _phone = TextEditingController();
    _city = TextEditingController(text: detected.city.value ?? '');
    _country = detected.country.value?.iso2;
    _timezone = detected.timezone.value;
    _locale = detected.locale.value ?? 'en';
    _theme = detected.theme.value ?? 'system';
    _currency = detected.currency.value?.code;
    _dateFormat = detected.dateFormat.value ?? 'DD/MM/YYYY';
    _timeFormat = detected.timeFormat.value ?? '24h';
    _phoneCountry = detected.phoneCountryCode.value ?? detected.country.value?.iso2;
  }

  @override
  void dispose() {
    _cityDebounce?.cancel();
    _name.dispose();
    _bio.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  CountryOption? get _selectedCountry {
    for (final country in widget.countries.countries) {
      if (country.iso2 == _country) return country;
    }
    return null;
  }

  TimezoneOption? get _selectedTimezone {
    for (final zone in widget.timezones.timezones) {
      if (zone.value == _timezone) return zone;
    }
    return null;
  }

  void _countryChanged(CountryOption? country) {
    if (country == null || country.iso2 == _country) return;
    setState(() {
      _country = country.iso2;
      // A city belongs to a country. Keeping the old one across a country
      // change would silently attach "Paris" to the UAE.
      _city.clear();
      _citySuggestions = const [];
      _phoneCountry ??= country.iso2;
    });
  }

  void _searchCities(String query) {
    _cityDebounce?.cancel();
    final iso2 = _country;
    if (iso2 == null) return;
    _cityDebounce = Timer(const Duration(milliseconds: 260), () async {
      setState(() => _searchingCities = true);
      try {
        final result = await ref
            .read(profileRepositoryProvider)
            .cities(iso2, query: query);
        if (!mounted) return;
        setState(() {
          _citySuggestions = result.cities;
          _searchingCities = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _citySuggestions = const [];
          _searchingCities = false;
        });
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(profileActionsProvider).completeOnboarding(
            OnboardingDraft(
              name: _name.text.trim().isEmpty ? null : _name.text.trim(),
              bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              phoneCountryCode: _phoneCountry,
              countryCode: _country,
              city: _city.text.trim().isEmpty ? null : _city.text.trim(),
              timezone: _timezone,
              locale: _locale,
              theme: _theme,
              preferredCurrency: _currency,
              dateFormat: _dateFormat,
              timeFormat: _timeFormat,
            ),
          );
      if (!mounted) return;
      AppSnack.show(context, context.tr('onboardingSaved'));
      context.go(RoutePaths.profile);
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _skip() async {
    setState(() => _submitting = true);
    try {
      await ref.read(profileActionsProvider).skipOnboarding();
      if (!mounted) return;
      AppSnack.show(context, context.tr('onboardingSkipped'));
      context.go(RoutePaths.profile);
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Text(
            context.tr('onboardingPreferencesTitle'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.tr('onboardingPreferencesSubtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.dukavo.textSecondary,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DetectedBadge(source: _detected.country.source),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: context.tr('onboardingPersonalTitle'),
            subtitle: context.tr('onboardingPersonalHint'),
            child: Column(
              children: [
                AppTextField(
                  controller: _name,
                  label: context.tr('name'),
                  hint: context.tr('nameHint'),
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _bio,
                  label: context.tr('bio'),
                  hint: context.tr('bioHint'),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            title: context.tr('location'),
            subtitle: context.tr('onboardingLocationHint'),
            child: Column(
              children: [
                SearchPickerField<CountryOption>(
                  label: context.tr('country'),
                  hint: context.tr('countryPlaceholder'),
                  searchHint: context.tr('countrySearch'),
                  prefixIcon: Icons.public_rounded,
                  value: _selectedCountry,
                  options: widget.countries.countries,
                  labelOf: (country) => '${country.flag}  ${country.name}',
                  subtitleOf: (country) =>
                      '${country.iso2} · +${country.dialCode}',
                  searchTermsOf: (country) =>
                      '${country.name} ${country.nameEn} ${country.nameAr} '
                          '${country.native} ${country.iso2} ${country.dialCode}',
                  onSelected: _countryChanged,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _city,
                  label: context.tr('city'),
                  hint: context.tr('cityHint'),
                  helper: context.tr('cityManualHint'),
                  prefixIcon: Icons.location_city_rounded,
                  onChanged: _searchCities,
                ),
                if (_searchingCities)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xs),
                    child: LinearProgressIndicator(minHeight: 2),
                  )
                else if (_citySuggestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final city in _citySuggestions.take(8))
                            ActionChip(
                              label: Text(city),
                              onPressed: () {
                                setState(() {
                                  _city.text = city;
                                  _citySuggestions = const [];
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                SearchPickerField<TimezoneOption>(
                  label: context.tr('timezone'),
                  hint: context.tr('timezonePlaceholder'),
                  searchHint: context.tr('timezoneSearch'),
                  prefixIcon: Icons.schedule_rounded,
                  value: _selectedTimezone,
                  options: widget.timezones.timezones,
                  labelOf: (zone) => zone.label,
                  searchTermsOf: (zone) => '${zone.label} ${zone.value}',
                  onSelected: (zone) => setState(() => _timezone = zone.value),
                ),
                const SizedBox(height: AppSpacing.xs),
                SearchPickerField<CountryOption>(
                  label: context.tr('phoneCountry'),
                  hint: context.tr('phoneCountryHint'),
                  searchHint: context.tr('countrySearch'),
                  prefixIcon: Icons.call_outlined,
                  value: _selectedPhoneCountry(),
                  options: widget.countries.countries,
                  labelOf: (country) =>
                      '${country.flag}  ${country.name} (+${country.dialCode})',
                  searchTermsOf: (country) =>
                      '${country.name} ${country.nameEn} ${country.nameAr} '
                          '${country.native} ${country.iso2} ${country.dialCode}',
                  onSelected: (country) =>
                      setState(() => _phoneCountry = country.iso2),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppTextField(
                  controller: _phone,
                  label: context.tr('phone'),
                  hint: context.tr('optional'),
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            title: context.tr('preferences'),
            subtitle: context.tr('onboardingDisplayHint'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChoiceRow(
                  label: context.tr('language'),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'en',
                        label: Text(context.tr('english')),
                      ),
                      ButtonSegment(
                        value: 'ar',
                        label: Text(context.tr('arabic')),
                      ),
                    ],
                    selected: {_locale ?? 'en'},
                    onSelectionChanged: (values) =>
                        setState(() => _locale = values.first),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                CurrencyPickerField(
                  currencies: widget.currencies.currencies,
                  value: _currency,
                  label: context.tr('displayCurrency'),
                  onChanged: (currency) =>
                      setState(() => _currency = currency.code),
                ),
                const SizedBox(height: AppSpacing.xs),
                _ChoiceRow(
                  label: context.tr('theme'),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'system',
                        label: Text(context.tr('themeSystem')),
                      ),
                      ButtonSegment(
                        value: 'light',
                        label: Text(context.tr('themeLight')),
                      ),
                      ButtonSegment(
                        value: 'dark',
                        label: Text(context.tr('themeDark')),
                      ),
                    ],
                    selected: {_theme ?? 'system'},
                    onSelectionChanged: (values) =>
                        setState(() => _theme = values.first),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
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
                  onChanged: (value) => setState(() => _dateFormat = value),
                ),
                const SizedBox(height: AppSpacing.xs),
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
                  onChanged: (value) => setState(() => _timeFormat = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.tr('onboardingFootnote'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.dukavo.textMuted,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: context.tr('onboardingSave'),
            icon: Icons.check_rounded,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _save,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: context.tr('onboardingSkip'),
            variant: AppButtonVariant.outlined,
            expand: true,
            onPressed: _submitting ? null : _skip,
          ),
        ],
      ),
    );
  }

  CountryOption? _selectedPhoneCountry() {
    for (final country in widget.countries.countries) {
      if (country.iso2 == _phoneCountry) return country;
    }
    return null;
  }
}

class _DetectedBadge extends StatelessWidget {
  const _DetectedBadge({required this.source});

  final PreferenceSource source;

  @override
  Widget build(BuildContext context) {
    final approximate = source.isApproximate;
    return InfoBanner(
      message: approximate
          ? context.tr('onboardingApproximateBadge')
          : context.tr('onboardingDetectedBadge'),
      tone: approximate ? InfoBannerTone.warning : InfoBannerTone.info,
      icon: approximate
          ? Icons.info_outline_rounded
          : Icons.auto_awesome_outlined,
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Align(alignment: AlignmentDirectional.centerStart, child: child),
      ],
    );
  }
}
