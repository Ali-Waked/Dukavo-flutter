import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../stores/application/store_controller.dart';

final _isoDate = DateFormat('yyyy-MM-dd');

/// Merchant Copilot: a grounded answer over the dashboard's own aggregates.
///
/// The server supplies the facts, the prompt and the schema; this screen only
/// collects the question, the optional store and the period. It never computes
/// a metric of its own and it prints the server's data gaps verbatim.
class MerchantCopilotScreen extends ConsumerStatefulWidget {
  const MerchantCopilotScreen({super.key});

  @override
  ConsumerState<MerchantCopilotScreen> createState() =>
      _MerchantCopilotScreenState();
}

class _MerchantCopilotScreenState extends ConsumerState<MerchantCopilotScreen> {
  final TextEditingController _question = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _storeId;
  DateTimeRange? _range;
  JsonMap? _result;
  bool _asking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final until = DateTime.now();
    _range = DateTimeRange(
      start: until.subtract(const Duration(days: 29)),
      end: until,
    );
  }

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canUseAi) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('aiCopilot'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final stores = ref.watch(storeOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('aiCopilot'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            InfoBanner(
              icon: Icons.verified_outlined,
              message: context.tr('aiCopilotHint'),
            ),
            const SizedBox(height: AppSpacing.md),
            stores.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : DropdownButtonFormField<int?>(
                      key: ValueKey('copilot-store-$_storeId'),
                      initialValue: _storeId,
                      decoration: InputDecoration(
                        labelText: context.tr('storeFilter'),
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(context.tr('all')),
                        ),
                        for (final store in list)
                          DropdownMenuItem<int?>(
                            value: store.id,
                            child: Text(store.name),
                          ),
                      ],
                      onChanged: (value) => setState(() => _storeId = value),
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickRange,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.tr('period'),
                  suffixIcon: const Icon(Icons.date_range_outlined),
                ),
                child: Text(_rangeLabel(context)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _question,
              minLines: 3,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: context.tr('yourQuestion'),
                hintText: context.tr('aiCopilotQuestionHint'),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return context.tr('requiredField');
                if (text.length > 1000) return context.tr('questionTooLong');
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.tr('askCopilot'),
              icon: Icons.auto_awesome,
              expand: true,
              loading: _asking,
              onPressed: _ask,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              StatusBanner(tone: StatusBannerTone.error, message: _error!),
            ],
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _CopilotAnswer(result: _result!),
            ],
          ],
        ),
      ),
    );
  }

  String _rangeLabel(BuildContext context) {
    final range = _range;
    if (range == null) return context.tr('selectPeriod');
    return '${_isoDate.format(range.start)} → ${_isoDate.format(range.end)}';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range,
      helpText: context.tr('selectPeriod'),
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _ask() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final range = _range;
    if (range == null) return;
    setState(() {
      _asking = true;
      _error = null;
    });
    try {
      final data = await ref.read(apiClientProvider).post<JsonMap>(
        ApiPaths.aiMerchantCopilot,
        body: {
          'question': _question.text.trim(),
          if (_storeId != null) 'store_id': _storeId,
          'from': _isoDate.format(range.start),
          'until': _isoDate.format(range.end),
        },
        decode: (value) =>
            value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
      );
      if (!mounted) return;
      setState(() {
        _result = data;
        _asking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _asking = false;
        _error = error is ApiException ? error.message : null;
      });
    }
  }
}

class _CopilotAnswer extends StatelessWidget {
  const _CopilotAnswer({required this.result});

  final JsonMap result;

  @override
  Widget build(BuildContext context) {
    final period = _mapOf(result['period']);
    final scope = _mapOf(result['scope']);
    final answer = '${result['answer'] ?? ''}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          title: context.tr('answer'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answer.isEmpty ? context.tr('noAnswerReturned') : answer,
                style: context.texts.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  if (scope['store_name'] != null)
                    _Meta(
                      label: context.tr('store'),
                      value: '${scope['store_name']}',
                    ),
                  if (scope['currency'] != null)
                    _Meta(
                      label: context.tr('currency'),
                      value: '${scope['currency']}',
                    ),
                  if (period['from'] != null && period['until'] != null)
                    _Meta(
                      label: context.tr('period'),
                      value: '${period['from']} → ${period['until']}',
                    ),
                  if (period['timezone'] != null)
                    _Meta(
                      label: context.tr('timezone'),
                      value: '${period['timezone']}',
                    ),
                ],
              ),
            ],
          ),
        ),
        _StringListCard(
          titleKey: 'factsUsed',
          icon: Icons.fact_check_outlined,
          values: _strings(result['facts_used']),
        ),
        _StringListCard(
          titleKey: 'missingData',
          icon: Icons.help_outline_rounded,
          values: _strings(result['missing_or_insufficient']),
          tone: StatusBannerTone.warning,
        ),
        _StringListCard(
          titleKey: 'estimatesAndRecommendations',
          icon: Icons.tips_and_updates_outlined,
          values: _strings(result['estimates_and_recommendations']),
        ),
        _ObjectListCard(
          titleKey: 'actionPreviews',
          icon: Icons.play_circle_outline,
          values: _maps(result['action_previews']),
        ),
        _ObjectListCard(
          titleKey: 'metricExplanations',
          icon: Icons.info_outline,
          values: _maps(result['metric_explanations']),
        ),
        _StringListCard(
          titleKey: 'dataGaps',
          icon: Icons.report_outlined,
          values: _strings(result['data_gaps']),
          tone: StatusBannerTone.warning,
        ),
      ],
    );
  }
}

/// Dashboard insights: the server's briefing over tenant aggregates.
class MerchantInsightsScreen extends ConsumerStatefulWidget {
  const MerchantInsightsScreen({super.key});

  @override
  ConsumerState<MerchantInsightsScreen> createState() =>
      _MerchantInsightsScreenState();
}

class _MerchantInsightsScreenState extends ConsumerState<MerchantInsightsScreen> {
  int? _storeId;
  JsonMap? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ref.read(apiClientProvider).get<JsonMap>(
            ApiPaths.aiInsights,
            query: {
              if (_storeId != null) 'store_id': _storeId,
            },
            decode: (value) => value is Map
                ? Map<String, dynamic>.from(value)
                : <String, dynamic>{},
          );
      if (!mounted) return;
      setState(() {
        _result = data;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException ? error.message : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionsProvider);
    if (!permissions.canUseAi) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('aiInsights'))),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: context.tr('noPermissionTitle'),
          message: context.tr('noPermissionMessage'),
        ),
      );
    }
    final stores = ref.watch(storeOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('aiInsights')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          stores.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : DropdownButtonFormField<int?>(
                    key: ValueKey('insights-store-$_storeId'),
                    initialValue: _storeId,
                    decoration: InputDecoration(
                      labelText: context.tr('storeFilter'),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(context.tr('all')),
                      ),
                      for (final store in list)
                        DropdownMenuItem<int?>(
                          value: store.id,
                          child: Text(store.name),
                        ),
                    ],
                    onChanged: _loading
                        ? null
                        : (value) {
                            setState(() => _storeId = value);
                            _load();
                          },
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: LoadingView(),
            )
          else if (_error != null)
            ErrorView(message: _error!, onRetry: _load)
          else if (_result != null) ...[
            SectionCard(
              title: context.tr('summary'),
              child: Text(
                '${_result!['summary'] ?? ''}'.trim().isEmpty
                    ? context.tr('noAnswerReturned')
                    : '${_result!['summary']}',
                style: context.texts.bodyMedium,
              ),
            ),
            _ObjectListCard(
              titleKey: 'highlights',
              icon: Icons.insights_outlined,
              values: _maps(_result!['highlights']),
              valuesAsHighlights: true,
            ),
            _ObjectListCard(
              titleKey: 'recommendations',
              icon: Icons.tips_and_updates_outlined,
              values: _maps(_result!['recommendations']),
            ),
            _StringListCard(
              titleKey: 'dataGaps',
              icon: Icons.report_outlined,
              values: _strings(_result!['data_gaps']),
              tone: StatusBannerTone.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _StringListCard extends StatelessWidget {
  const _StringListCard({
    required this.titleKey,
    required this.icon,
    required this.values,
    this.tone,
  });

  final String titleKey;
  final IconData icon;
  final List<String> values;
  final StatusBannerTone? tone;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SectionCard(
        title: context.tr(titleKey),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final value in values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 16, color: context.dukavo.textMuted),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(value, style: context.texts.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ObjectListCard extends StatelessWidget {
  const _ObjectListCard({
    required this.titleKey,
    required this.icon,
    required this.values,
    this.valuesAsHighlights = false,
  });

  final String titleKey;
  final IconData icon;
  final List<JsonMap> values;
  final bool valuesAsHighlights;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: SectionCard(
        title: context.tr(titleKey),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final value in values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: context.scheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${value['title'] ?? value['label'] ?? value['metric'] ?? value['type'] ?? ''}',
                                  style: context.texts.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (valuesAsHighlights &&
                                  value['severity'] != null)
                                StatusChip(
                                  status: '${value['severity']}',
                                  compact: true,
                                ),
                            ],
                          ),
                          if (value['detail'] != null ||
                              value['reason'] != null ||
                              value['definition'] != null)
                            Text(
                              '${value['detail'] ?? value['reason'] ?? value['definition']}',
                              style: context.texts.bodySmall?.copyWith(
                                color: context.dukavo.textSecondary,
                              ),
                            ),
                          if (value['link_hint'] != null)
                            Text(
                              '${value['link_hint']}',
                              style: context.texts.labelSmall?.copyWith(
                                color: context.dukavo.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.texts.labelSmall?.copyWith(
            color: context.dukavo.textMuted,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: context.texts.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

List<String> _strings(Object? value) {
  if (value is List) {
    return value
        .map((entry) => '$entry'.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

List<JsonMap> _maps(Object? value) {
  if (value is List) {
    return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  return const <JsonMap>[];
}

JsonMap _mapOf(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
