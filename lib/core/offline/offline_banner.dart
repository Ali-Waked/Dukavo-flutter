import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/design_tokens.dart';
import '../providers.dart';
import 'connectivity.dart';

/// A quiet, global connection banner.
///
/// It is intentionally not a navigation surface: reconnecting only refreshes
/// data and flushes the safe queue. It sits above the router's child and
/// removes the duplicate status-bar inset so screens do not jump.
class OfflineBannerHost extends ConsumerStatefulWidget {
  const OfflineBannerHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OfflineBannerHost> createState() => _OfflineBannerHostState();
}

class _OfflineBannerHostState extends ConsumerState<OfflineBannerHost> {
  Timer? _backOnlineTimer;
  bool _showBackOnline = false;

  @override
  void dispose() {
    _backOnlineTimer?.cancel();
    super.dispose();
  }

  void _flashBackOnline() {
    _backOnlineTimer?.cancel();
    setState(() => _showBackOnline = true);
    _backOnlineTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showBackOnline = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final sync = ref.watch(syncManagerProvider);

    ref.listen<ConnectivityStatus>(
      connectivityProvider.select((value) => value.status),
      (previous, next) {
        if (previous == ConnectivityStatus.offline &&
            next == ConnectivityStatus.online) {
          _flashBackOnline();
        }
      },
    );

    final offline = connectivity.isOffline;
    final syncing = sync.isSyncing;
    final pending = sync.pendingMutations;

    // A completed sync hides the "back online" confirmation early; the user
    // has already seen the app react.
    if (offline) _showBackOnline = false;

    final _Banner? banner;
    if (offline) {
      banner = _Banner(
        icon: Icons.cloud_off_rounded,
        title: context.tr('offlineTitle'),
        message: context.tr('offlineBody'),
        background: context.dukavo.warningContainer,
        foreground: context.dukavo.onWarning,
        actionLabel: context.tr('retry'),
        onAction: () => connectivity.check(force: true),
      );
    } else if (syncing) {
      banner = _Banner(
        icon: Icons.sync_rounded,
        title: context.tr('offlineSyncingTitle'),
        message: pending > 0
            ? context.tr('offlineSyncingBody', args: {'count': pending})
            : context.tr('offlineRefreshing'),
        background: context.dukavo.infoContainer,
        foreground: context.dukavo.onInfo,
        progress: true,
      );
    } else if (_showBackOnline) {
      banner = _Banner(
        icon: Icons.cloud_done_rounded,
        title: context.tr('offlineBackOnline'),
        message: context.tr('offlineBackOnlineBody'),
        background: context.dukavo.successContainer,
        foreground: context.dukavo.onSuccess,
      );
    } else {
      banner = null;
    }

    final topInset = MediaQuery.paddingOf(context).top;
    return Column(
      children: [
        if (banner != null)
          Material(
            color: banner.background,
            child: Padding(
              padding: EdgeInsets.only(top: topInset),
              child: banner,
            ),
          ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: banner != null,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.title,
    required this.message,
    required this.background,
    required this.foreground,
    this.actionLabel,
    this.onAction,
    this.progress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color background;
  final Color foreground;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            if (progress)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            else
              Icon(icon, size: 20, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: texts.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    message,
                    style: texts.bodySmall?.copyWith(
                      color: foreground.withValues(alpha: 0.86),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
