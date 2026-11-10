import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/design_tokens.dart';
import '../api/api_exception.dart';
import '../pagination/paginated_notifier.dart';
import '../utils/formatters.dart';

/// The Dukavo logo.
///
/// The icon-only asset is used in square spots. Set [showWordmark] for headers,
/// auth screens and other wide spaces that should include the brand name.
///
/// The full wordmark ships in four language/theme combinations. Reading the
/// active [Locale] and [Theme] here means every caller gets the right artwork
/// and the image rebuilds when either changes; callers never choose an asset
/// themselves.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.showWordmark = false,
  });

  final double size;
  final bool showWordmark;

  static const Map<String, Map<String, String>> _fullLogos = {
    'en': {
      'light': 'assets/images/logo-full-en-light.png',
      'dark': 'assets/images/logo-full-en-dark.png',
    },
    'ar': {
      'light': 'assets/images/logo-full-ar-light.png',
      'dark': 'assets/images/logo-full-ar-dark.png',
    },
  };

  /// The full-logo asset for the current language and brightness.
  static String fullAssetFor(BuildContext context) {
    final language =
        Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'en';
    final theme =
        Theme.of(context).brightness == Brightness.dark ? 'dark' : 'light';

    return _fullLogos[language]![theme]!;
  }

  @override
  Widget build(BuildContext context) {
    final asset = showWordmark
        ? fullAssetFor(context)
        : 'assets/images/logo-icon.png';

    return Image.asset(
      asset,
      width: showWordmark ? null : size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Dukavo',
    );
  }
}

enum AppButtonVariant { filled, outlined, text, tonal, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.expand = false,
    this.height,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    final effectiveOnPressed = loading ? null : onPressed;
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.filled ||
                      variant == AppButtonVariant.danger
                  ? context.scheme.onPrimary
                  : context.scheme.primary,
            ),
          )
        : Text(label);

    late final Widget button;
    switch (variant) {
      case AppButtonVariant.filled:
        button = icon == null
            ? FilledButton(onPressed: effectiveOnPressed, child: child)
            : FilledButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: 18),
                label: child,
              );
      case AppButtonVariant.outlined:
        button = icon == null
            ? OutlinedButton(onPressed: effectiveOnPressed, child: child)
            : OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: 18),
                label: child,
              );
      case AppButtonVariant.text:
        button = icon == null
            ? TextButton(onPressed: effectiveOnPressed, child: child)
            : TextButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: 18),
                label: child,
              );
      case AppButtonVariant.tonal:
        button = icon == null
            ? FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.scheme.primaryContainer,
                  foregroundColor: context.scheme.onPrimaryContainer,
                  disabledBackgroundColor: colors.surfaceHigh,
                  disabledForegroundColor: colors.textMuted,
                ),
                onPressed: effectiveOnPressed,
                child: child,
              )
            : FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.scheme.primaryContainer,
                  foregroundColor: context.scheme.onPrimaryContainer,
                  disabledBackgroundColor: colors.surfaceHigh,
                  disabledForegroundColor: colors.textMuted,
                ),
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: 18),
                label: child,
              );
      case AppButtonVariant.danger:
        button = icon == null
            ? FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.scheme.error,
                  foregroundColor: context.scheme.onError,
                ),
                onPressed: effectiveOnPressed,
                child: child,
              )
            : FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.scheme.error,
                  foregroundColor: context.scheme.onError,
                ),
                onPressed: effectiveOnPressed,
                icon: Icon(icon, size: 18),
                label: child,
              );
    }

    final sized = height == null
        ? button
        : SizedBox(height: height, child: button);
    if (!expand) return sized;
    return SizedBox(width: double.infinity, child: sized);
  }
}

/// A comfortable, keyboard-aware text field for mobile forms.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      style: context.texts.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helper,
        counterText: widget.maxLength == null ? null : '',
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        suffixIcon: widget.suffix ??
            (widget.obscureText
                ? IconButton(
                    tooltip: _obscure
                        ? context.tr('showPassword')
                        : context.tr('hidePassword'),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  )
                : null),
      ),
    );
  }
}

/// A page-level header used at the top of every primary screen.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.actions,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.md,
    ),
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.texts;
    final colors = context.dukavo;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: theme.labelSmall?.copyWith(
                      color: context.scheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Text(
                  title,
                  style: theme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: theme.bodyMedium?.copyWith(color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Row(mainAxisSize: MainAxisSize.min, children: actions!),
          ],
        ],
      ),
    );
  }
}

/// A shared page scaffold with the product's safe-area and background rules.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.resizeToAvoidBottomInset = true,
    this.safeBottom = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final bool resizeToAvoidBottomInset;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      drawer: drawer,
      body: SafeArea(
        bottom: safeBottom,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

enum AppCardTone { surface, low, high, primary, transparent }

/// The canonical surface for grouped content.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.tone = AppCardTone.surface,
    this.border = true,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final AppCardTone tone;
  final bool border;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    final effectiveRadius = radius ?? AppRadius.card;
    final background = switch (tone) {
      AppCardTone.surface => colors.surface,
      AppCardTone.low => colors.surfaceLow,
      AppCardTone.high => colors.surfaceHigh,
      AppCardTone.primary => context.scheme.primaryContainer,
      AppCardTone.transparent => Colors.transparent,
    };

    final content = Padding(padding: padding, child: child);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: effectiveRadius,
        border: border && tone != AppCardTone.transparent
            ? Border.all(color: colors.border)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? content
            : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// A KPI tile with an icon well, a value and an optional trend.
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tint,
    this.onTap,
    this.trend,
    this.trendPositive = true,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? tint;
  final VoidCallback? onTap;
  final String? trend;
  final bool trendPositive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    final accent = tint ?? context.scheme.primary;
    final trendColor = trendPositive ? colors.success : colors.danger;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  width: compact ? 30 : 34,
                  height: compact ? 30 : 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: context.isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.xs + 2),
                  ),
                  child: Icon(icon, size: compact ? 16 : 18, color: accent),
                ),
              const Spacer(),
              if (trend != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: trendColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend!,
                      style: context.texts.labelSmall?.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? context.texts.titleLarge
                    : context.texts.headlineSmall)
                ?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding =
        const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.texts.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.dukavo.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.dukavo.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: context.scheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: context.texts.bodyMedium?.copyWith(
                  color: context.dukavo.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A pulsing placeholder used while a screen's first payload arrives.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.xs,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations == true) {
      return _bar(context, 1);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ).value;
        return _bar(context, 0.55 + (value * 0.45));
      },
    );
  }

  Widget _bar(BuildContext context, double opacity) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: context.dukavo.surfaceHigh.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );
  }
}

/// A skeleton list that mirrors the rhythm of a real card list.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.rows = 5,
    this.padding = AppSpacing.page,
    this.showAvatar = true,
  });

  final int rows;
  final EdgeInsetsGeometry padding;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => AppCard(
        child: Row(
          children: [
            if (showAvatar) ...[
              const LoadingSkeleton(width: 44, height: 44, radius: 14),
              const SizedBox(width: AppSpacing.sm),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingSkeleton(width: 180, height: 14),
                  SizedBox(height: 8),
                  LoadingSkeleton(width: 110, height: 11),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const LoadingSkeleton(width: 48, height: 24, radius: 12),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.dangerContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: colors.danger,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title ?? context.tr('error'),
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              message,
              style: context.texts.bodyMedium?.copyWith(
                color: colors.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: context.tr('retry'),
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.tonal,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.dukavo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                message!,
                style: context.texts.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                icon: Icons.add_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.loading,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => loading ?? const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error is ApiException
            ? error.message
            : context.tr('errorGeneric'),
        onRetry: onRetry,
      ),
    );
  }
}

/// A compact status pill. The dot and label make the state legible without
/// relying on colour alone.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.label,
    this.compact = false,
    this.showDot = true,
  });

  final String status;
  final String? label;
  final bool compact;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = _StatusColors.of(context, status);
    final text = label ?? context.tr(status);
    return Semantics(
      label: text,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          compact ? 7 : 9,
          compact ? 3 : 5,
          compact ? 9 : 11,
          compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: colors.foreground.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.foreground,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.labelSmall?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 10 : 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors(this.foreground, this.background);

  final Color foreground;
  final Color background;

  factory _StatusColors.of(BuildContext context, String status) {
    final colors = context.dukavo;
    switch (status) {
      case 'active':
      case 'paid':
      case 'delivered':
      case 'connected':
      case 'healthy':
      case 'success':
      case 'open':
      case 'confirmed':
      case 'completed':
        return _StatusColors(colors.success, colors.successContainer);
      case 'pending':
      case 'pending_confirmation':
      case 'draft':
      case 'unpaid':
      case 'partially_paid':
      case 'low_stock':
      case 'warning':
      case 'processing':
      case 'shipped':
      case 'reorder':
      case 'invited':
        return _StatusColors(colors.warning, colors.warningContainer);
      case 'cancelled':
      case 'failed':
      case 'blocked':
      case 'suspended':
      case 'out_of_stock':
      case 'error':
      case 'critical':
        return _StatusColors(colors.danger, colors.dangerContainer);
      case 'inactive':
      case 'closed':
      case 'read':
      case 'archived':
        return _StatusColors(
          colors.textSecondary,
          colors.surfaceHigh,
        );
      default:
        return _StatusColors(colors.info, colors.infoContainer);
    }
  }
}

/// A pill-shaped search field with a visible clear action.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: context.texts.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint ?? context.tr('search'),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: widget.controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: context.tr('clear'),
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                },
              ),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.tone = AppCardTone.surface,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final AppCardTone tone;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tone: tone,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: context.texts.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: context.texts.bodySmall?.copyWith(
                            color: context.dukavo.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.sm + 2),
          ],
          child,
        ],
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    required this.name,
    this.size = AppSizes.avatar,
  });

  final String? url;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final fallback = Container(
      width: size,
      height: size,
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        Formatters.initials(name),
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url!.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (context, value) => fallback,
                errorWidget: (context, value, error) => fallback,
              ),
      ),
    );
  }
}

class ConfirmDialog {
  const ConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          destructive ? Icons.warning_amber_rounded : Icons.help_outline,
          color: destructive
              ? Theme.of(dialogContext).colorScheme.error
              : Theme.of(dialogContext).colorScheme.primary,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class AppSnack {
  const AppSnack._();

  static void show(BuildContext context, String message,
      {bool isError = false}) {
    final colors = context.dukavo;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                size: 20,
                color: isError ? colors.danger : colors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isError ? colors.dangerContainer : null,
        ),
      );
  }
}

/// A quiet information banner for hints, warnings and empty-form guidance.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline_rounded,
    this.tone = InfoBannerTone.info,
  });

  final String message;
  final String? title;
  final IconData icon;
  final InfoBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      InfoBannerTone.info => (context.dukavo.info, context.dukavo.infoContainer),
      InfoBannerTone.success => (
          context.dukavo.success,
          context.dukavo.successContainer
        ),
      InfoBannerTone.warning => (
          context.dukavo.warning,
          context.dukavo.warningContainer
        ),
      InfoBannerTone.danger => (
          context.dukavo.danger,
          context.dukavo.dangerContainer
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: AppRadius.input,
        border: Border.all(color: colors.$1.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.$1),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: context.texts.labelLarge?.copyWith(
                      color: colors.$1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.dukavo.textSecondary,
                    height: 1.45,
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

enum InfoBannerTone { info, success, warning, danger }

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A list that owns the "load the next page near the bottom" behaviour.
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    this.empty,
    this.padding = AppSpacing.page,
    this.separator = const SizedBox(height: AppSpacing.sm),
  });

  final PaginatedState<T> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Widget? empty;
  final EdgeInsetsGeometry padding;
  final Widget separator;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeLoadMore);
    _controller.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.isLoading && state.items.isEmpty) {
      return const ListSkeleton();
    }

    if (state.error != null && state.items.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => widget.onRefresh(),
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: widget.empty ??
                  EmptyState(title: context.tr('noData')),
            ),
          ],
        ),
      );
    }

    final hasFooter = state.hasMore || state.isLoadingMore;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        itemCount: state.items.length + (hasFooter ? 1 : 0),
        separatorBuilder: (context, index) => widget.separator,
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return widget.itemBuilder(context, state.items[index], index);
        },
      ),
    );
  }
}

/// A grouped list used by settings-style screens.
class AppListGroup extends StatelessWidget {
  const AppListGroup({
    super.key,
    required this.children,
    this.title,
  });

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xxs,
              0,
              AppSpacing.xxs,
              AppSpacing.xs,
            ),
            child: Text(
              title!.toUpperCase(),
              style: context.texts.labelSmall?.copyWith(
                color: context.dukavo.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: context.dukavo.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The shared bottom navigation shell.
///
/// Keeps the product's top border and quiet shadow in one place so the
/// merchant, platform and public shells cannot drift apart.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final colors = context.dukavo;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                  spreadRadius: -8,
                ),
              ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          onDestinationSelected(index);
        },
        destinations: destinations,
      ),
    );
  }
}
