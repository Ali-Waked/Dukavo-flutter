import '../../core/auth/permissions.dart';
import '../../features/auth/application/auth_controller.dart';
import 'route_paths.dart';

/// The first screen a signed-in user may actually open.
///
/// A role without `dashboard.view` must not land on a screen that would answer
/// 403, so the landing page is the first destination the server's permission
/// list allows. Platform operators land in the platform console instead of a
/// merchant workspace.
String homePathFor(Permissions permissions, {bool platformMode = false}) {
  if (platformMode) return RoutePaths.platformDashboard;
  if (permissions.canViewDashboard) return RoutePaths.dashboard;
  if (permissions.canViewOrders) return RoutePaths.orders;
  if (permissions.canViewProducts) return RoutePaths.products;
  if (permissions.canViewConversations) return RoutePaths.conversations;
  return RoutePaths.more;
}

/// Where the splash screen hands over once initialization is complete.
///
/// `null` means the auth bootstrap has not answered yet, so the splash keeps
/// its final brand frame visible and waits instead of guessing a destination.
String? splashDestination(AuthState auth) {
  switch (auth.status) {
    case AuthStatus.unknown:
      return null;
    case AuthStatus.unauthenticated:
      return RoutePaths.home;
    case AuthStatus.needsTenant:
      return RoutePaths.setup;
    case AuthStatus.platform:
      return RoutePaths.platformDashboard;
    case AuthStatus.authenticated:
      final permissions =
          auth.session?.permissionSet ?? const Permissions.empty();
      return homePathFor(permissions);
  }
}

/// Accept only same-origin absolute paths, so a crafted `redirect` query cannot
/// turn a successful login into an open redirect or a navigation loop.
String? sanitizeRedirect(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty || !value.startsWith('/')) return null;
  if (value.startsWith('//') || value.contains('\\')) return null;
  if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(value)) return null;

  final String decoded;
  try {
    decoded = Uri.decodeFull(value);
  } catch (_) {
    return null;
  }
  if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(decoded)) return null;

  final uri = Uri.tryParse(value);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  if (uri.path.isEmpty) return null;

  switch (uri.path) {
    case RoutePaths.login:
    case RoutePaths.register:
    case RoutePaths.forgotPassword:
    case RoutePaths.resetPassword:
    case RoutePaths.splash:
      return null;
  }
  return uri.toString();
}
