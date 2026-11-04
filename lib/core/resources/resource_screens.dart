import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/localization/app_localizations.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../providers.dart';
import '../utils/formatters.dart';
import '../widgets/app_widgets.dart';
import 'json_resource.dart';
import 'resource_pager.dart';
import 'resource_spec.dart';

/// A paginated, searchable admin list driven by a [ResourceSpec].
class ResourceListScreen extends ConsumerStatefulWidget {
  const ResourceListScreen({
    super.key,
    required this.spec,
    this.titleOverride,
    this.header,
  });

  final ResourceSpec spec;
  final String? titleOverride;
  final Widget? header;

  @override
  ConsumerState<ResourceListScreen> createState() => _ResourceListScreenState();
}

class _ResourceListScreenState extends ConsumerState<ResourceListScreen> {
  late final ResourcePager _pager;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pager = ResourcePager(ref.read(apiClientProvider), widget.spec);
    _pager.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pager.loadInitial());
  }

  @override
  void dispose() {
    _pager.removeListener(_refresh);
    _pager.dispose();
    _search.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleOverride ?? context.tr(spec.titleKey)),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _pager.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: spec.canCreate && spec.createPath != null
          ? FloatingActionButton.extended(
              onPressed: () => _openCreate(context),
              icon: const Icon(Icons.add),
              label: Text(context.tr(spec.createLabelKey)),
            )
          : null,
      body: Column(
        children: [
          if (widget.header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: widget.header,
            ),
          if (spec.searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchField(
                controller: _search,
                hint: context.tr('search'),
                onSubmitted: _pager.setSearch,
                onChanged: (value) {
                  if (value.isEmpty) _pager.setSearch('');
                },
              ),
            ),
          for (final filter in spec.filters)
            _FilterChips(
              filter: filter,
              selected: _pager.filterValues[filter.param],
              onSelected: (value) => _pager.setFilter(filter.param, value),
            ),
          Expanded(
            child: PagedListView<JsonResource>(
              state: _pager.state,
              onRefresh: _pager.refresh,
              onLoadMore: _pager.loadMore,
              empty: EmptyState(
                title: context.tr(spec.emptyTitleKey),
                icon: spec.emptyIcon ?? spec.icon,
                actionLabel:
                    spec.canCreate ? context.tr(spec.createLabelKey) : null,
                onAction: spec.canCreate ? () => _openCreate(context) : null,
              ),
              itemBuilder: (context, item, index) => ResourceCard(
                spec: spec,
                resource: item,
                onTap: () => _openDetail(context, item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final path = widget.spec.createPath;
    if (path == null) return;
    final changed = await context.push<bool>(path);
    if (changed == true) _pager.reload();
  }

  Future<void> _openDetail(BuildContext context, JsonResource resource) async {
    final changed = await context.push<bool>(
      widget.spec.detailRouteFor(resource),
      extra: resource,
    );
    if (changed == true) _pager.reload();
  }
}

/// A single-select filter rendered as a horizontally scrollable chip row.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.selected,
    required this.onSelected,
  });

  final ResourceFilterSpec filter;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(context.tr(filter.allLabelKey)),
              selected: selected == null || selected!.isEmpty,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final option in filter.options)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(context.tr(option.label)),
                selected: selected == option.value,
                onSelected: (_) => onSelected(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

/// The standard row card shared by every admin list.
class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.spec,
    required this.resource,
    this.onTap,
  });

  final ResourceSpec spec;
  final JsonResource resource;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = spec.status?.call(resource);
    final subtitle = spec.subtitle?.call(resource);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(spec.icon, color: scheme.onPrimaryContainer, size: 22),
        ),
        title: Text(
          spec.title(resource),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle == null || subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != null && status.isNotEmpty)
              StatusChip(status: status, compact: true),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Detail view for a [ResourceSpec]. The list passes the row it already has as
/// [initial] so the screen paints immediately, then refreshes from the server.
class ResourceDetailScreen extends ConsumerStatefulWidget {
  const ResourceDetailScreen({
    super.key,
    required this.spec,
    required this.id,
    this.initial,
  });

  final ResourceSpec spec;
  final int id;
  final JsonResource? initial;

  @override
  ConsumerState<ResourceDetailScreen> createState() =>
      _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends ConsumerState<ResourceDetailScreen> {
  JsonResource? _resource;
  bool _loading = false;
  bool _acting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resource = widget.initial;
    if (widget.spec.fetchDetail) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final path = widget.spec.detailPathFor(
        widget.initial ?? JsonResource({'id': widget.id}),
      );
      final data = await api.get<JsonMap>(path, decode: _asMap);
      if (!mounted) return;
      setState(() {
        _resource = JsonResource(data);
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
    final spec = widget.spec;
    final resource = _resource;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(spec.titleKey)),
        actions: [
          if (spec.canEdit && spec.editPath != null && resource != null)
            IconButton(
              tooltip: context.tr('edit'),
              onPressed: () => _edit(resource),
              icon: const Icon(Icons.edit_outlined),
            ),
          if (spec.canDelete && spec.deletePath != null && resource != null)
            IconButton(
              tooltip: context.tr('delete'),
              onPressed: () => _delete(resource),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _loading && resource == null
          ? const LoadingView()
          : resource == null
              ? ErrorView(
                  message: _error ?? context.tr('errorGeneric'),
                  onRetry: _load,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _header(context, resource),
                      const SizedBox(height: 12),
                      SectionCard(
                        child: Column(
                          children: [
                            for (final field in spec.fields
                                .where((field) => field.showInDetail))
                              KeyValueRow(
                                label: context.tr(field.labelKey),
                                value: _display(context, field, resource),
                              ),
                          ],
                        ),
                      ),
                      if (spec.extraDetail != null) ...[
                        const SizedBox(height: 16),
                        spec.extraDetail!(context, resource),
                      ],
                      if (spec.actions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _actions(context, resource),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _header(BuildContext context, JsonResource resource) {
    final status = widget.spec.status?.call(resource);
    final subtitle = widget.spec.subtitle?.call(resource);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.spec.icon,
            color: scheme.onPrimaryContainer,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.spec.title(resource),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (status != null && status.isNotEmpty) StatusChip(status: status),
      ],
    );
  }

  Widget _actions(BuildContext context, JsonResource resource) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final action in widget.spec.actions)
          if (action.visible?.call(resource) ?? true)
            AppButton(
              label: context.tr(action.labelKey),
              icon: action.icon,
              variant: action.destructive
                  ? AppButtonVariant.outlined
                  : AppButtonVariant.filled,
              onPressed: _acting ? null : () => _run(action, resource),
            ),
      ],
    );
  }

  Future<void> _run(ResourceActionSpec action, JsonResource resource) async {
    if (action.confirmKey != null) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: context.tr(action.labelKey),
        message: context.tr(action.confirmKey!),
        confirmLabel: context.tr(action.labelKey),
        destructive: action.destructive,
      );
      if (!confirmed) return;
    }
    setState(() => _acting = true);
    try {
      final api = ref.read(apiClientProvider);
      final path = action.path(resource);
      final body = action.body?.call(resource);
      switch (action.method) {
        case 'DELETE':
          await api.delete(path);
          break;
        case 'PATCH':
          await api.patch<dynamic>(path, body: body);
          break;
        default:
          await api.post<dynamic>(path, body: body);
      }
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
      await _load();
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _edit(JsonResource resource) async {
    final path = widget.spec.editPath;
    if (path == null) return;
    final location = path(resource);
    if (location == null) return;
    final changed = await context.push<bool>(location, extra: resource);
    if (changed == true) _load();
  }

  Future<void> _delete(JsonResource resource) async {
    final path = widget.spec.deletePath;
    if (path == null) return;
    final location = path(resource);
    if (location == null) return;
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('delete'),
      message: context.tr('deleteConfirmMessage'),
      confirmLabel: context.tr('delete'),
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(apiClientProvider).delete(location);
      if (!mounted) return;
      AppSnack.show(context, context.tr('deleted'));
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(
        context,
        error is ApiException ? error.message : context.tr('errorGeneric'),
        isError: true,
      );
    }
  }
}

/// Create/edit form for a [ResourceSpec].
class ResourceFormScreen extends ConsumerStatefulWidget {
  const ResourceFormScreen({
    super.key,
    required this.spec,
    this.id,
    this.initial,
    this.titleOverride,
    this.extraFields,
  });

  final ResourceSpec spec;
  final int? id;
  final JsonResource? initial;
  final String? titleOverride;
  final List<Widget>? extraFields;

  @override
  ConsumerState<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends ConsumerState<ResourceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _booleans = {};
  final Map<String, String> _selects = {};

  bool _loading = false;
  bool _submitting = false;
  String? _error;

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    for (final field in widget.spec.fields.where((field) => field.showInForm)) {
      _controllers[field.key] = TextEditingController();
      _booleans[field.key] = false;
    }
    final initial = widget.initial;
    if (initial != null) {
      _populate(initial);
    } else if (_isEditing && widget.spec.fetchDetail) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _populate(JsonResource resource) {
    for (final field in widget.spec.fields) {
      final controller = _controllers[field.key];
      if (controller != null) {
        final value = resource.data[field.key];
        if (value != null && field.type == ResourceFieldType.json) {
          try {
            controller.text = const JsonEncoder.withIndent('  ').convert(value);
          } catch (_) {
            controller.text = '$value';
          }
        } else if (value != null && field.type != ResourceFieldType.boolean) {
          controller.text = '${value is num ? _trimNumber(value) : value}';
        }
      }
      _booleans[field.key] = resource.flag(field.key);
      final selected = resource.text(field.key);
      if (selected.isNotEmpty) _selects[field.key] = selected;
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = await api.get<JsonMap>(
        widget.spec.detailPathFor(JsonResource({'id': widget.id})),
        decode: _asMap,
      );
      if (!mounted) return;
      setState(() {
        _populate(JsonResource(data));
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
    final spec = widget.spec;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titleOverride ??
              (_isEditing
                  ? context.tr('edit')
                  : context.tr(spec.createLabelKey)),
        ),
      ),
      body: _loading
          ? const LoadingView()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (spec.extraForm != null) ...[
                    spec.extraForm!(context),
                    const SizedBox(height: 12),
                  ],
                  for (final field
                      in spec.fields.where((field) => field.showInForm)) ...[
                    _field(context, field),
                    const SizedBox(height: 12),
                  ],
                  if (widget.extraFields != null) ...[
                    ...widget.extraFields!,
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  AppButton(
                    label: context.tr('save'),
                    loading: _submitting,
                    expand: true,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(BuildContext context, ResourceFieldSpec field) {
    final label = context.tr(field.labelKey);
    switch (field.type) {
      case ResourceFieldType.boolean:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: field.helperKey == null
              ? null
              : Text(context.tr(field.helperKey!)),
          value: _booleans[field.key] ?? false,
          onChanged: (value) => setState(() => _booleans[field.key] = value),
        );
      case ResourceFieldType.select:
        return DropdownButtonFormField<String>(
          initialValue: _selects[field.key],
          decoration: InputDecoration(
            labelText: label,
            helperText:
                field.helperKey == null ? null : context.tr(field.helperKey!),
          ),
          items: [
            for (final option in field.options)
              DropdownMenuItem(
                value: option.value,
                child: Text(context.tr(option.label)),
              ),
          ],
          validator: field.required
              ? (value) => value == null ? context.tr('requiredField') : null
              : null,
          onChanged: (value) => setState(() {
            if (value != null) _selects[field.key] = value;
          }),
        );
      case ResourceFieldType.json:
        return AppTextField(
          controller: _controllers[field.key],
          label: label,
          helper: field.helperKey == null ? null : context.tr(field.helperKey!),
          maxLines: field.maxLines > 1 ? field.maxLines : 8,
          keyboardType: TextInputType.multiline,
          validator: (value) {
            final raw = value?.trim() ?? '';
            if (raw.isEmpty) {
              return field.required ? context.tr('requiredField') : null;
            }
            try {
              jsonDecode(raw);
            } catch (_) {
              return context.tr('invalidJson');
            }
            return null;
          },
        );
      default:
        return AppTextField(
          controller: _controllers[field.key],
          label: label,
          helper: field.helperKey == null ? null : context.tr(field.helperKey!),
          maxLines:
              field.type == ResourceFieldType.multiline ? field.maxLines : 1,
          obscureText: field.type == ResourceFieldType.password,
          keyboardType: switch (field.type) {
            ResourceFieldType.integer => TextInputType.number,
            ResourceFieldType.decimal => const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ResourceFieldType.date => TextInputType.datetime,
            _ => TextInputType.text,
          },
          validator: (value) {
            if (field.required && (value == null || value.trim().isEmpty)) {
              return context.tr('requiredField');
            }
            if (value == null || value.trim().isEmpty) {
              return field.validator?.call(value);
            }
            if (field.type == ResourceFieldType.integer &&
                int.tryParse(value.trim()) == null) {
              return context.tr('invalidNumber');
            }
            if (field.type == ResourceFieldType.decimal &&
                double.tryParse(value.trim()) == null) {
              return context.tr('invalidNumber');
            }
            return field.validator?.call(value);
          },
        );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final body = _body();
      if (_isEditing) {
        await api.patch<dynamic>(
          '${widget.spec.path}/${widget.id}',
          body: body,
        );
      } else {
        await api.post<dynamic>(widget.spec.path, body: body);
      }
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = error is ApiException ? error.message : null;
      });
    }
  }

  Map<String, dynamic> _body() {
    final body = <String, dynamic>{};
    for (final field in widget.spec.fields.where((field) => field.showInForm)) {
      switch (field.type) {
        case ResourceFieldType.boolean:
          body[field.key] = _booleans[field.key] ?? false;
          break;
        case ResourceFieldType.select:
          final value = _selects[field.key];
          if (value != null && value.isNotEmpty) body[field.key] = value;
          break;
        case ResourceFieldType.integer:
          final raw = _controllers[field.key]?.text.trim() ?? '';
          if (raw.isNotEmpty) body[field.key] = int.parse(raw);
          break;
        case ResourceFieldType.decimal:
          final raw = _controllers[field.key]?.text.trim() ?? '';
          if (raw.isNotEmpty) body[field.key] = double.parse(raw);
          break;
        case ResourceFieldType.json:
          final raw = _controllers[field.key]?.text.trim() ?? '';
          if (raw.isNotEmpty) body[field.key] = jsonDecode(raw);
          break;
        default:
          final raw = _controllers[field.key]?.text.trim() ?? '';
          if (raw.isNotEmpty) {
            body[field.key] = raw;
          } else if (_isEditing && field.required) {
            body[field.key] = '';
          }
      }
    }
    return body;
  }
}

String _display(
  BuildContext context,
  ResourceFieldSpec field,
  JsonResource resource,
) {
  switch (field.type) {
    case ResourceFieldType.boolean:
      return resource.flag(field.key) ? context.tr('yes') : context.tr('no');
    case ResourceFieldType.decimal:
      final value = resource.number(field.key);
      return value == null ? '—' : Formatters.number(value);
    case ResourceFieldType.integer:
      final value = resource.number(field.key);
      return value == null ? '—' : '${value.toInt()}';
    case ResourceFieldType.date:
      return Formatters.date(resource.optionalText(field.key));
    case ResourceFieldType.json:
      final value = resource.data[field.key];
      if (value == null) return '—';
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return '$value';
      }
    case ResourceFieldType.select:
      final raw = resource.text(field.key);
      for (final option in field.options) {
        if (option.value == raw) return context.tr(option.label);
      }
      return raw.isEmpty ? '—' : raw;
    default:
      final value = resource.text(field.key);
      return value.isEmpty ? '—' : value;
  }
}

String _trimNumber(num value) {
  return value == value.roundToDouble() ? '${value.toInt()}' : '$value';
}

JsonMap _asMap(Object? data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  return const <String, dynamic>{};
}
