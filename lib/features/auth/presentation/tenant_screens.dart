import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_controller.dart';
import '../domain/auth_domain.dart';

/// Shown when a signed-in account has no workspace yet.
class TenantSetupScreen extends ConsumerStatefulWidget {
  const TenantSetupScreen({super.key});

  @override
  ConsumerState<TenantSetupScreen> createState() => _TenantSetupScreenState();
}

class _TenantSetupScreenState extends ConsumerState<TenantSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _storeName = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _storeName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).provisionTenant(
          name: _name.text.trim(),
          storeName:
              _storeName.text.trim().isEmpty ? null : _storeName.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final error =
        auth.errorKey != null ? context.tr(auth.errorKey!) : auth.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AppLogo(size: 56),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      context.tr('tenantSetupTitle'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('tenantSetupSubtitle'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (error != null && error.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          error,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      controller: _name,
                      label: context.tr('workspaceName'),
                      prefixIcon: Icons.business_outlined,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? context.tr('requiredField')
                              : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _storeName,
                      label: context.tr('storeName'),
                      helper: context.tr('optional'),
                      prefixIcon: Icons.storefront_outlined,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                      label: context.tr('createWorkspace'),
                      loading: auth.isSubmitting,
                      expand: true,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: context.tr('logout'),
                      variant: AppButtonVariant.text,
                      onPressed: auth.isSubmitting
                          ? null
                          : () => ref
                              .read(authControllerProvider.notifier)
                              .logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The workspace switcher, shared by the profile and settings screens.
Future<void> showTenantSwitcher(BuildContext context, WidgetRef ref) {
  final session = ref.read(currentSessionProvider);
  if (session == null || session.tenants.isEmpty) {
    return Future<void>.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(currentSessionProvider);
          final auth = ref.watch(authControllerProvider);
          final activeSlug = current?.activeTenant?.slug;

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.75,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Text(
                      context.tr('switchWorkspace'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: session.tenants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final TenantMembership tenant = session.tenants[index];
                        final isActive = tenant.slug == activeSlug;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            child: Text(Formatters.initials(tenant.name)),
                          ),
                          title: Text(tenant.name),
                          subtitle: Text(tenant.slug),
                          trailing: isActive
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: isActive || auth.isSubmitting
                              ? null
                              : () async {
                                  final ok = await ref
                                      .read(authControllerProvider.notifier)
                                      .switchTenant(tenant.slug);
                                  if (ok && sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                },
                        );
                      },
                    ),
                  ),
                  if (auth.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Text(
                        auth.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
