import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

/// Platform availability switches.
///
/// A flag withdraws a capability from every tenant. It is not a subscription
/// check, so nothing here is labelled a plan or an entitlement.
class PlatformSettingsFeaturesScreen extends ConsumerStatefulWidget {
  const PlatformSettingsFeaturesScreen({super.key});

  @override
  ConsumerState<PlatformSettingsFeaturesScreen> createState() =>
      _PlatformSettingsFeaturesScreenState();
}

class _PlatformSettingsFeaturesScreenState
    extends ConsumerState<PlatformSettingsFeaturesScreen> {
  String _query = '';
  String? _busy;
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final features = ref.watch(platformFeaturesProvider);
    final permissions = ref.watch(permissionsProvider);
    final canManage = permissions.canManagePlatformFeatures;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('platformSettingsFeaturesTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(platformFeaturesProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: features.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(context, error),
          onRetry: () => ref.invalidate(platformFeaturesProvider),
        ),
        data: (data) => _body(context, data, canManage),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    List<PlatformFeatureFlag> features,
    bool canManage,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final enabled = features.where((feature) => feature.enabled).length;
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? features
        : features
            .where((feature) =>
                feature.key.toLowerCase().contains(query) ||
                feature.labelFor(isArabic).toLowerCase().contains(query))
            .toList();

    final groups = <String, List<PlatformFeatureFlag>>{};
    for (final feature in visible) {
      groups.putIfAbsent(feature.group, () => <PlatformFeatureFlag>[]).add(feature);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(platformFeaturesProvider),
      child: ListView(
        padding: AppSpacing.page,
        children: [
          StatusBanner(
            title: context.tr('platformSettingsFeaturesNoteTitle'),
            message: context.tr('platformSettingsFeaturesNoteBody'),
            tone: StatusBannerTone.info,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                context.tr('platformSettingsFeaturesEnabled',
                    args: {'count': enabled}),
                style: context.texts.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.tr('platformSettingsFeaturesTotal',
                    args: {'count': features.length}),
                style: context.texts.bodySmall
                    ?.copyWith(color: context.dukavo.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SearchField(
            controller: _search,
            hint: context.tr('platformSettingsFeaturesSearch'),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.md),
          if (visible.isEmpty)
            EmptyState(
              icon: Icons.toggle_off_outlined,
              title: context.tr('platformSettingsFeaturesEmptyTitle'),
              message: context.tr('platformSettingsFeaturesEmptyBody'),
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
                      _FeatureRow(
                        feature: entry.value[index],
                        isArabic: isArabic,
                        enabled: canManage && _busy == null,
                        busy: _busy == entry.value[index].key,
                        onChanged: (next) => _toggle(entry.value[index], next),
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
    );
  }

  Future<void> _toggle(PlatformFeatureFlag feature, bool enabled) async {
    setState(() => _busy = feature.key);

    try {
      await ref
          .read(settingsActionsProvider)
          .setFeature(feature.key, enabled);
      if (!mounted) return;
      AppSnack.show(
        context,
        enabled
            ? context.tr('platformSettingsFeatureEnabled',
                args: {'name': feature.label})
            : context.tr('platformSettingsFeatureDisabled',
                args: {'name': feature.label}),
      );
    } catch (error) {
      if (mounted) AppSnack.show(context, _message(context, error), isError: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  static String _message(BuildContext context, Object error) {
    if (error is ApiException && error.message.isNotEmpty) return error.message;
    return context.tr('errorGeneric');
  }

  static String _groupLabel(BuildContext context, String group) {
    final key = switch (group) {
      'intelligence' => 'featureGroupIntelligence',
      'channels' => 'featureGroupChannels',
      'communication' => 'featureGroupCommunication',
      'operations' => 'featureGroupOperations',
      'commerce' => 'featureGroupCommerce',
      'growth' => 'featureGroupGrowth',
      _ => 'featureGroupOperations',
    };

    return context.tr(key);
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.feature,
    required this.isArabic,
    required this.enabled,
    required this.busy,
    required this.onChanged,
  });

  final PlatformFeatureFlag feature;
  final bool isArabic;
  final bool enabled;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.labelFor(isArabic),
                  style: context.texts.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (feature.descriptionFor(isArabic).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    feature.descriptionFor(isArabic),
                    style: context.texts.bodySmall?.copyWith(
                      color: context.dukavo.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  feature.key,
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.dukavo.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (busy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: feature.enabled,
              onChanged: enabled ? onChanged : null,
            ),
        ],
      ),
    );
  }
}
