import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/currency/currency_catalogue.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/currency_picker.dart';
import '../../auth/application/auth_controller.dart';
import '../application/profile_controller.dart';
import '../domain/profile_domain.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profileTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('settings'),
            onPressed: () => context.push(RoutePaths.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (data) => _ProfileBody(profile: data),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Stack(
                  children: [
                    AppAvatar(
                      url: profile.avatarUrl,
                      name: profile.name,
                      size: 88,
                    ),
                    PositionedDirectional(
                      bottom: -4,
                      end: -4,
                      child: Material(
                        color: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _pickAvatar(context, ref),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                StatusChip(status: profile.status),
                const SizedBox(height: 8),
                Text(
                  '${context.tr('lastLogin')}: '
                  '${Formatters.dateTime(profile.lastLoginAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (profile.avatarUrl != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _removeAvatar(context, ref),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(context.tr('removePhoto')),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: context.tr('account'),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(context.tr('editProfile')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editProfile(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.currency_exchange),
                title: Text(context.tr('displayCurrency')),
                subtitle: Text(
                  profile.preferredCurrencyName.isEmpty
                      ? profile.preferredCurrency
                      : '${profile.preferredCurrency} · '
                          '${profile.preferredCurrencyName}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editCurrency(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: Text(context.tr('changePassword')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _changePassword(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_outlined),
                title: Text(context.tr('notificationPreferences')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RoutePaths.settings),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings_outlined),
                title: Text(context.tr('settings')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RoutePaths.settings),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _SessionsCard(),
        const SizedBox(height: 12),
        AppButton(
          label: context.tr('logout'),
          variant: AppButtonVariant.outlined,
          icon: Icons.logout,
          expand: true,
          onPressed: () => _signOut(context, ref),
        ),
      ],
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (!context.mounted) return;
        AppSnack.show(context, context.tr('imageUploadFailed'), isError: true);
        return;
      }
      await ref.read(profileActionsProvider).uploadAvatar(bytes, file.name);
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('avatarUpdated'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _removeAvatar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(profileActionsProvider).removeAvatar();
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('avatarRemoved'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final updated = await showModalBottomSheet<ProfileUpdateDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ProfileEditSheet(profile: profile),
    );
    if (updated == null) return;
    try {
      await ref.read(profileActionsProvider).update(updated);
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('profileUpdated'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _editCurrency(BuildContext context, WidgetRef ref) async {
    try {
      final catalogue = await ref.read(currencyCatalogueProvider.future);
      if (!context.mounted) return;

      final choice = await showCurrencyPicker(
        context,
        currencies: catalogue.currencies,
        selected: profile.preferredCurrency,
        title: context.tr('displayCurrency'),
      );
      if (choice == null || choice.code == profile.preferredCurrency) return;

      await ref.read(profileActionsProvider).update(
            ProfileUpdateDraft(preferredCurrency: choice.code),
          );
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('profileUpdated'));
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.message, isError: true);
    } catch (_) {
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('errorGeneric'), isError: true);
    }
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_PasswordDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => const _PasswordSheet(),
    );
    if (result == null) return;
    try {
      await ref.read(profileActionsProvider).changePassword(
            currentPassword: result.current,
            password: result.next,
            passwordConfirmation: result.confirmation,
          );
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('passwordChanged'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('logout'),
      message: context.tr('signOutMessage'),
      confirmLabel: context.tr('logout'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).logout();
  }
}

class _SessionsCard extends ConsumerWidget {
  const _SessionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(profileSessionsProvider);

    return SectionCard(
      title: context.tr('sessions'),
      trailing: TextButton(
        onPressed: () => _revokeOthers(context, ref),
        child: Text(context.tr('revokeOthers')),
      ),
      child: sessions.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: LoadingView(),
        ),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileSessionsProvider),
        ),
        data: (items) => Column(
          children: [
            for (final session in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  session.isCurrent ? Icons.phone_iphone : Icons.devices_other,
                ),
                title: Text(session.name),
                subtitle: Text(
                  [
                    if (session.isCurrent) context.tr('currentSession'),
                    Formatters.dateTime(
                      session.lastUsedAt ?? session.createdAt,
                    ),
                  ].join(' · '),
                ),
                trailing: session.isCurrent
                    ? null
                    : IconButton(
                        tooltip: context.tr('revoke'),
                        onPressed: () => _revoke(context, ref, session),
                        icon: const Icon(Icons.logout, size: 20),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    ProfileSession session,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('revoke'),
      message: context.tr('sessionRevokeMessage'),
      confirmLabel: context.tr('revoke'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(profileActionsProvider).revokeSession(session.id);
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('sessionRevoked'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }

  Future<void> _revokeOthers(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.tr('revokeOthers'),
      message: context.tr('revokeOthersMessage'),
      confirmLabel: context.tr('revokeOthers'),
      cancelLabel: context.tr('cancel'),
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(profileActionsProvider).revokeOtherSessions();
      if (!context.mounted) return;
      AppSnack.show(context, context.tr('allSessionsRevoked'));
    } catch (error) {
      if (!context.mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    }
  }
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({required this.profile});

  final UserProfile profile;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone ?? '');
  late String _locale = widget.profile.locale ?? 'en';

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('editProfile'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _name,
                label: context.tr('name'),
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _phone,
                label: context.tr('phone'),
                helper: context.tr('optional'),
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _locale,
                decoration: InputDecoration(labelText: context.tr('locale')),
                items: [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(context.tr('english')),
                  ),
                  DropdownMenuItem(
                    value: 'ar',
                    child: Text(context.tr('arabic')),
                  ),
                ],
                onChanged: (value) => setState(() => _locale = value ?? 'en'),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('saveChanges'),
                expand: true,
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  Navigator.of(context).pop(
                    ProfileUpdateDraft(
                      name: _name.text.trim(),
                      phone: _phone.text.trim(),
                      locale: _locale,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordDraft {
  const _PasswordDraft({
    required this.current,
    required this.next,
    required this.confirmation,
  });

  final String current;
  final String next;
  final String confirmation;
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('changePassword'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _current,
                label: context.tr('currentPassword'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? context.tr('requiredField')
                    : null,
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _next,
                label: context.tr('newPassword'),
                helper: context.tr('passwordHint'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return context.tr('passwordTooShort');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _confirmation,
                label: context.tr('confirmPassword'),
                obscureText: true,
                validator: (value) {
                  if (value != _next.text) {
                    return context.tr('passwordMismatch');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                label: context.tr('changePassword'),
                expand: true,
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  Navigator.of(context).pop(
                    _PasswordDraft(
                      current: _current.text,
                      next: _next.text,
                      confirmation: _confirmation.text,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
