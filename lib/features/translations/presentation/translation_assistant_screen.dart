import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/translation_controller.dart';
import '../domain/translation_domain.dart';

/// The mobile half of the AI translation assistant.
///
/// The workflow is deliberately identical to the web surface: generate a
/// proposal, review it, edit or reject it, and only then approve it. Nothing on
/// this screen publishes copy implicitly.
class TranslationAssistantScreen extends ConsumerStatefulWidget {
  const TranslationAssistantScreen({
    super.key,
    required this.surface,
    required this.entity,
    required this.recordId,
    this.entityName,
  });

  final String surface;
  final String entity;
  final int recordId;
  final String? entityName;

  @override
  ConsumerState<TranslationAssistantScreen> createState() =>
      _TranslationAssistantScreenState();
}

class _TranslationAssistantScreenState
    extends ConsumerState<TranslationAssistantScreen> {
  final Set<String> _fields = <String>{};
  final Set<String> _targets = <String>{};
  final Set<int> _selectedRows = <int>{};

  String? _sourceOverride;
  String? _action;
  bool _initialized = false;

  TranslationTarget get _target => TranslationTarget(
        surface: widget.surface,
        entity: widget.entity,
        recordId: widget.recordId,
        sourceLocale: _sourceOverride,
      );

  TranslationTarget _targetForSource(String? source) => TranslationTarget(
        surface: widget.surface,
        entity: widget.entity,
        recordId: widget.recordId,
        sourceLocale: source,
      );

  void _syncSelections(TranslationOverview overview) {
    final fieldKeys = overview.fields.map((field) => field.key).toSet();
    final targetKeys = overview.targetLocales.toSet();

    if (!_initialized ||
        !_fields.every(fieldKeys.contains) ||
        (_fields.isEmpty && fieldKeys.isNotEmpty && !overview.isEmpty)) {
      _fields
        ..clear()
        ..addAll(fieldKeys);
    }

    if (!_initialized || !_targets.every(targetKeys.contains)) {
      _targets
        ..clear()
        ..addAll(targetKeys);
    }

    final selectable = <int>{};
    for (final fields in overview.translations.values) {
      for (final row in fields.values) {
        if (row.canBeSelected && row.id != null) selectable.add(row.id!);
      }
    }
    _selectedRows.removeWhere((id) => !selectable.contains(id));
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    final overviewAsync = ref.watch(translationOverviewProvider(target));
    final usage = ref.watch(translationUsageProvider(widget.surface)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('translationAssistant')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _action == null
                ? () {
                    ref.invalidate(translationOverviewProvider(target));
                    ref.invalidate(translationUsageProvider(widget.surface));
                  }
                : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: overviewAsync.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error is ApiException ? error.message : error.toString(),
          onRetry: () => ref.invalidate(translationOverviewProvider(target)),
        ),
        data: (overview) {
          _syncSelections(overview);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(translationOverviewProvider(target));
              ref.invalidate(translationUsageProvider(widget.surface));
              await ref.read(translationOverviewProvider(target).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                AppSpacing.xl,
              ),
              children: [
                _header(context, overview),
                const SizedBox(height: AppSpacing.md),
                _generationCard(context, overview),
                const SizedBox(height: AppSpacing.md),
                if (usage != null) _usageCard(context, usage),
                if (usage != null) const SizedBox(height: AppSpacing.md),
                _reviewCard(context, overview),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, TranslationOverview overview) {
    final name = overview.entity.name.isEmpty
        ? (widget.entityName ?? overview.entity.label)
        : overview.entity.name;

    return SectionCard(
      title: name,
      subtitle: '${overview.entity.label} · #${overview.entity.id}',
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.tr('translationReviewHint'),
              style: context.texts.bodySmall?.copyWith(
                color: context.dukavo.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusChip(
            status: _selectedRows.isEmpty ? 'draft' : 'active',
            label: _selectedRows.isEmpty
                ? context.tr('translationNoSelection')
                : context.tr(
                    'translationSelectedCount',
                    args: {'count': _selectedRows.length},
                  ),
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _generationCard(
    BuildContext context,
    TranslationOverview overview,
  ) {
    final source = _sourceOverride ?? overview.sourceLocale;
    final detection = overview.sourceDetection;
    final detectionLabel = detection.locale == null
        ? context.tr('translationSourceUnknown')
        : context.tr(
            'translationDetectedLanguage',
            args: {
              'language': translationLanguageLabel(detection.locale!),
              'confidence': (detection.confidence * 100).round(),
            },
          );

    return SectionCard(
      title: context.tr('translationGenerateTitle'),
      subtitle: context.tr('translationGenerateHint'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: source,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.tr('translationSourceLanguage'),
              prefixIcon: const Icon(Icons.translate, size: 20),
            ),
            items: [
              for (final locale in overview.enabledLocales)
                DropdownMenuItem(
                  value: locale,
                  child: Text(
                    '${translationLanguageLabel(locale)} ($locale)',
                  ),
                ),
            ],
            onChanged: _action == null
                ? (value) {
                    if (value == null || value == source) return;
                    setState(() {
                      _sourceOverride = value;
                      _selectedRows.clear();
                      _initialized = false;
                    });
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            detectionLabel,
            style: context.texts.bodySmall?.copyWith(
              color: context.dukavo.textMuted,
            ),
          ),
          if (overview.sourceRequired) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoBanner(
              title: context.tr('translationSourceRequired'),
              message: context.tr('translationSourceRequiredHint'),
              tone: InfoBannerTone.warning,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            context.tr('translationFields'),
            style: context.texts.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final field in overview.fields)
                FilterChip(
                  label: Text(field.label),
                  selected: _fields.contains(field.key),
                  onSelected: _action == null
                      ? (selected) => setState(() {
                            if (selected) {
                              _fields.add(field.key);
                            } else {
                              _fields.remove(field.key);
                            }
                          })
                      : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.tr('translationTargets'),
            style: context.texts.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (overview.targetLocales.isEmpty)
            Text(
              context.tr('translationNoTargets'),
              style: context.texts.bodySmall?.copyWith(
                color: context.dukavo.textMuted,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final locale in overview.targetLocales)
                  FilterChip(
                    label: Text(translationLanguageLabel(locale)),
                    selected: _targets.contains(locale),
                    onSelected: _action == null
                        ? (selected) => setState(() {
                              if (selected) {
                                _targets.add(locale);
                              } else {
                                _targets.remove(locale);
                              }
                            })
                        : null,
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: context.tr('translationGenerate'),
                  icon: Icons.auto_awesome,
                  loading: _action == 'generate',
                  onPressed: _action != null ||
                          source == null ||
                          _fields.isEmpty ||
                          _targets.isEmpty
                      ? null
                      : () => _generate(overview),
                ),
              ),
              if (_selectedRows.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: context.tr(
                      'translationApproveSelectedCount',
                      args: {'count': _selectedRows.length},
                    ),
                    icon: Icons.verified_outlined,
                    variant: AppButtonVariant.tonal,
                    loading: _action == 'approve-all',
                    onPressed:
                        _action == null ? () => _approveSelected(overview) : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _usageCard(BuildContext context, TranslationUsage usage) {
    return SectionCard(
      title: context.tr('translationUsageTitle'),
      child: Text(
        context.tr(
          'translationUsageSummary',
          args: {
            'requests': usage.requests,
            'tokens': usage.totalTokens,
            'cost': usage.estimatedCost.toStringAsFixed(4),
          },
        ),
        style: context.texts.bodySmall?.copyWith(
          color: context.dukavo.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _reviewCard(BuildContext context, TranslationOverview overview) {
    if (overview.targetLocales.isEmpty) {
      return SectionCard(
        title: context.tr('translationReviewTitle'),
        child: EmptyState(
          title: context.tr('translationNoTargets'),
          icon: Icons.translate,
        ),
      );
    }

    return SectionCard(
      title: context.tr('translationReviewTitle'),
      subtitle: context.tr('translationReviewHint'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final locale in overview.targetLocales) ...[
            _localeSection(context, overview, locale),
            if (locale != overview.targetLocales.last)
              const Divider(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _localeSection(
    BuildContext context,
    TranslationOverview overview,
    String locale,
  ) {
    final rows = overview.translations[locale] ?? const <String, TranslationRow>{};
    final fields = overview.fields
        .where((field) => rows.containsKey(field.key))
        .toList();
    final extraKeys = rows.keys
        .where((key) => !fields.any((field) => field.key == key))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${translationLanguageLabel(locale)} · $locale',
                style: context.texts.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (rows.values.any((row) => row.isStale))
              StatusChip(
                status: 'stale',
                label: context.tr('translationStale'),
                compact: true,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final field in fields) ...[
          _rowCard(context, overview, rows[field.key]!, field),
          const SizedBox(height: AppSpacing.sm),
        ],
        for (final key in extraKeys) ...[
          _rowCard(
            context,
            overview,
            rows[key]!,
            overview.field(key) ??
                TranslationFieldDefinition(
                  key: key,
                  label: key,
                  format: 'text',
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _rowCard(
    BuildContext context,
    TranslationOverview overview,
    TranslationRow row,
    TranslationFieldDefinition field,
  ) {
    final canReview = ref.watch(permissionsProvider).canReviewTranslations;
    final copy = row.translatedText?.trim();
    final published = row.publishedText?.trim();
    final source = overview.sources[field.key]?.trim();
    final showPublished = published != null &&
        published.isNotEmpty &&
        published != copy &&
        row.isStale;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: context.dukavo.surfaceLow,
        borderRadius: AppRadius.input,
        border: Border.all(color: context.dukavo.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (row.canBeSelected)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 4),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: row.id != null && _selectedRows.contains(row.id),
                      onChanged: _action == null
                          ? (selected) {
                              if (row.id == null) return;
                              setState(() {
                                if (selected == true) {
                                  _selectedRows.add(row.id!);
                                } else {
                                  _selectedRows.remove(row.id!);
                                }
                              });
                            }
                          : null,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  field.label,
                  style: context.texts.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                status: row.status,
                label: _statusLabel(context, row),
                compact: true,
              ),
            ],
          ),
          if (row.manuallyEdited) ...[
            const SizedBox(height: 4),
            Text(
              context.tr('translationManuallyEdited'),
              style: context.texts.labelSmall?.copyWith(
                color: context.dukavo.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (source != null && source.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr('translationSourceCopy'),
              style: context.texts.labelSmall?.copyWith(
                color: context.dukavo.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              source,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.texts.bodySmall?.copyWith(
                color: context.dukavo.textMuted,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy == null || copy.isEmpty
                ? context.tr('translationNotTranslatedYet')
                : copy,
            style: context.texts.bodyMedium?.copyWith(height: 1.5),
          ),
          if (row.rejectionReason != null &&
              row.rejectionReason!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(
                'translationRejectionReasonValue',
                args: {'reason': row.rejectionReason!},
              ),
              style: context.texts.bodySmall?.copyWith(
                color: context.dukavo.danger,
              ),
            ),
          ],
          if (showPublished) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoBanner(
              title: context.tr('translationPublishedCopy'),
              message: published,
              icon: Icons.public_outlined,
              tone: InfoBannerTone.info,
            ),
          ],
          if (row.id != null && canReview) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                if (!row.isApproved)
                  TextButton.icon(
                    onPressed: _action == null
                        ? () => _approve(row)
                        : null,
                    icon: const Icon(Icons.check, size: 17),
                    label: Text(context.tr('translationApprove')),
                  ),
                TextButton.icon(
                  onPressed: _action == null ? () => _edit(row) : null,
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  label: Text(context.tr('translationEdit')),
                ),
                if (!row.isRejected)
                  TextButton.icon(
                    onPressed: _action == null ? () => _reject(row) : null,
                    icon: const Icon(Icons.close, size: 17),
                    label: Text(context.tr('translationReject')),
                  ),
                TextButton.icon(
                  onPressed: _action == null
                      ? () => _regenerate(row)
                      : null,
                  icon: const Icon(Icons.refresh, size: 17),
                  label: Text(context.tr('translationRegenerate')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context, TranslationRow row) {
    final key = switch (row.status) {
      'not_translated' => 'translationStatusNotTranslated',
      'generating' => 'translationStatusGenerating',
      'generated' => 'translationStatusGenerated',
      'needs_review' => 'translationStatusNeedsReview',
      'approved' => 'translationStatusApproved',
      'rejected' => 'translationStatusRejected',
      'failed' => 'translationStatusFailed',
      'stale' => 'translationStatusStale',
      _ => '',
    };

    if (key.isEmpty) return row.statusLabel;

    final translated = context.tr(key);
    return translated == key ? row.statusLabel : translated;
  }

  Future<void> _generate(TranslationOverview overview) async {
    final source = _sourceOverride ?? overview.sourceLocale;
    if (source == null) {
      AppSnack.show(
        context,
        context.tr('translationSourceRequiredHint'),
        isError: true,
      );
      return;
    }

    setState(() => _action = 'generate');
    try {
      await ref.read(translationActionsProvider).generate(
            target: _targetForSource(source),
            fields: _fields.toList(),
            targetLocales: _targets.toList(),
            sourceLocale: source,
          );
      if (!mounted) return;
      _showSnack(context.tr('translationGenerated'));
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _action = null);
    }
  }

  Future<void> _approveSelected(TranslationOverview overview) async {
    final ids = _selectedRows.toList();
    if (ids.isEmpty) {
      AppSnack.show(
        context,
        context.tr('translationNothingSelected'),
        isError: true,
      );
      return;
    }

    setState(() => _action = 'approve-all');
    try {
      await ref.read(translationActionsProvider).approveMany(
            target: _target,
            ids: ids,
          );
      if (!mounted) return;
      setState(_selectedRows.clear);
      _showSnack(context.tr('translationApprovedMessage'));
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _action = null);
    }
  }

  Future<void> _approve(TranslationRow row) async {
    if (row.id == null) return;
    final message = context.tr('translationApprovedMessage');
    await _runRow(row, 'approve', () async {
      await ref.read(translationActionsProvider).approve(
            target: _target,
            id: row.id!,
          );
      _showSnack(message);
    });
  }

  Future<void> _edit(TranslationRow row) async {
    if (row.id == null) return;
    if (row.isApproved) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: context.tr('translationEditApprovedTitle'),
        message: context.tr('translationEditApprovedMessage'),
        confirmLabel: context.tr('translationEdit'),
      );
      if (!confirmed) return;
    }

    final controller = TextEditingController(
      text: row.translatedText ?? row.publishedText ?? '',
    );
    if (!mounted) return;
    final successMessage = context.tr('translationUpdated');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('translationEdit')),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: context.tr('translationEditHint'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result == null) return;
    if (result.isEmpty) {
      if (!mounted) return;
      AppSnack.show(
        context,
        context.tr('translationTextRequired'),
        isError: true,
      );
      return;
    }

    await _runRow(row, 'edit', () async {
      await ref.read(translationActionsProvider).update(
            target: _target,
            id: row.id!,
            translatedText: result,
          );
      _showSnack(successMessage);
    });
  }

  Future<void> _reject(TranslationRow row) async {
    if (row.id == null) return;
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('translationReject')),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: context.tr('translationRejectReason'),
            hintText: context.tr('translationRejectReasonHint'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(context.tr('translationReject')),
          ),
        ],
      ),
    );
    controller.dispose();

    if (reason == null) return;
    if (!mounted) return;

    final successMessage = context.tr('translationRejectedMessage');
    await _runRow(row, 'reject', () async {
      await ref.read(translationActionsProvider).reject(
            target: _target,
            id: row.id!,
            reason: reason.isEmpty ? null : reason,
          );
      _showSnack(successMessage);
    });
  }

  Future<void> _regenerate(TranslationRow row) async {
    if (row.id == null) return;
    final needsConfirmation = row.manuallyEdited || row.isApproved;

    if (needsConfirmation) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: context.tr('translationRegenerate'),
        message: context.tr('translationOverwriteMessage'),
        confirmLabel: context.tr('translationRegenerate'),
        destructive: row.manuallyEdited,
      );
      if (!confirmed) return;
    }

    if (!mounted) return;
    final successMessage = context.tr('translationGenerated');
    await _runRow(row, 'regenerate', () async {
      await ref.read(translationActionsProvider).regenerate(
            target: _target,
            id: row.id!,
            confirmOverwrite: needsConfirmation,
          );
      _showSnack(successMessage);
    });
  }

  Future<void> _runRow(
    TranslationRow row,
    String action,
    Future<void> Function() operation,
  ) async {
    setState(() => _action = 'row-${row.id}-$action');
    try {
      await operation();
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    } finally {
      if (mounted) setState(() => _action = null);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    AppSnack.show(context, message);
  }

  void _showError(Object error) {
    if (!mounted) return;
    AppSnack.show(
      context,
      error is ApiException ? error.message : context.tr('errorGeneric'),
      isError: true,
    );
  }
}
