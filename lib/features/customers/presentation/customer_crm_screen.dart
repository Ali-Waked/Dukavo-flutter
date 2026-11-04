import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/customer_crm_controller.dart';
import '../domain/customer_crm_domain.dart';
import '../domain/customer_domain.dart';

/// The customer's CRM workspace: lifetime stats, the AI summary, merchant
/// memories and a merged order/conversation timeline.
///
/// Every value comes from `CustomerCrmController` / `CustomerMemoryController`.
/// The AI summary is generated on the server; this screen only requests a
/// refresh and lets a permitted merchant correct the stored text.
class CustomerCrmScreen extends ConsumerStatefulWidget {
  const CustomerCrmScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<CustomerCrmScreen> createState() => _CustomerCrmScreenState();
}

class _CustomerCrmScreenState extends ConsumerState<CustomerCrmScreen> {
  bool _refreshingSummary = false;
  int? _deletingMemoryId;

  void _reload() {
    ref.invalidate(customerCrmOverviewProvider(widget.id));
    ref.invalidate(customerTimelineProvider(widget.id));
    ref.invalidate(customerMemoriesProvider(widget.id));
  }

  Future<void> _refreshSummary() async {
    setState(() => _refreshingSummary = true);
    try {
      await ref.read(customerCrmActionsProvider).refreshSummary(widget.id);
      if (!mounted) return;
      AppSnack.show(context, context.tr('summaryRefreshed'));
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    } finally {
      if (mounted) setState(() => _refreshingSummary = false);
    }
  }

  Future<void> _editSummary(CustomerSummary summary) async {
    final controller = TextEditingController(text: summary.summary);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('editSummary')),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 8,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.tr('summaryHint'),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !mounted) return;

    try {
      await ref
          .read(customerCrmActionsProvider)
          .updateSummary(widget.id, result.trim());
      if (!mounted) return;
      AppSnack.show(context, context.tr('summaryUpdated'));
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    }
  }

  Future<void> _addMemory() async {
    final draft = await showDialog<CustomerMemoryDraft>(
      context: context,
      builder: (dialogContext) => const _MemoryDialog(),
    );
    if (draft == null || !mounted) return;
    await _saveMemory(draft);
  }

  Future<void> _editMemory(CustomerMemory memory) async {
    final draft = await showDialog<CustomerMemoryDraft>(
      context: context,
      builder: (dialogContext) => _MemoryDialog(memory: memory),
    );
    if (draft == null || !mounted) return;
    await _saveMemory(draft, memoryId: memory.id);
  }

  Future<void> _saveMemory(
    CustomerMemoryDraft draft, {
    int? memoryId,
  }) async {
    try {
      final actions = ref.read(customerCrmActionsProvider);
      if (memoryId == null) {
        await actions.createMemory(widget.id, draft);
      } else {
        await actions.updateMemory(widget.id, memoryId, draft);
      }
      if (!mounted) return;
      AppSnack.show(context, context.tr('memorySaved'));
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    }
  }

  Future<void> _deleteMemory(CustomerMemory memory) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('deleteMemory'),
      message: context.tr('deleteMemoryMessage'),
      confirmLabel: context.tr('delete'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _deletingMemoryId = memory.id);
    try {
      await ref
          .read(customerCrmActionsProvider)
          .deleteMemory(widget.id, memory.id);
      if (!mounted) return;
      AppSnack.show(context, context.tr('memoryDeleted'));
    } on ApiException catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    } finally {
      if (mounted) setState(() => _deletingMemoryId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(customerCrmOverviewProvider(widget.id));
    final permissions = ref.watch(permissionsProvider);
    final sessionCurrency =
        ref.watch(currentSessionProvider)?.currency ?? 'USD';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('customerCrm')),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: overview.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error is ApiException
              ? error.message
              : context.tr('errorGeneric'),
          onRetry: _reload,
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _CustomerHeader(customer: data.customer),
              const SizedBox(height: 16),
              _StatsGrid(
                stats: data.stats,
                fallbackCurrency: sessionCurrency,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                summary: data.summary,
                canUseAi: permissions.canUseAi,
                canEdit: permissions.canUpdateCustomers,
                refreshing: _refreshingSummary,
                onRefresh: _refreshSummary,
                onEdit: () => _editSummary(data.summary),
              ),
              const SizedBox(height: 12),
              _MemoriesSection(
                customerId: widget.id,
                canUpdate: permissions.canUpdateCustomers,
                canDelete: permissions.canDeleteCustomers,
                deletingId: _deletingMemoryId,
                onAdd: _addMemory,
                onEdit: _editMemory,
                onDelete: _deleteMemory,
              ),
              const SizedBox(height: 12),
              _TimelineSection(customerId: widget.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AppAvatar(name: customer.name, size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (customer.phone != null || customer.email != null)
                Text(
                  customer.phone ?? customer.email ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        StatusChip(status: customer.status),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.fallbackCurrency});

  final CustomerStats stats;
  final String fallbackCurrency;

  @override
  Widget build(BuildContext context) {
    final currency = stats.currency ?? fallbackCurrency;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: context.tr('ordersCount'),
                value: '${stats.ordersCount}',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: context.tr('paidOrders'),
                value: '${stats.paidOrdersCount}',
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: context.tr('totalSpent'),
                value: Formatters.currency(stats.totalSpent, currency),
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: context.tr('averageOrderValue'),
                value: Formatters.currency(stats.averageOrderValue, currency),
                icon: Icons.analytics_outlined,
              ),
            ),
          ],
        ),
        if (stats.lastInteractionAt != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '${context.tr('lastInteraction')}: '
              '${Formatters.dateTime(stats.lastInteractionAt)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.canUseAi,
    required this.canEdit,
    required this.refreshing,
    required this.onRefresh,
    required this.onEdit,
  });

  final CustomerSummary summary;
  final bool canUseAi;
  final bool canEdit;
  final bool refreshing;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: context.tr('aiSummary'),
      trailing: canEdit && !summary.isEmpty
          ? IconButton(
              tooltip: context.tr('editSummary'),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (summary.isEmpty)
            Text(
              context.tr('aiSummaryEmpty'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Text(summary.summary, style: theme.textTheme.bodyMedium),
            if (summary.highlights.isNotEmpty)
              _SummaryList(
                title: context.tr('highlights'),
                items: summary.highlights,
                icon: Icons.auto_awesome_outlined,
                color: theme.colorScheme.primary,
              ),
            if (summary.risks.isNotEmpty)
              _SummaryList(
                title: context.tr('risks'),
                items: summary.risks,
                icon: Icons.warning_amber_outlined,
                color: theme.colorScheme.error,
              ),
            if (summary.opportunities.isNotEmpty)
              _SummaryList(
                title: context.tr('opportunities'),
                items: summary.opportunities,
                icon: Icons.trending_up,
                color: theme.colorScheme.tertiary,
              ),
            if (summary.refreshedAt != null || summary.model != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (summary.model != null) summary.model!,
                  if (summary.refreshedAt != null)
                    Formatters.dateTime(summary.refreshedAt),
                  if (summary.isEdited) context.tr('edited'),
                ].join(' · '),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          if (canUseAi) ...[
            const SizedBox(height: 12),
            AppButton(
              label: context.tr('refreshSummary'),
              icon: Icons.auto_awesome,
              variant: AppButtonVariant.outlined,
              expand: true,
              loading: refreshing,
              onPressed: onRefresh,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  const _SummaryList({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _MemoriesSection extends ConsumerWidget {
  const _MemoriesSection({
    required this.customerId,
    required this.canUpdate,
    required this.canDelete,
    required this.deletingId,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final int customerId;
  final bool canUpdate;
  final bool canDelete;
  final int? deletingId;
  final VoidCallback onAdd;
  final ValueChanged<CustomerMemory> onEdit;
  final ValueChanged<CustomerMemory> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(customerMemoriesProvider(customerId));
    return SectionCard(
      title: context.tr('memories'),
      trailing: canUpdate
          ? IconButton(
              tooltip: context.tr('addMemory'),
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            )
          : null,
      child: memories.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        ),
        error: (error, stack) => Text(
          error is ApiException ? error.message : context.tr('errorGeneric'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Text(
              context.tr('noMemories'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            );
          }
          return Column(
            children: [
              for (final memory in items)
                _MemoryTile(
                  memory: memory,
                  deleting: deletingId == memory.id,
                  canUpdate: canUpdate,
                  canDelete: canDelete,
                  onEdit: () => onEdit(memory),
                  onDelete: () => onDelete(memory),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({
    required this.memory,
    required this.deleting,
    required this.canUpdate,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  final CustomerMemory memory;
  final bool deleting;
  final bool canUpdate;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.key,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(memory.value, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  [
                    memory.category,
                    memory.source,
                    if (memory.confidence != null)
                      '${memory.confidence}% ${context.tr('confidence')}',
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (deleting)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<String>(
              enabled: canUpdate || canDelete,
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                if (canUpdate)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(context.tr('edit')),
                  ),
                if (canDelete)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(context.tr('delete')),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TimelineSection extends ConsumerWidget {
  const _TimelineSection({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(customerTimelineProvider(customerId));
    return SectionCard(
      title: context.tr('timeline'),
      child: timeline.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        ),
        error: (error, stack) => Text(
          error is ApiException ? error.message : context.tr('errorGeneric'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Text(
              context.tr('noActivity'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            );
          }
          return Column(
            children: [
              for (final entry in items) _TimelineTile(entry: entry),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry});

  final CustomerTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOrder = entry.isOrder;
    final title = isOrder
        ? (entry.orderNumber ?? context.tr('order'))
        : (entry.conversationSubject ??
            entry.conversationDisplayName ??
            context.tr('conversation'));
    final subtitle = isOrder
        ? [
            if (entry.orderStatus != null) entry.orderStatus!,
            if (entry.itemCount != null)
              '${entry.itemCount} ${context.tr('items')}',
            if (entry.grandTotal != null && entry.currency != null)
              Formatters.currency(entry.grandTotal!, entry.currency!),
          ].join(' · ')
        : [
            if (entry.conversationChannel != null) entry.conversationChannel!,
            if (entry.data['status'] != null) '${entry.data['status']}',
          ].join(' · ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          isOrder ? Icons.receipt_long_outlined : Icons.chat_bubble_outline,
          size: 18,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle.isEmpty
            ? Formatters.dateTime(entry.timestamp?.toIso8601String())
            : '${Formatters.dateTime(entry.timestamp?.toIso8601String())}'
                ' · $subtitle',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        if (entry.isOrder && entry.orderNumber != null) {
          context.push(RoutePaths.order(entry.orderNumber!));
        } else if (entry.isConversation && entry.conversationId != null) {
          context.push(RoutePaths.conversation(entry.conversationId!));
        }
      },
    );
  }
}

class _MemoryDialog extends StatefulWidget {
  const _MemoryDialog({this.memory});

  final CustomerMemory? memory;

  @override
  State<_MemoryDialog> createState() => _MemoryDialogState();
}

class _MemoryDialogState extends State<_MemoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _key = TextEditingController(text: widget.memory?.key ?? '');
  late final _value = TextEditingController(text: widget.memory?.value ?? '');
  late final _category =
      TextEditingController(text: widget.memory?.category ?? 'general');
  late final _source =
      TextEditingController(text: widget.memory?.source ?? 'manual');
  late final _confidence = TextEditingController(
    text: widget.memory?.confidence?.toString() ?? '',
  );

  @override
  void dispose() {
    _key.dispose();
    _value.dispose();
    _category.dispose();
    _source.dispose();
    _confidence.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CustomerMemoryDraft(
        key: _key.text.trim(),
        value: _value.text.trim(),
        category:
            _category.text.trim().isEmpty ? 'general' : _category.text.trim(),
        source: _source.text.trim().isEmpty ? 'manual' : _source.text.trim(),
        confidence: int.tryParse(_confidence.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.memory == null
            ? context.tr('addMemory')
            : context.tr('editMemory'),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _key,
                label: context.tr('memoryKey'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _value,
                label: context.tr('memoryValue'),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _category,
                label: context.tr('category'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _source,
                label: context.tr('source'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _confidence,
                label: context.tr('confidence'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final parsed = int.tryParse(text);
                  if (parsed == null || parsed < 0 || parsed > 100) {
                    return context.tr('confidenceRange');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}
