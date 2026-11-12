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

/// Integration health.
///
/// Reading shows the last recorded probe. A check calls the provider, so it only
/// runs from an explicit tap and only for an operator with the test grant.
class PlatformSettingsHealthScreen extends ConsumerStatefulWidget {
  const PlatformSettingsHealthScreen({super.key});

  @override
  ConsumerState<PlatformSettingsHealthScreen> createState() =>
      _PlatformSettingsHealthScreenState();
}

class _PlatformSettingsHealthScreenState
    extends ConsumerState<PlatformSettingsHealthScreen> {
  String? _busy;

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(integrationHealthProvider);
    final permissions = ref.watch(permissionsProvider);
    final canTest = permissions.canTestPlatformIntegrations;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('platformSettingsHealthTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: () => ref.invalidate(integrationHealthProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: health.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: _message(context, error),
          onRetry: () => ref.invalidate(integrationHealthProvider),
        ),
        data: (data) {
          final isArabic = Localizations.localeOf(context).languageCode == 'ar';
          final locale = Localizations.localeOf(context).toLanguageTag();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(integrationHealthProvider),
            child: ListView(
              padding: AppSpacing.page,
              children: [
                StatusBanner(
                  title: context.tr('platformSettingsHealthReadTitle'),
                  message: context.tr('platformSettingsHealthReadBody'),
                  tone: StatusBannerTone.info,
                ),
                const SizedBox(height: AppSpacing.md),
                if (data.isEmpty)
                  EmptyState(
                    icon: Icons.monitor_heart_outlined,
                    title: context.tr('platformSettingsHealthEmpty'),
                  )
                else
                  for (final integration in data) ...[
                    _IntegrationCard(
                      integration: integration,
                      isArabic: isArabic,
                      locale: locale,
                      canTest: canTest,
                      busy: _busy == integration.key,
                      locked: _busy != null,
                      onTest: () => _check(integration),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _check(IntegrationHealth integration) async {
    setState(() => _busy = integration.key);

    try {
      await ref
          .read(settingsActionsProvider)
          .checkIntegration(integration.key);
      if (!mounted) return;
      AppSnack.show(
        context,
        context.tr('platformSettingsHealthChecked',
            args: {'name': integration.label}),
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
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.integration,
    required this.isArabic,
    required this.locale,
    required this.canTest,
    required this.busy,
    required this.locked,
    required this.onTest,
  });

  final IntegrationHealth integration;
  final bool isArabic;
  final String locale;
  final bool canTest;
  final bool busy;
  final bool locked;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final checked = integration.checkedAt;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  integration.labelFor(isArabic),
                  style: context.texts.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              StatusChip(
                status: _status(integration.tone),
                label: context
                    .tr('platformSettingsHealthState${_stateSuffix(integration.state)}'),
                compact: true,
              ),
            ],
          ),
          if ((integration.summary ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              integration.summary!,
              style: context.texts.bodySmall?.copyWith(
                color: context.dukavo.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  checked == null
                      ? context.tr('platformSettingsHealthNever')
                      : context.tr('platformSettingsHealthCheckedAt', args: {
                          'when': Formatters.dateTime(checked, locale: locale),
                        }),
                  style: context.texts.labelSmall
                      ?.copyWith(color: context.dukavo.textMuted),
                ),
              ),
              if (canTest)
                AppButton(
                  label: context.tr('platformSettingsHealthTest'),
                  variant: AppButtonVariant.outlined,
                  loading: busy,
                  height: 36,
                  icon: Icons.play_arrow_rounded,
                  onPressed: locked ? null : onTest,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _status(String tone) {
    return switch (tone) {
      'success' => 'active',
      'warning' => 'pending',
      'danger' => 'failed',
      'neutral' => 'inactive',
      _ => 'info',
    };
  }

  static String _stateSuffix(String state) {
    final buffer = StringBuffer();
    var upper = true;

    for (final rune in state.runes) {
      final character = String.fromCharCode(rune);
      if (character == '_') {
        upper = true;
        continue;
      }
      buffer.write(upper ? character.toUpperCase() : character);
      upper = false;
    }

    return buffer.toString();
  }
}
