import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/permissions.dart';
import '../../../core/providers.dart';
import '../data/auth_data.dart';
import '../domain/auth_domain.dart';

enum AuthStatus {
  /// Reading the stored token and calling `/me`.
  unknown,

  /// No usable token.
  unauthenticated,

  /// A token exists but the account has no workspace yet.
  needsTenant,

  /// Signed in with an active tenant.
  authenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.errorKey,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStatus status;
  final Session? session;

  /// A localisation key the UI should prefer over [errorMessage].
  final String? errorKey;

  /// A server-supplied message, already localised by `Accept-Language`.
  final String? errorMessage;

  final bool isSubmitting;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isBootstrapping => status == AuthStatus.unknown;

  AuthState copyWith({
    AuthStatus? status,
    Session? session,
    String? errorKey,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, {bool autoBootstrap = true})
      : super(const AuthState(status: AuthStatus.unknown)) {
    if (autoBootstrap) {
      unawaited(bootstrap());
    }
  }

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    state = const AuthState(status: AuthStatus.unknown);
    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      state = AuthState(
        status:
            session.hasTenant ? AuthStatus.authenticated : AuthStatus.needsTenant,
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
      final session = await _repository.login(email: email, password: password);
      state = AuthState(
        status:
            session.hasTenant ? AuthStatus.authenticated : AuthStatus.needsTenant,
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
        status:
            session.hasTenant ? AuthStatus.authenticated : AuthStatus.needsTenant,
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
        status:
            session.hasTenant ? AuthStatus.authenticated : AuthStatus.needsTenant,
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
        status: session.hasTenant
            ? AuthStatus.authenticated
            : AuthStatus.needsTenant,
        session: session,
      );
    } catch (_) {
      // A refresh is cosmetic; the edit itself already succeeded.
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isSubmitting: true);
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
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(ref.watch(authRepositoryProvider));
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
