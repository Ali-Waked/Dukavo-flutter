import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/app_widgets.dart';

/// Role detail and permission editor, shared by the merchant and platform
/// consoles.
///
/// The permission catalogue comes from `GET /permissions`, not from the role
/// payload: the editor must be able to grant anything the server knows about,
/// including permissions the current caller does not hold.
class RolePermissionsScreen extends ConsumerStatefulWidget {
  const RolePermissionsScreen({
    super.key,
    this.id,
    this.platform = false,
  });

  /// Null creates a new role; a value edits the existing one.
  final int? id;
  final bool platform;

  @override
  ConsumerState<RolePermissionsScreen> createState() =>
      _RolePermissionsScreenState();
}

class _RolePermissionsScreenState extends ConsumerState<RolePermissionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();

  final Set<String> _selected = <String>{};
  List<_PermissionModule> _modules = const [];
  String _scope = '';
  bool _system = false;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  String get _rolesPath =>
      widget.platform ? ApiPaths.platformRoles : ApiPaths.roles;

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (!_isEditing) {
      _scope = widget.platform ? 'platform' : 'tenant';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiClientProvider);
      final role = _isEditing
          ? await api.get<JsonMap>(
              '$_rolesPath/${widget.id}',
              decode: _asMap,
            )
          : const <String, dynamic>{};
      final catalogue =
          await api.get<JsonMap>(ApiPaths.permissions, decode: _asMap);
      if (!mounted) return;
      setState(() {
        _name.text = '${role['name'] ?? ''}';
        _description.text = '${role['description'] ?? ''}';
        _scope = _isEditing ? '${role['scope'] ?? ''}' : _scope;
        _system = role['is_system'] == true;
        final slugs = role['permission_slugs'];
        if (slugs is List) {
          _selected
            ..clear()
            ..addAll(slugs.map((slug) => '$slug'));
        } else if (role['permissions'] is List) {
          _selected
            ..clear()
            ..addAll((role['permissions'] as List).whereType<Map>().map(
                  (entry) => '${entry['slug'] ?? ''}',
                ));
        }
        final rawModules = catalogue['modules'];
        _modules = rawModules is List
            ? rawModules.whereType<Map>().map((entry) {
                final map = Map<String, dynamic>.from(entry);
                final rawPermissions = map['permissions'];
                final permissions = rawPermissions is List
                    ? rawPermissions.whereType<Map>().map((permission) {
                        final item = Map<String, dynamic>.from(permission);
                        return _PermissionEntry(
                          slug: '${item['slug'] ?? ''}',
                          name: '${item['name'] ?? item['slug'] ?? ''}',
                          description: '${item['description'] ?? ''}',
                        );
                      }).toList()
                    : const <_PermissionEntry>[];
                return _PermissionModule(
                  module: '${map['module'] ?? ''}',
                  permissions: permissions,
                );
              }).toList()
            : const <_PermissionModule>[];
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(_isEditing ? 'rolePermissions' : 'createRole'),
        ),
        actions: [
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      if (_isEditing)
                        StatusChip(status: _scope, label: context.tr(_scope))
                      else
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _scope,
                            decoration: InputDecoration(
                              labelText: context.tr('scope'),
                            ),
                            items: [
                              for (final scope in widget.platform
                                  ? const ['platform', 'tenant']
                                  : const ['tenant'])
                                DropdownMenuItem(
                                  value: scope,
                                  child: Text(context.tr(
                                    scope == 'platform'
                                        ? 'platformScope'
                                        : 'tenantScope',
                                  )),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _scope = value);
                              }
                            },
                          ),
                        ),
                      if (_system) ...[
                        const SizedBox(width: 8),
                        StatusChip(
                          status: 'system',
                          label: context.tr('systemRole'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _name,
                    label: context.tr('name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? context.tr('requiredField')
                            : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _description,
                    label: context.tr('description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('permissions'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _system
                        ? context.tr('systemRolePermissionsLocked')
                        : context.tr('permissionsHint'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final module in _modules)
                    _ModuleCard(
                      module: module,
                      selected: _selected,
                      enabled: !_system,
                      onChanged: (slug, value) {
                        setState(() {
                          if (value) {
                            _selected.add(slug);
                          } else {
                            _selected.remove(slug);
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 20),
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      if (!_isEditing) {
        await api.post<dynamic>(
          _rolesPath,
          body: {
            'name': _name.text.trim(),
            'scope': _scope,
            'description': _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),
            'permissions': _selected.toList()..sort(),
          },
        );
        if (!mounted) return;
        AppSnack.show(context, context.tr('saved'));
        context.pop(true);
        return;
      }
      await api.patch<dynamic>(
        '$_rolesPath/${widget.id}',
        body: {
          'name': _name.text.trim(),
          'description': _description.text.trim().isEmpty
              ? null
              : _description.text.trim(),
        },
      );
      if (!_system) {
        await api.put<dynamic>(
          _permissionsPath,
          body: {'permissions': _selected.toList()..sort()},
        );
      }
      if (!mounted) return;
      AppSnack.show(context, context.tr('saved'));
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _message(error);
      });
    }
  }

  String get _permissionsPath => widget.platform
      ? ApiPaths.platformRolePermissions(widget.id!)
      : ApiPaths.rolePermissions(widget.id!);

  String _message(Object error) {
    return error is ApiException ? error.message : context.tr('errorGeneric');
  }

  JsonMap _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class _PermissionModule {
  const _PermissionModule({required this.module, required this.permissions});

  final String module;
  final List<_PermissionEntry> permissions;
}

class _PermissionEntry {
  const _PermissionEntry({
    required this.slug,
    required this.name,
    required this.description,
  });

  final String slug;
  final String name;
  final String description;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final _PermissionModule module;
  final Set<String> selected;
  final bool enabled;
  final void Function(String slug, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    if (module.permissions.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(),
        title: Text(
          _label(context, module.module),
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          context.tr('selectedCount', args: {
            'count': module.permissions
                .where((permission) => selected.contains(permission.slug))
                .length,
          }),
          style: theme.textTheme.bodySmall,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        children: [
          for (final permission in module.permissions)
            CheckboxListTile(
              value: selected.contains(permission.slug),
              onChanged: enabled
                  ? (value) => onChanged(permission.slug, value ?? false)
                  : null,
              title: Text(_label(context, permission.name)),
              subtitle: Text(
                permission.slug,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
        ],
      ),
    );
  }

  /// Permission names are humanised English from the registry. They are data,
  /// not copy, so an untranslated module shows the server's label rather than
  /// a missing-key token.
  static String _label(BuildContext context, String value) {
    final key = value.trim();
    if (key.isEmpty) return '—';
    final translated = context.tr(key);
    return translated == key ? key : translated;
  }
}
