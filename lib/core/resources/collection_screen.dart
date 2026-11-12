import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/design_tokens.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../providers.dart';
import '../utils/formatters.dart';
import '../widgets/app_widgets.dart';
import 'json_resource.dart';

/// How a [CollectionFieldSpec] value is rendered in the detail sheet.
enum CollectionFieldType { text, integer, decimal, boolean, date, json, status }

class CollectionFieldSpec {
  const CollectionFieldSpec({
    required this.key,
    required this.labelKey,
    this.type = CollectionFieldType.text,
    this.show = true,
  });

  final String key;
  final String labelKey;
  final CollectionFieldType type;
  final bool show;
}

/// One network action offered inside a collection item sheet.
class CollectionActionSpec {
  const CollectionActionSpec({
    required this.labelKey,
    required this.path,
    this.method = 'POST',
    this.body,
    this.confirmKey,
    this.icon,
    this.destructive = false,
    this.visible,
  });

  final String labelKey;
  final String Function(JsonResource resource) path;
  final String method;
  final Map<String, dynamic>? Function(JsonResource resource)? body;
  final String? confirmKey;
  final IconData? icon;
  final bool destructive;
  final bool Function(JsonResource resource)? visible;
}

/// A read-first list for server endpoints that return a wrapped collection
/// (`{countries: [...]}`) or a paginated resource the generic [ResourcePager]
/// cannot map to a [ResourceSpec].
///
/// The screen is deliberately mobile-shaped: a compact card list, a detail
/// sheet with labelled rows, and only the actions the endpoint actually
/// exposes. It never invents a route or a field.
class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({
    super.key,
    required this.titleKey,
    required this.path,
    required this.icon,
    required this.title,
    this.itemsKey,
    this.paginated = false,
    this.query = const <String, dynamic>{},
    this.subtitle,
    this.status,
    this.fields = const <CollectionFieldSpec>[],
    this.actions = const <CollectionActionSpec>[],
    this.emptyTitleKey = 'nothingHereYet',
    this.header,
    this.embedded = false,
    this.onItemTap,
    this.extraSheet,
    this.refreshKey,
  });

  final String titleKey;
  final String path;
  final IconData icon;

  /// The wrapped list key. When null the response is expected to be a list
  /// under `data` (paginated resources).
  final String? itemsKey;
  final bool paginated;
  final Map<String, dynamic> query;

  final String Function(JsonResource resource) title;
  final String? Function(JsonResource resource)? subtitle;
  final String? Function(JsonResource resource)? status;
  final List<CollectionFieldSpec> fields;
  final List<CollectionActionSpec> actions;

  final String emptyTitleKey;
  final Widget? header;
  final bool embedded;

  /// When set, tapping a card calls this instead of opening the detail sheet.
  final void Function(BuildContext context, JsonResource resource)? onItemTap;

  /// Optional bespoke block appended to the detail sheet.
  final Widget Function(BuildContext context, JsonResource resource)? extraSheet;

  /// Bump this value from an ancestor to force a reload.
  final Object? refreshKey;

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  List<JsonResource> _items = const <JsonResource>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant CollectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey ||
        oldWidget.path != widget.path) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final List<JsonResource> items;
      if (widget.paginated) {
        final page = await api.list<JsonResource>(
          widget.path,
          query: <String, dynamic>{...widget.query, 'per_page': 100},
          item: JsonResource.fromJson,
        );
        items = page.items;
      } else {
        final data = await api.get<JsonMap>(
          widget.path,
          query: widget.query.isEmpty ? null : widget.query,
          decode: (value) =>
              value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{},
        );
        final key = widget.itemsKey ?? 'data';
        final raw = data[key];
        items = raw is List
            ? raw
                .whereType<Map>()
                .map((row) => JsonResource(Map<String, dynamic>.from(row)))
                .toList()
            : const <JsonResource>[];
      }
      if (!mounted) return;
      setState(() {
        _items = items;
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
    final body = RefreshIndicator(
      onRefresh: _load,
      child: _buildBody(context),
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(widget.titleKey)),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _items.isEmpty) {
      return const LoadingView();
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          ErrorView(message: _error!, onRetry: _load),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.page,
      children: [
        if (widget.header != null) ...[
          widget.header!,
          const SizedBox(height: AppSpacing.md),
        ],
        if (_items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: EmptyState(
              title: context.tr(widget.emptyTitleKey),
              icon: widget.icon,
            ),
          )
        else
          for (final item in _items) ...[
            _CollectionCard(
              icon: widget.icon,
              title: widget.title(item),
              subtitle: widget.subtitle?.call(item),
              status: widget.status?.call(item),
              onTap: () {
                if (widget.onItemTap != null) {
                  widget.onItemTap!(context, item);
                } else {
                  _openSheet(item);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          StatusBanner(tone: StatusBannerTone.error, message: _error!),
        ],
      ],
    );
  }

  Future<void> _openSheet(JsonResource resource) async {
    var current = resource;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _CollectionSheet(
        resource: current,
        fields: widget.fields,
        actions: widget.actions,
        title: widget.title(resource),
        status: widget.status?.call(resource),
        extra: widget.extraSheet?.call(sheetContext, current),
        onAction: (action) async {
          final confirmed = action.confirmKey == null ||
              await ConfirmDialog.show(
                sheetContext,
                title: sheetContext.tr(action.labelKey),
                message: sheetContext.tr(action.confirmKey!),
                confirmLabel: sheetContext.tr(action.labelKey),
                destructive: action.destructive,
              );
          if (!confirmed) return false;
          try {
            final api = ref.read(apiClientProvider);
            final path = action.path(current);
            switch (action.method) {
              case 'DELETE':
                await api.delete(path);
                break;
              case 'PATCH':
                await api.patch<dynamic>(path, body: action.body?.call(current));
                break;
              case 'PUT':
                await api.put<dynamic>(path, body: action.body?.call(current));
                break;
              default:
                await api.post<dynamic>(path, body: action.body?.call(current));
            }
            if (!sheetContext.mounted) return false;
            AppSnack.show(sheetContext, sheetContext.tr('saved'));
            await _load();
            if (mounted && _items.length == 1) {
              // The row may have changed shape; refresh the sheet data too.
              current = _items.first;
            }
            return true;
          } catch (error) {
            if (!sheetContext.mounted) return false;
            AppSnack.show(
              sheetContext,
              error is ApiException
                  ? error.message
                  : sheetContext.tr('errorGeneric'),
              isError: true,
            );
            return false;
          }
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.status,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.scheme.onPrimaryContainer, size: 21),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle == null || subtitle!.isEmpty
            ? null
            : Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodySmall
                    ?.copyWith(color: context.dukavo.textSecondary),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != null && status!.isNotEmpty)
              StatusChip(status: status!, compact: true),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CollectionSheet extends StatefulWidget {
  const _CollectionSheet({
    required this.resource,
    required this.fields,
    required this.actions,
    required this.title,
    required this.onAction,
    this.status,
    this.extra,
  });

  final JsonResource resource;
  final List<CollectionFieldSpec> fields;
  final List<CollectionActionSpec> actions;
  final String title;
  final String? status;
  final Widget? extra;
  final Future<bool> Function(CollectionActionSpec action) onAction;

  @override
  State<_CollectionSheet> createState() => _CollectionSheetState();
}

class _CollectionSheetState extends State<_CollectionSheet> {
  String? _running;

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    final actions = widget.actions
        .where((action) => action.visible?.call(resource) ?? true)
        .toList();
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: context.texts.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (widget.status != null && widget.status!.isNotEmpty) ...[
              const SizedBox(height: 6),
              StatusChip(status: widget.status!),
            ],
            const SizedBox(height: AppSpacing.md),
            for (final field in widget.fields.where((field) => field.show))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: KeyValueRow(
                  label: context.tr(field.labelKey),
                  value: _display(context, field, resource),
                  technical: const {'key', 'code', 'slug', 'adapter'}
                      .contains(field.key),
                ),
              ),
            if (widget.extra != null) ...[
              const SizedBox(height: AppSpacing.md),
              widget.extra!,
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              for (final action in actions) ...[
                AppButton(
                  label: context.tr(action.labelKey),
                  icon: action.icon,
                  expand: true,
                  variant: action.destructive
                      ? AppButtonVariant.outlined
                      : AppButtonVariant.filled,
                  loading: _running == action.labelKey,
                  onPressed: _running != null
                      ? null
                      : () async {
                          setState(() => _running = action.labelKey);
                          await widget.onAction(action);
                          if (mounted) setState(() => _running = null);
                        },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _display(
    BuildContext context,
    CollectionFieldSpec field,
    JsonResource resource,
  ) {
    final raw = resource.data[field.key];
    if (raw == null) return '—';
    switch (field.type) {
      case CollectionFieldType.boolean:
        return resource.flag(field.key) ? context.tr('yes') : context.tr('no');
      case CollectionFieldType.integer:
        final value = resource.number(field.key);
        return value == null ? '$raw' : '${value.toInt()}';
      case CollectionFieldType.decimal:
        final value = resource.number(field.key);
        return value == null ? '$raw' : Formatters.number(value);
      case CollectionFieldType.date:
        return Formatters.date(resource.optionalText(field.key));
      case CollectionFieldType.json:
        if (raw is List) return raw.isEmpty ? '—' : raw.join(', ');
        if (raw is Map) return raw.isEmpty ? '—' : raw.toString();
        return '$raw';
      case CollectionFieldType.status:
        final text = resource.text(field.key);
        return context.tr(text);
      case CollectionFieldType.text:
        if (raw is List) return raw.isEmpty ? '—' : raw.join(', ');
        return resource.text(field.key, fallback: '—');
    }
  }
}
