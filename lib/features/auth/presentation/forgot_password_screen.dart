import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/design_tokens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitting = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text);
      if (!mounted) return;
      setState(() {
        _sent = true;
        _submitting = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('errorGeneric');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    final texts = context.texts;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('forgotPassword'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _sent
                  ? _SentState(onBack: () => Navigator.of(context).pop())
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: context.scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              color: context.scheme.onPrimaryContainer,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            context.tr('forgotPasswordTitle'),
                            style: texts.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            context.tr('forgotPasswordSubtitle'),
                            style: texts.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (_error != null) ...[
                            StatusBanner(
                              message: _error!,
                              tone: StatusBannerTone.error,
                              icon: Icons.error_outline_rounded,
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppTextField(
                                  controller: _email,
                                  label: context.tr('email'),
                                  hint: context.tr('emailHint'),
                                  prefixIcon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submit(),
                                  validator: (value) {
                                    final required = Validators.required(value);
                                    if (required != null) {
                                      return context.tr('requiredField');
                                    }
                                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(value!.trim())) {
                                      return context.tr('invalidEmail');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppButton(
                                  label: context.tr('sendResetLink'),
                                  loading: _submitting,
                                  expand: true,
                                  icon: Icons.send_rounded,
                                  onPressed: _submit,
                                ),
                              ],
                            ),
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

class _SentState extends StatelessWidget {
  const _SentState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.successContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 34,
              color: colors.success,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.tr('resetLinkSent'),
          style: context.texts.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.tr('resetLinkSentMessage'),
          style: context.texts.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: context.tr('back'),
          expand: true,
          icon: Icons.arrow_back_rounded,
          onPressed: onBack,
        ),
      ],
    );
  }
}
