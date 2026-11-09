import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_paths.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/app_widgets.dart';

/// Create or edit a team member, for either the merchant workspace or the
/// platform console.
///
/// The two surfaces share every field but differ in two places: the API base
/// path and the scope of assignable roles. Keeping one screen means the role
/// guard, the password rules and the error display cannot drift apart.
class TeamUserFormScreen extends ConsumerStatefulWidget {
  const TeamUserFormScreen({
    super.key,
    this.id,
    this.platform = false,
  });

  final int? id;
  final bool platform;

  @override
  ConsumerState<TeamUserFormScreen> createState() => _TeamUserFormScreenState();
}

class _TeamUserFormScreenState extends ConsumerState<TeamUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _locale = TextEditingController();

  List<JsonMap> _roles = const [];
  int? _roleId;
  int? _originalRoleId;
  String _status = 'active';
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  bool get _isEditing => widget.id != null;

  String get _basePath =>
      widget.platform ? ApiPaths.platformUsers : ApiPaths.users;
  String get _rolesPath =>
      widget.platform ? ApiPaths.platformRoles : ApiPaths.roles;
  String get _roleScope => widget.platform ? 'platform' : 'tenant';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _locale.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiClientProvider);
      final roles = await api.get<List<dynamic>>(
        _rolesPath,
        query: {'scope': _roleScope},
        decode: (data) => data is List ? data : const <dynamic>[],
      );
      final roleMaps =
          roles.whereType<Map>().map(Map<String, dynamic>.from).toList();
      JsonMap? user;
      if (_isEditing) {
        user = await api.get<JsonMap>(
          '$_basePath/${widget.id}',
          decode: _asMap,
        );
      }
      if (!mounted) return;
      setState(() {
        _roles = roleMaps;
        if (user != null) {
          _name.text = '${user['name'] ?? ''}';
          _email.text = '${user['email'] ?? ''}';
          _phone.text = '${user['phone'] ?? ''}';
          _locale.text = '${user['locale'] ?? ''}';
          _status = '${user['status'] ?? 'active'}';
          final currentRoles = user['roles'];
          if (currentRoles is List) {
            for (final entry in currentRoles) {
              if (entry is Map && entry['id'] != null) {
                _originalRoleId = _asInt(entry['id']);
                _roleId = _originalRoleId;
                break;
              }
            }
          }
        } else if (_roles.length == 1) {
          _roleId = _asInt(_roles.first['id']);
        }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? context.tr('editTeamMember')
              : context.tr('createTeamMember'),
        ),
      ),
      body: _loading
          ? const LoadingView()
          : Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  if (_error != null) ...[
                    _ErrorBanner(message: _error!),
                    const SizedBox(height: 12),
                  ],
                  AppTextField(
                    controller: _name,
                    label: context.tr('name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _email,
                    label: context.tr('email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return context.tr('requiredField');
                      if (!text.contains('@')) {
                        return context.tr('invalidEmail');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _phone,
                    label: context.tr('phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration:
                        InputDecoration(labelText: context.tr('status')),
                    items: [
                      for (final value in const [
                        'active',
                        'invited',
                        'suspended',
                      ])
                        DropdownMenuItem(
                          value: value,
                          child: Text(context.tr(value)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _status = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _roleId,
                    decoration: InputDecoration(labelText: context.tr('role')),
                    validator: (value) =>
                        value == null ? context.tr('requiredField') : null,
                    items: [
                      for (final role in _roles)
                        DropdownMenuItem(
                          value: _asInt(role['id']),
                          child: Text('${role['name'] ?? role['slug'] ?? ''}'),
                        ),
                    ],
                    onChanged: (value) => setState(() => _roleId = value),
                  ),
                  const SizedBox(height: 12),
                  if (!(widget.platform && _isEditing)) ...[
                    AppTextField(
                      controller: _password,
                      label: context.tr(
                        _isEditing ? 'newPasswordOptional' : 'password',
                      ),
                      obscureText: true,
                      helper: context.tr('passwordMinHint'),
                      validator: (value) {
                        final text = value ?? '';
                        if (!_isEditing && text.isEmpty) {
                          return context.tr('requiredField');
                        }
                        if (text.isNotEmpty && text.length < 12) {
                          return context.tr('passwordTooShort');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordConfirm,
                      label: context.tr('confirmPassword'),
                      obscureText: true,
                      validator: (value) {
                        if (_password.text.isEmpty) return null;
                        if (value != _password.text) {
                          return context.tr('passwordMismatch');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Text(
                      context.tr('platformPasswordSelfService'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _locale,
                    label: context.tr('locale'),
                    helper: context.tr('localeHint'),
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
      final body = <String, dynamic>{
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _emptyToNull(_phone.text),
        'locale': _emptyToNull(_locale.text),
        'status': _status,
      };
      if (!(widget.platform && _isEditing) && _password.text.isNotEmpty) {
        body['password'] = _password.text;
        body['password_confirmation'] = _passwordConfirm.text;
      }
      if (!_isEditing) {
        body['role_id'] = _roleId;
        await api.post<dynamic>(_basePath, body: body);
      } else if (widget.platform) {
        await api.patch<dynamic>('$_basePath/${widget.id}', body: body);
        if (_roleId != null && _roleId != _originalRoleId) {
          await api.postVoid('$_basePath/${widget.id}/roles/$_roleId');
          if (_originalRoleId != null) {
            await api.delete(
              '$_basePath/${widget.id}/roles/$_originalRoleId',
            );
          }
        }
      } else {
        body['role_id'] = _roleId;
        await api.patch<dynamic>('$_basePath/${widget.id}', body: body);
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

  String? _required(String? value) => (value == null || value.trim().isEmpty)
      ? context.tr('requiredField')
      : null;

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  String _message(Object error) {
    return error is ApiException ? error.message : context.tr('errorGeneric');
  }

  JsonMap _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
