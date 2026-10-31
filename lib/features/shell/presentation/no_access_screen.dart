import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router/route_paths.dart';
import '../../../core/widgets/app_widgets.dart';

/// Shown when a route's required permission is absent from `/me`.
class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('noPermissionTitle'))),
      body: EmptyState(
        title: context.tr('noPermissionTitle'),
        message: context.tr('noPermissionMessage'),
        icon: Icons.lock_outline,
        actionLabel: context.tr('goToDashboard'),
        onAction: () => context.go(RoutePaths.dashboard),
      ),
    );
  }
}
