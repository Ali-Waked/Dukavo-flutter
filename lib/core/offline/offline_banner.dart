import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/design_tokens.dart';
import '../providers.dart';
import '../widgets/app_widgets.dart';
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

    final StatusBanner? banner;
    if (offline) {
      banner = StatusBanner(
        tone: StatusBannerTone.warning,
        icon: Icons.cloud_off_rounded,
        title: context.tr('offlineTitle'),
        message: context.tr('offlineBody'),
        actionLabel: context.tr('retry'),
        onAction: () => connectivity.check(force: true),
      );
    } else if (syncing) {
      banner = StatusBanner(
        tone: StatusBannerTone.info,
        icon: Icons.sync_rounded,
        title: context.tr('offlineSyncingTitle'),
        message: pending > 0
            ? context.tr('offlineSyncingBody', args: {'count': pending})
            : context.tr('offlineRefreshing'),
        progress: true,
      );
    } else if (_showBackOnline) {
      banner = StatusBanner(
        tone: StatusBannerTone.success,
        icon: Icons.cloud_done_rounded,
        title: context.tr('offlineBackOnline'),
        message: context.tr('offlineBackOnlineBody'),
      );
    } else {
      banner = null;
    }

    final topInset = MediaQuery.paddingOf(context).top;
    return Column(
      children: [
        if (banner != null)
          Material(
            color: context.dukavo.background,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                topInset + AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
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
