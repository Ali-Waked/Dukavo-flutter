import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/resources/json_resource.dart';
import '../../../core/resources/resource_screens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import 'merchant_specs.dart';

final recoverySummaryProvider =
    FutureProvider.autoDispose<JsonResource>((ref) async {
  final data = await ref.read(apiClientProvider).get<JsonMap>(
        ApiPaths.recoverySummary,
        decode: (value) => value is Map
            ? Map<String, dynamic>.from(value)
            : const <String, dynamic>{},
      );
  return JsonResource(data);
});

/// Lost-sale recovery: the funnel at the top, the opportunities below.
///
/// The summary is a separate request from the list so the page paints even when
/// the list is still paginating, and so a failed summary cannot hide the rows an
/// agent needs to work.
class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResourceListScreen(
      spec: recoverySpec,
      header: const _RecoverySummaryCard(),
    );
  }
}

class _RecoverySummaryCard extends ConsumerWidget {
  const _RecoverySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recoverySummaryProvider);
    final theme = Theme.of(context);
    return async.when(
      loading: () => const SectionCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stack) => SectionCard(
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('recoverySummaryUnavailable'),
                style: theme.textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: context.tr('retry'),
              onPressed: () => ref.invalidate(recoverySummaryProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
      data: (summary) {
        final counts = JsonResource(
          summary.map('counts') ?? const <String, dynamic>{},
        );
        final openValues = _moneyList(summary.data['open_value']);
        final recovered = _moneyList(summary.data['recovered_revenue']);
        return SectionCard(
          title: context.tr('recoverySummary'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill(
                    context,
                    context.tr('open'),
                    Formatters.number(counts.number('open') ?? 0),
                    AppColors.warning,
                  ),
                  _pill(
                    context,
                    context.tr('readyToRecover'),
                    Formatters.number(counts.number('eligible') ?? 0),
                    AppColors.info,
                  ),
                  _pill(
                    context,
                    context.tr('followUpSent'),
                    Formatters.number(counts.number('contacted') ?? 0),
                    theme.colorScheme.primary,
                  ),
                  _pill(
                    context,
                    context.tr('recovered'),
                    Formatters.number(counts.number('recovered') ?? 0),
                    AppColors.success,
                  ),
                  _pill(
                    context,
                    context.tr('responded'),
                    Formatters.number(counts.number('responded') ?? 0),
                    AppColors.success,
                  ),
                ],
              ),
              if (openValues.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final entry in openValues)
                  KeyValueRow(
                    label:
                        '${context.tr('openValue')} · ${entry['currency'] ?? ''}',
                    value: Formatters.currency(
                      (entry['total'] as num?)?.toDouble() ?? 0,
                      '${entry['currency'] ?? ''}',
                    ),
                  ),
              ],
              if (recovered.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final entry in recovered)
                  KeyValueRow(
                    label:
                        '${context.tr('recoveredRevenue')} · ${entry['currency'] ?? ''}',
                    value: Formatters.currency(
                      (entry['total'] as num?)?.toDouble() ?? 0,
                      '${entry['currency'] ?? ''}',
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _moneyList(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  Widget _pill(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
