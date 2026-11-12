import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_controller.dart';
import '../domain/settings_models.dart';

/// Configuration history, read from the shared audit log.
///
/// Rows are already redacted by the server: a secret appears as configured with
/// a last-four hint, never as a value. Nothing on this screen can un-redact it.
class PlatformSettingsHistoryScreen extends ConsumerStatefulWidget {
  const PlatformSettingsHistoryScreen({super.key});

  @override
  ConsumerState<PlatformSettingsHistoryScreen> createState() =>
      _PlatformSettingsHistoryScreenState();
}

class _PlatformSettingsHistoryScreenState
    extends ConsumerState<PlatformSettingsHistoryScreen> {
  final TextEditingController _filter = TextEditingController();
  int _limit = 50;
  String? _key;

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    final query = SettingsHistoryQuery(key: _key, limit: _limit);
    final history = ref.watch(settingsHistoryProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('platformSettingsHistoryTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(settingsHistoryProvider(query)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !permissions.canViewPlatformConfiguration
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: context.tr('noPermissionTitle'),
              message: context.tr('noPermissionMessage'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _filter,
                              label: context.tr('platformSettingsHistoryFilter'),
                              hint: context.tr(
                                  'platformSettingsHistoryFilterHint'),
                              textInputAction: TextInputAction.search,
                              prefixIcon: Icons.search_rounded,
                              onSubmitted: (value) =>
                                  setState(() => _key = _clean(value)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: AppButton(
                              label: context.tr('apply'),
                              variant: AppButtonVariant.outlined,
                              onPressed: () => setState(
                                () => _key = _clean(_filter.text),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Text(
                            context.tr('platformSettingsHistoryRows'),
                            style: context.texts.labelMedium
                                ?.copyWith(color: context.dukavo.textSecondary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          for (final limit in const [25, 50, 100, 200])
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: AppSpacing.xxs,
                              ),
                              child: ChoiceChip(
                                label: Text('$limit'),
                                selected: _limit == limit,
                                onSelected: (_) =>
                                    setState(() => _limit = limit),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: history.when(
                    loading: () => const LoadingView(),
                    error: (error, stack) => ErrorView(
                      message: _message(context, error),
                      onRetry: () =>
                          ref.invalidate(settingsHistoryProvider(query)),
                    ),
                    data: (changes) => _list(context, changes),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _list(BuildContext context, List<SettingsHistoryEntry> changes) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = Localizations.localeOf(context).toLanguageTag();

    return RefreshIndicator(
      onRefresh: () async =>
          ref.invalidate(settingsHistoryProvider(
            SettingsHistoryQuery(key: _key, limit: _limit),
          )),
      child: ListView(
        padding: AppSpacing.page,
        children: [
          if (changes.isEmpty)
            EmptyState(
              icon: Icons.history_rounded,
              title: _key == null
                  ? context.tr('platformSettingsHistoryEmpty')
                  : context.tr('platformSettingsHistoryEmptyFiltered'),
              message: _key == null
                  ? context.tr('platformSettingsHistoryEmptyBody')
                  : null,
            )
          else
            for (final change in changes) ...[
              _HistoryRow(
                change: change,
                isArabic: isArabic,
                locale: locale,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
        ],
      ),
    );
  }

  static String? _clean(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _message(BuildContext context, Object error) {
    if (error is ApiException && error.message.isNotEmpty) return error.message;
    return context.tr('errorGeneric');
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.change,
    required this.isArabic,
    required this.locale,
  });

  final SettingsHistoryEntry change;
  final bool isArabic;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final oldValue = _side(context, change.oldValue);
    final newValue = _side(context, change.newValue);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  change.actionLabel.isEmpty
                      ? change.action
                      : change.actionLabel,
                  style: context.texts.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (change.createdAt != null)
                Text(
                  Formatters.dateTime(change.createdAt, locale: locale),
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.dukavo.textMuted),
                ),
            ],
          ),
          if (change.key != null) ...[
            const SizedBox(height: 2),
            Text(
              change.key!,
              style: context.texts.labelMedium?.copyWith(
                color: context.dukavo.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Flexible(
                child: _ValuePill(text: oldValue, muted: true),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.grey),
              ),
              Flexible(
                child: _ValuePill(text: newValue, muted: false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            change.actorName == null
                ? context.tr('platformSettingsHistorySystem')
                : change.actorName!,
            style: context.texts.labelSmall
                ?.copyWith(color: context.dukavo.textMuted),
          ),
        ],
      ),
    );
  }

  String _side(BuildContext context, SettingAuditValue? value) {
    if (value == null) return context.tr('platformSettingsHistoryNone');

    final hint = value.secretHint;
    if (hint != null) {
      return context.tr('platformSettingsHistorySecret',
          args: {'hint': hint});
    }

    final raw = value.value;
    if (raw == null || '$raw'.trim().isEmpty) {
      return context.tr('platformSettingsHistoryNone');
    }

    return '$raw';
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.text, required this.muted});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.dukavo.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: context.dukavo.border),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.texts.bodySmall?.copyWith(
          color: muted
              ? context.dukavo.textSecondary
              : context.dukavo.textPrimary,
          fontWeight: muted ? FontWeight.w400 : FontWeight.w600,
        ),
      ),
    );
  }
}
