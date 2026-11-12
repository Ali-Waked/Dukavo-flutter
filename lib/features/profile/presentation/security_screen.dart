import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/profile_controller.dart';
import '../domain/profile_domain.dart';

/// The account's own security centre.
///
/// Password, two-step verification, signed-in devices and the append-only
/// security history live together because they answer one question: who can get
/// into this account, and what has already happened. Secrets and recovery codes
/// are shown only at the moment they are created.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('securityCenter'))),
      body: ListView(
        padding: AppSpacing.page,
        children: const [
          _PasswordCard(),
          SizedBox(height: AppSpacing.sm),
          _TwoFactorCard(),
          SizedBox(height: AppSpacing.sm),
          _SessionsCard(),
          SizedBox(height: AppSpacing.sm),
          _ActivityCard(),
        ],
      ),
    );
  }
}

/* --------------------------------------------------------------- password */

class _PasswordCard extends ConsumerWidget {
  const _PasswordCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: context.tr('changePassword'),
      subtitle: context.tr('changePasswordDesc'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: context.tr('changePassword'),
            variant: AppButtonVariant.outlined,
            icon: Icons.lock_outline_rounded,
            onPressed: () async {
              final draft = await showModalBottomSheet<_PasswordDraft>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => const _PasswordSheet(),
              );
              if (draft == null) return;
              try {
                await ref.read(profileActionsProvider).changePassword(
                      currentPassword: draft.current,
                      password: draft.next,
                      passwordConfirmation: draft.confirmation,
                    );
                if (!context.mounted) return;
                AppSnack.show(context, context.tr('passwordChanged'));
              } catch (error) {
                if (!context.mounted) return;
                AppSnack.show(context, error.toString(), isError: true);
              }
            },
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------- two-factor */

class _TwoFactorCard extends ConsumerStatefulWidget {
  const _TwoFactorCard();

  @override
  ConsumerState<_TwoFactorCard> createState() => _TwoFactorCardState();
}

class _TwoFactorCardState extends ConsumerState<_TwoFactorCard> {
  TwoFactorSetup? _setup;
  List<String>? _codes;
  bool _busy = false;
  final _code = TextEditingController();
  final _recovery = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _recovery.dispose();
    super.dispose();
  }

  Future<void> _startSetup() async {
    setState(() => _busy = true);
    try {
      final setup = await ref.read(profileActionsProvider).startTwoFactorSetup();
      if (!mounted) return;
      setState(() {
        _setup = setup;
        _codes = null;
        _code.clear();
      });
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final code = _code.text.trim();
    if (code.length != 6) {
      AppSnack.show(context, context.tr('twoFactorCodeLength'), isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final result =
          await ref.read(profileActionsProvider).confirmTwoFactor(code);
      if (!mounted) return;
      setState(() {
        _codes = result.codes;
        _setup = null;
        _code.clear();
      });
      AppSnack.show(context, context.tr('twoFactorEnabled'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    final draft = await showDialog<_DisableDraft>(
      context: context,
      builder: (_) => const _DisableDialog(),
    );
    if (draft == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(profileActionsProvider).disableTwoFactor(
            password: draft.password,
            code: draft.code,
            recoveryCode: draft.recoveryCode,
          );
      if (!mounted) return;
      AppSnack.show(context, context.tr('twoFactorDisabled'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _regenerate() async {
    final draft = await showDialog<_DisableDraft>(
      context: context,
      builder: (_) => const _DisableDialog(
        requirePassword: false,
        titleKey: 'regenerateRecoveryCodes',
        introKey: 'regenerateIntro',
        confirmKey: 'regenerateRecoveryCodes',
      ),
    );
    if (draft == null) return;
    final code = draft.code ?? draft.recoveryCode ?? '';
    setState(() => _busy = true);
    try {
      final codes =
          await ref.read(profileActionsProvider).regenerateRecoveryCodes(code);
      if (!mounted) return;
      setState(() => _codes = codes);
      AppSnack.show(context, context.tr('recoveryCodesRegenerated'));
    } catch (error) {
      if (!mounted) return;
      AppSnack.show(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(twoFactorStatusProvider);
    final colors = context.dukavo;

    return SectionCard(
      title: context.tr('twoFactor'),
      subtitle: context.tr('twoFactorDesc'),
      child: status.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: LoadingView(),
        ),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(twoFactorStatusProvider),
        ),
        data: (value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  value.enabled
                      ? Icons.verified_user_rounded
                      : Icons.gpp_maybe_outlined,
                  color: value.enabled ? colors.success : colors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    value.enabled
                        ? context.tr('twoFactorOn')
                        : context.tr('twoFactorOff'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (value.enabled && value.confirmedAt != null)
                  Text(
                    context.tr(
                      'twoFactorActiveSince',
                      args: {'time': Formatters.date(value.confirmedAt)},
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textMuted,
                        ),
                  ),
              ],
            ),
            if (value.enabled) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.tr(
                  'recoveryCodesRemaining',
                  args: {'count': value.recoveryCodesCount},
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  AppButton(
                    label: context.tr('regenerateRecoveryCodes'),
                    variant: AppButtonVariant.outlined,
                    icon: Icons.refresh_rounded,
                    onPressed: _busy ? null : _regenerate,
                  ),
                  AppButton(
                    label: context.tr('disableTwoFactor'),
                    variant: AppButtonVariant.danger,
                    icon: Icons.remove_circle_outline,
                    onPressed: _busy ? null : _disable,
                  ),
                ],
              ),
            ] else if (_setup == null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: context.tr('twoFactorEnable'),
                icon: Icons.shield_outlined,
                loading: _busy,
                onPressed: _busy ? null : _startSetup,
              ),
            ],
            if (_setup != null) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                message: context.tr('twoFactorSetupIntro'),
                tone: InfoBannerTone.info,
                icon: Icons.qr_code_2_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              _SecretBlock(label: context.tr('twoFactorSecret'), value: _setup!.secret),
              const SizedBox(height: AppSpacing.xs),
              _SecretBlock(
                label: context.tr('twoFactorProvisioningUri'),
                value: _setup!.provisioningUri,
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  context.tr('twoFactorSecretOnce'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _code,
                label: context.tr('twoFactorCode'),
                hint: context.tr('twoFactorCodePlaceholder'),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: context.tr('twoFactorConfirm'),
                loading: _busy,
                onPressed: _busy ? null : _confirm,
              ),
            ],
            if (_codes != null) ...[
              const SizedBox(height: AppSpacing.md),
              _RecoveryCodes(codes: _codes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecretBlock extends StatelessWidget {
  const _SecretBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
            IconButton(
              tooltip: context.tr('copy'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (!context.mounted) return;
                AppSnack.show(context, context.tr('copied'));
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecoveryCodes extends StatelessWidget {
  const _RecoveryCodes({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tone: AppCardTone.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('recoveryCodesTitle'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('recoveryCodesOnce'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.dukavo.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 6,
            children: [
              for (final code in codes)
                SelectableText(
                  code,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: context.tr('copy'),
            variant: AppButtonVariant.outlined,
            icon: Icons.copy_all_rounded,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: codes.join('\n')));
              if (!context.mounted) return;
              AppSnack.show(context, context.tr('copied'));
            },
          ),
        ],
      ),
    );
  }
}

/* --------------------------------------------------------------- sessions */

class _SessionsCard extends ConsumerWidget {
  const _SessionsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(profileSessionsProvider);

    return SectionCard(
      title: context.tr('sessions'),
      subtitle: context.tr('sessionsDesc'),
      trailing: TextButton(
        onPressed: () => _revokeOthers(context, ref),
        child: Text(context.tr('revokeOthers')),
      ),
      child: sessions.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
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
                leading: Icon(_deviceIcon(session.deviceType)),
                title: Text(
                  session.browser.isEmpty
                      ? session.device
                      : '${session.browser} · ${session.platform}',
                ),
                subtitle: Text(
                  [
                    if (session.isCurrent) context.tr('currentSession'),
                    if (session.countryName != null) session.countryName!,
                    if (session.ipAddress != null) session.ipAddress!,
                    Formatters.dateTime(
                      session.lastActivityAt ??
                          session.lastUsedAt ??
                          session.createdAt,
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

  IconData _deviceIcon(String deviceType) {
    switch (deviceType) {
      case 'mobile':
        return Icons.phone_iphone_rounded;
      case 'tablet':
        return Icons.tablet_mac_rounded;
      default:
        return Icons.computer_rounded;
    }
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

/* --------------------------------------------------------------- activity */

class _ActivityCard extends ConsumerWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(securityActivityProvider);

    return SectionCard(
      title: context.tr('securityActivity'),
      subtitle: context.tr('securityActivityDesc'),
      child: activity.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: LoadingView(),
        ),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(securityActivityProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return Text(context.tr('securityActivityEmpty'));
          }
          return Column(
            children: [
              for (final event in events)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    event.isSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    color: event.isSuccess
                        ? context.dukavo.success
                        : context.dukavo.danger,
                  ),
                  title: Text(event.label),
                  subtitle: Text(
                    [
                      Formatters.dateTime(event.createdAt),
                      if (event.device != null) event.device!,
                      if (event.ipAddress != null) event.ipAddress!,
                    ].join(' · '),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/* ----------------------------------------------------------------- dialogs */

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

class _DisableDraft {
  const _DisableDraft({
    this.password = '',
    this.code,
    this.recoveryCode,
  });

  final String password;
  final String? code;
  final String? recoveryCode;
}

class _DisableDialog extends StatefulWidget {
  const _DisableDialog({
    this.requirePassword = true,
    this.titleKey = 'disableTwoFactor',
    this.introKey = 'disableWarning',
    this.confirmKey = 'disableTwoFactor',
  });

  final bool requirePassword;
  final String titleKey;
  final String introKey;
  final String confirmKey;

  @override
  State<_DisableDialog> createState() => _DisableDialogState();
}

class _DisableDialogState extends State<_DisableDialog> {
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _recovery = TextEditingController();
  bool _useRecovery = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _code.dispose();
    _recovery.dispose();
    super.dispose();
  }

  void _confirm() {
    if (widget.requirePassword && _password.text.isEmpty) {
      setState(() => _error = context.tr('currentPasswordRequired'));
      return;
    }
    final factor = _useRecovery ? _recovery.text.trim() : _code.text.trim();
    if (!widget.requirePassword && factor.isEmpty) {
      setState(() => _error = context.tr('requiresAuthenticationCode'));
      return;
    }
    if (widget.requirePassword && factor.isEmpty) {
      setState(() => _error = context.tr('requiresAuthenticationCode'));
      return;
    }
    Navigator.of(context).pop(
      _DisableDraft(
        password: _password.text,
        code: _useRecovery ? null : factor,
        recoveryCode: _useRecovery ? factor : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr(widget.titleKey)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr(widget.introKey)),
            const SizedBox(height: AppSpacing.sm),
            if (widget.requirePassword) ...[
              AppTextField(
                controller: _password,
                label: context.tr('currentPassword'),
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (_useRecovery)
              AppTextField(
                controller: _recovery,
                label: context.tr('recoveryCode'),
                prefixIcon: Icons.key_outlined,
              )
            else
              AppTextField(
                controller: _code,
                label: context.tr('twoFactorCode'),
                hint: context.tr('twoFactorCodePlaceholder'),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            TextButton(
              onPressed: () => setState(() {
                _useRecovery = !_useRecovery;
                _error = null;
              }),
              child: Text(
                context.tr(
                  _useRecovery ? 'useAuthenticatorCode' : 'useRecoveryCode',
                ),
              ),
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
        FilledButton(
          onPressed: _confirm,
          child: Text(context.tr(widget.confirmKey)),
        ),
      ],
    );
  }
}
