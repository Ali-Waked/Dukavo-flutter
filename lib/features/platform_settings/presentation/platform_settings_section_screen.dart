import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

/// One configuration category, rendered from its definitions.
///
/// The server decides which control a setting needs, where its effective value
/// came from and whether the caller may change it. This screen honours all
/// three: an environment-sourced value is disabled, a database override offers
/// an explicit reset, and a secret is written once and never read back.
class PlatformSettingsSectionScreen extends ConsumerWidget {
  const PlatformSettingsSectionScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(settingsSectionProvider(category));
    final canView = ref.watch(permissionsProvider).canViewPlatformSettings;

    return Scaffold(
      appBar: AppBar(
        title: Text(section.valueOrNull?.category.labelFor(_arabic(context)) ??
            context.tr('platformSettings')),
      ),
      body: !canView
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: context.tr('noPermissionTitle'),
              message: context.tr('noPermissionMessage'),
            )
          : section.when(
              loading: () => const LoadingView(),
              error: (error, stack) => ErrorView(
                message: _message(context, error),
                onRetry: () =>
                    ref.invalidate(settingsSectionProvider(category)),
              ),
              data: (data) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(settingsSectionProvider(category)),
                child: _SectionForm(
                  category: category,
                  section: data,
                  isArabic: _arabic(context),
                ),
              ),
            ),
    );
  }

  static bool _arabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static String _message(BuildContext context, Object error) {
    if (error is ApiException && error.message.isNotEmpty) return error.message;
    return context.tr('errorGeneric');
  }
}

class _SectionForm extends ConsumerStatefulWidget {
  const _SectionForm({
    required this.category,
    required this.section,
    required this.isArabic,
  });

  final String category;
  final SettingsSection section;
  final bool isArabic;

  @override
  ConsumerState<_SectionForm> createState() => _SectionFormState();
}

class _SectionFormState extends ConsumerState<_SectionForm> {
  late List<SettingDefinition> _settings;
  late Map<String, Object?> _values;
  late Map<String, TextEditingController> _controllers;
  final Set<String> _dirty = <String>{};
  final Map<String, String> _fieldErrors = <String, String>{};
  bool _saving = false;

  bool get _canEdit {
    final permissions = widget.section.permissions;

    if (widget.category == 'security' || widget.category == 'maintenance') {
      return permissions.security;
    }

    if (widget.category == 'features') return permissions.features;

    return permissions.update;
  }

  bool get _canEditSecrets =>
      _canEdit && widget.section.permissions.secrets;

  @override
  void initState() {
    super.initState();
    _adopt(widget.section.category.settings);
  }

  void _adopt(List<SettingDefinition> settings) {
    _settings = settings;
    _values = <String, Object?>{};
    _controllers = <String, TextEditingController>{};

    for (final setting in settings) {
      _values[setting.field] = setting.value;

      if (setting.isText || setting.isSecret) {
        _controllers[setting.field] =
            TextEditingController(text: _text(setting.value));
      }
    }

    _dirty.clear();
    _fieldErrors.clear();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<SettingDefinition>>{};

    for (final setting in _settings) {
      groups.putIfAbsent(setting.group, () => <SettingDefinition>[]).add(setting);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              if (!_canEdit) ...[
                StatusBanner(
                  title: context.tr('platformSettingsReadOnlyTitle'),
                  message: context.tr('platformSettingsReadOnlyBody'),
                  tone: StatusBannerTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_settings.isEmpty)
                EmptyState(
                  icon: Icons.tune_rounded,
                  title: context.tr('platformSettingsEmptySection'),
                )
              else
                for (final entry in groups.entries) ...[
                  Text(
                    _groupLabel(context, entry.key),
                    style: context.texts.labelLarge?.copyWith(
                      color: context.dukavo.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var index = 0;
                            index < entry.value.length;
                            index++) ...[
                          _SettingRow(
                            setting: entry.value[index],
                            value: _values[entry.value[index].field],
                            controller:
                                _controllers[entry.value[index].field],
                            error:
                                _fieldErrors[entry.value[index].field],
                            enabled: _canEdit &&
                                (entry.value[index].editable ||
                                    (entry.value[index].isSecret &&
                                        _canEditSecrets)),
                            secretWritable: _canEditSecrets,
                            isArabic: widget.isArabic,
                            onChanged: (value) => _change(
                              entry.value[index],
                              value,
                            ),
                            onReset: entry.value[index].fromDatabase
                                ? () => _reset(entry.value[index])
                                : null,
                          ),
                          if (index != entry.value.length - 1)
                            Divider(
                              height: 1,
                              indent: AppSpacing.md,
                              endIndent: AppSpacing.md,
                              color: context.dukavo.border,
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          ),
        ),
        if (_canEdit && _settings.isNotEmpty)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.dukavo.surface,
                border: Border(
                  top: BorderSide(color: context.dukavo.border),
                ),
              ),
              child: Row(
                children: [
                  if (_dirty.isNotEmpty)
                    Expanded(
                      child: Text(
                        context.tr('platformSettingsUnsaved', args: {
                          'count': _dirty.length,
                        }),
                        style: context.texts.bodySmall
                            ?.copyWith(color: context.dukavo.textSecondary),
                      ),
                    )
                  else
                    const Spacer(),
                  if (_dirty.isNotEmpty)
                    TextButton(
                      onPressed: _saving ? null : _discard,
                      child: Text(context.tr('discard')),
                    ),
                  const SizedBox(width: AppSpacing.xs),
                  AppButton(
                    label: context.tr('saveChanges'),
                    icon: Icons.check_rounded,
                    loading: _saving,
                    onPressed: _dirty.isEmpty ? null : _save,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _change(SettingDefinition setting, Object? value) {
    setState(() {
      _values[setting.field] = value;
      _dirty.add(setting.field);
      _fieldErrors.remove(setting.field);
    });
  }

  void _reset(SettingDefinition setting) {
    setState(() {
      _values[setting.field] = null;
      _dirty.add(setting.field);
      _controllers[setting.field]?.text = '';
      _fieldErrors.remove(setting.field);
    });
  }

  void _discard() {
    setState(() {
      for (final setting in _settings) {
        _values[setting.field] = setting.value;
        _controllers[setting.field]?.text = _text(setting.value);
      }
      _dirty.clear();
      _fieldErrors.clear();
    });
  }

  Future<void> _save() async {
    if (_saving || _dirty.isEmpty) return;

    final payload = <String, Object?>{};

    for (final field in _dirty) {
      final setting = _settings.firstWhere((entry) => entry.field == field);

      if (setting.isSecret) {
        final raw = _values[field];
        if (raw == null) {
          payload[field] = null;
        } else {
          final text = '$raw';
          if (text.trim().isEmpty) continue;
          payload[field] = text;
        }
        continue;
      }

      if (!setting.editable) continue;

      payload[field] = _payloadValue(setting, _values[field]);
    }

    if (payload.isEmpty) {
      setState(_dirty.clear);
      return;
    }

    setState(() => _saving = true);

    try {
      final updated = await ref
          .read(settingsActionsProvider)
          .save(widget.category, payload);

      if (!mounted) return;

      setState(() {
        _saving = false;
        _adopt(updated.category.settings);
      });
      AppSnack.show(context, context.tr('platformSettingsSaved'));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        if (error is ApiException && error.fields != null) {
          for (final entry in error.fields!.entries) {
            final field = entry.key.startsWith('values.')
                ? entry.key.substring('values.'.length)
                : entry.key;
            if (entry.value.isNotEmpty) {
              _fieldErrors[field] = entry.value.first;
            }
          }
        }
      });
      AppSnack.show(context, _message(context, error), isError: true);
    }
  }

  static Object? _payloadValue(SettingDefinition setting, Object? value) {
    if (value == null) return null;

    if (setting.isInteger) {
      final number = value is num ? value.toInt() : int.tryParse('$value');
      return number ?? value;
    }

    if (setting.isDecimal) {
      final number = value is num ? value.toDouble() : double.tryParse('$value');
      return number ?? value;
    }

    if (setting.isBoolean) return value == true;

    if (setting.isMultiSelect) {
      return value is List ? value.map((entry) => '$entry').toList() : <String>[];
    }

    return '$value';
  }

  static String _text(Object? value) {
    if (value == null) return '';
    if (value is bool) return value ? 'true' : 'false';
    if (value is List) return value.join(', ');
    return '$value';
  }

  static String _message(BuildContext context, Object error) {
    if (error is ApiException && error.message.isNotEmpty) return error.message;
    return context.tr('errorGeneric');
  }

  static String _groupLabel(BuildContext context, String group) {
    final key = switch (group) {
      'identity' => 'settingsGroupIdentity',
      'application' => 'settingsGroupApplication',
      'brand' => 'settingsGroupBrand',
      'contact' => 'settingsGroupContact',
      'format' => 'settingsGroupFormat',
      'language' => 'settingsGroupLanguage',
      'number' => 'settingsGroupNumber',
      'password' => 'settingsGroupPassword',
      'rate_limits' => 'settingsGroupRateLimits',
      'region' => 'settingsGroupRegion',
      'routing' => 'settingsGroupRouting',
      'runtime' => 'settingsGroupRuntime',
      'session' => 'settingsGroupSession',
      'social' => 'settingsGroupSocial',
      'state' => 'settingsGroupState',
      'transport' => 'settingsGroupTransport',
      'driver' => 'settingsGroupDriver',
      _ => 'settingsGroupGeneral',
    };

    return context.tr(key);
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.setting,
    required this.value,
    required this.controller,
    required this.error,
    required this.enabled,
    required this.secretWritable,
    required this.isArabic,
    required this.onChanged,
    this.onReset,
  });

  final SettingDefinition setting;
  final Object? value;
  final TextEditingController? controller;
  final String? error;
  final bool enabled;
  final bool secretWritable;
  final bool isArabic;
  final ValueChanged<Object?> onChanged;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
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
                    Text(
                      setting.labelFor(isArabic),
                      style: context.texts.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (setting.descriptionFor(isArabic).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        setting.descriptionFor(isArabic),
                        style: context.texts.bodySmall?.copyWith(
                          color: context.dukavo.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onReset != null && enabled)
                IconButton(
                  tooltip: context.tr('platformSettingsClearOverride'),
                  visualDensity: VisualDensity.compact,
                  onPressed: onReset,
                  icon: const Icon(Icons.settings_backup_restore, size: 20),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _control(context),
          const SizedBox(height: AppSpacing.xxs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _SourceChip(setting: setting),
              if (setting.requiresRestart)
                Text(
                  context.tr('platformSettingsRequiresRestart'),
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.dukavo.textMuted),
                ),
              if (setting.isSecret && setting.secretHint != null)
                Text(
                  context.tr('platformSettingsSecretHint',
                      args: {'hint': setting.secretHint}),
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.dukavo.textMuted),
                ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              error!,
              style: context.texts.bodySmall
                  ?.copyWith(color: context.dukavo.danger),
            ),
          ],
        ],
      ),
    );
  }

  Widget _control(BuildContext context) {
    final editable = enabled && setting.editable;

    if (setting.isBoolean) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        value: value == true,
        onChanged: editable ? onChanged : null,
        title: Text(value == true
            ? context.tr('enabled')
            : context.tr('disabled')),
      );
    }

    if (setting.isSelect) {
      final options = setting.options;
      final current = value == null ? null : '$value';

      return DropdownButtonFormField<String>(
        initialValue: options.contains(current) ? current : null,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
        ),
        hint: Text(context.tr('platformSettingsChooseOption')),
        items: [
          for (final option in options)
            DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
        ],
        onChanged: editable ? onChanged : null,
      );
    }

    if (setting.isMultiSelect) {
      final raw = value;
      final selected = <String>{
        if (raw is List) ...raw.map((entry) => '$entry'),
      };

      return Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xxs,
        children: [
          for (final option in setting.options)
            FilterChip(
              label: Text(option),
              selected: selected.contains(option),
              onSelected: editable
                  ? (isSelected) {
                      final next = <String>{...selected};
                      if (isSelected) {
                        next.add(option);
                      } else {
                        next.remove(option);
                      }
                      onChanged(next.toList());
                    }
                  : null,
            ),
        ],
      );
    }

    final secret = setting.isSecret;

    return AppTextField(
      controller: controller,
      enabled: secret ? editable && secretWritable : editable,
      obscureText: secret,
      maxLines: setting.isText ? 4 : 1,
      maxLength: setting.maxLength,
      keyboardType: setting.isInteger || setting.isDecimal
          ? const TextInputType.numberWithOptions(signed: true, decimal: true)
          : TextInputType.text,
      hint: secret && setting.configured
          ? context.tr('platformSettingsSecretPlaceholder')
          : null,
      helper: setting.min != null || setting.max != null
          ? context.tr('platformSettingsRange', args: {
              'min': setting.min ?? '—',
              'max': setting.max ?? '—',
            })
          : null,
      onChanged: editable ? onChanged : null,
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.setting});

  final SettingDefinition setting;

  @override
  Widget build(BuildContext context) {
    final key = switch (setting.source) {
      'database' => 'platformSettingsSourceDatabase',
      'environment' => 'platformSettingsSourceEnvironment',
      _ => 'platformSettingsSourceDefault',
    };

    final tone = switch (setting.source) {
      'database' => context.dukavo.primary,
      'environment' => context.dukavo.textMuted,
      _ => context.dukavo.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Text(
        context.tr(key),
        style: context.texts.labelSmall?.copyWith(color: tone),
      ),
    );
  }
}
