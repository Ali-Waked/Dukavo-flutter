import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers.dart';
import '../../notifications/application/push_service.dart';
import '../data/auth_data.dart';
import '../domain/auth_domain.dart';

enum AuthStatus {
  /// Reading the stored token and calling `/me`.
  unknown,

  /// No usable token.
  unauthenticated,

  /// A token exists but the account has no workspace yet.
  needsTenant,

  /// Signed in as a Dukavo operator without a merchant workspace.
  platform,

  /// Signed in with an active tenant.
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.twoFactorChallenge,
    this.errorKey,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStatus status;
  final Session? session;

  /// Present between a password check and the second step. Never lets the rest
  /// of the app treat the visitor as signed in.
  final TwoFactorChallenge? twoFactorChallenge;

  /// A localisation key the UI should prefer over [errorMessage].
  final String? errorKey;

  /// A server-supplied message, already localised by `Accept-Language`.
  final String? errorMessage;

  final bool isSubmitting;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated || status == AuthStatus.platform;
  bool get isPlatformMode => status == AuthStatus.platform;
  bool get isBootstrapping => status == AuthStatus.unknown;
  bool get awaitingTwoFactor => twoFactorChallenge != null;

  AuthState copyWith({
    AuthStatus? status,
    Session? session,
    TwoFactorChallenge? twoFactorChallenge,
    bool clearTwoFactorChallenge = false,
    String? errorKey,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      twoFactorChallenge: clearTwoFactorChallenge
          ? null
          : (twoFactorChallenge ?? this.twoFactorChallenge),
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(
    this._repository, {
    bool autoBootstrap = true,
    Future<void> Function()? onBeforeLogout,
  })  : _onBeforeLogout = onBeforeLogout,
        super(const AuthState(status: AuthStatus.unknown)) {
    if (autoBootstrap) {
      unawaited(bootstrap());
    }
  }

  final AuthRepository _repository;

  /// Runs while the bearer token is still valid. Push uses it to revoke this
  /// installation before logout destroys the credential.
  final Future<void> Function()? _onBeforeLogout;

  Future<void> bootstrap() async {
    state = const AuthState(status: AuthStatus.unknown);
    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      state = AuthState(
        status: _statusFor(session),
        session: session,
      );
    } on ApiException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorKey: error.isNetworkError ? 'errorNetwork' : null,
        errorMessage: error.isNetworkError ? null : error.message,
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorKey: 'errorGeneric',
      );
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final outcome = await _repository.login(email: email, password: password);

      final challenge = outcome.challenge;
      if (challenge != null) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          twoFactorChallenge: challenge,
        );
        return false;
      }

      final session = outcome.session!;
      state = AuthState(
        status: _statusFor(session),
        session: session,
      );
      return true;
    } on ApiException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorKey: _loginErrorKey(error),
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorKey: 'errorGeneric',
      );
      return false;
    }
  }

  /// Answer the second step. On success the challenge is discarded and the
  /// normal session state takes over; on failure it stays so the user can retry
  /// without re-entering their password.
  Future<bool> completeTwoFactor({
    String? code,
    String? recoveryCode,
  }) async {
    final challenge = state.twoFactorChallenge;
    if (challenge == null || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _repository.completeTwoFactor(
        challengeToken: challenge.challengeToken,
        code: code,
        recoveryCode: recoveryCode,
      );
      state = AuthState(
        status: _statusFor(session),
        session: session,
      );
      return true;
    } on ApiException catch (error) {
      final expired = error.statusCode == 422 &&
          (error.message.toLowerCase().contains('expired') ||
              error.message.toLowerCase().contains('challenge'));
      state = AuthState(
        status: AuthStatus.unauthenticated,
        twoFactorChallenge: expired ? null : challenge,
        errorKey: _loginErrorKey(error),
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        twoFactorChallenge: challenge,
        errorKey: 'errorGeneric',
      );
      return false;
    }
  }

  /// Abandon the second step and return to the password form.
  void cancelTwoFactor() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> provisionTenant({
    required String name,
    String? storeName,
  }) async {
    if (state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _repository.provisionTenant(
        name: name,
        storeName: storeName,
      );
      state = AuthState(
        status: _statusFor(session),
        session: session,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorKey: error.isValidation ? 'validationError' : null,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorKey: 'errorGeneric');
      return false;
    }
  }

  Future<bool> switchTenant(String slug) async {
    if (state.session == null || state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _repository.switchTenant(slug);
      state = AuthState(
        status: _statusFor(session),
        session: session,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorKey: 'errorGeneric');
      return false;
    }
  }

  /// Move the signed-in operator from a merchant workspace back to the
  /// platform console. The bearer token is untouched, so this is a context
  /// switch rather than a sign-out.
  Future<bool> enterPlatformMode() async {
    final session = state.session;
    if (session == null || !session.canUsePlatform || state.isSubmitting) {
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final next = await _repository.enterPlatformMode();
      state = AuthState(
        status: _statusFor(next),
        session: next,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorKey: 'errorGeneric');
      return false;
    }
  }

  /// Re-read `/me` after the user edits their own profile.
  ///
  /// The session holds the display name and avatar every other screen reads,
  /// so a profile change that only refreshed the profile screen would leave the
  /// shell showing stale data.
  Future<void> refreshSession() async {
    try {
      final session = await _repository.restoreSession();
      if (session == null || !mounted) return;
      state = state.copyWith(
        status: _statusFor(session),
        session: session,
      );
    } catch (_) {
      // A refresh is cosmetic; the edit itself already succeeded.
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isSubmitting: true);

    try {
      await _onBeforeLogout?.call();
    } catch (_) {
      // A failed token revocation must not trap the merchant in the app.
    }

    try {
      await _repository.logout();
    } catch (_) {
      await _repository.clearLocalSession();
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Called by [ApiClient] when the server rejects a token with 401.
  void handleUnauthorized() {
    unawaited(_repository.clearLocalSession());
    if (mounted) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        errorKey: 'sessionExpired',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Ask Fortify to resend the verification email for the signed-in account.
  ///
  /// Failures propagate: the verify screen shows the server's own refusal
  /// (the endpoint is session-guarded) rather than pretending the mail left.
  Future<void> resendVerificationEmail() {
    return _repository.resendVerificationEmail();
  }

  /// The one place that decides what a restored session may open.
  ///
  /// An active workspace always means merchant context. Without one, only a
  /// backend-confirmed platform operator may enter the platform console; every
  /// other account belongs in workspace onboarding.
  AuthStatus _statusFor(Session session) {
    if (session.hasTenant) return AuthStatus.authenticated;
    if (session.canUsePlatform) return AuthStatus.platform;
    return AuthStatus.needsTenant;
  }

  String? _loginErrorKey(ApiException error) {
    if (error.isNetworkError) return 'errorNetwork';
    if (error.statusCode == 401) return 'invalidCredentials';
    if (error.statusCode == 403) return 'accountSuspended';
    if (error.isValidation) return 'validationError';
    return null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    remote: AuthRemoteDataSource(apiClient),
    tokenStore: ref.watch(tokenStoreProvider),
    preferences: ref.watch(appPreferencesProvider),
    apiClient: apiClient,
    cache: ref.watch(cacheManagerProvider),
    queue: ref.watch(offlineQueueProvider),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(
    ref.watch(authRepositoryProvider),
    onBeforeLogout: ref.read(pushServiceProvider).unregisterToken,
  );
  final apiClient = ref.watch(apiClientProvider);
  apiClient.onUnauthorized = controller.handleUnauthorized;
  ref.onDispose(() {
    apiClient.onUnauthorized = null;
  });
  return controller;
});

final currentSessionProvider = Provider<Session?>((ref) {
  return ref.watch(authControllerProvider).session;
});

final permissionsProvider = Provider<Permissions>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session == null ? const Permissions.empty() : session.permissionSet;
});
