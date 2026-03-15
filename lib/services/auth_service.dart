import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

/// Possible states of the auth flow.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Manages auth state, user role, and exposes reactive updates via [ChangeNotifier].
class AuthService extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  String? _errorMessage;
  bool _isLoading = false;

  StreamSubscription<AuthState>? _authSub;

  // ── Getters ───────────────────────────────────────────────
  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isViewer => _user?.isViewer ?? true;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // ── Initialization ────────────────────────────────────────
  /// Call once at app startup. Listens for auth changes and resolves
  /// the initial session (if any).
  Future<void> init() async {
    _authSub = _authRepo.authStateChanges.listen(_onAuthStateChanged);
    await _resolveCurrentSession();
  }

  /// Handle Supabase auth events (sign-in, sign-out, token refresh).
  Future<void> _onAuthStateChanged(AuthState state) async {
    debugPrint('[AuthService] Auth event: ${state.event}');

    switch (state.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        await _resolveCurrentSession();
        break;
      case AuthChangeEvent.signedOut:
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  /// Resolve the current session — fetch user + role.
  Future<void> _resolveCurrentSession() async {
    final supabaseUser = _authRepo.currentUser;
    if (supabaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    try {
      _user = await _authRepo.buildAppUser();
      _status = AuthStatus.authenticated;
      debugPrint(
        '[AuthService] Signed in as ${_user?.email} (${_user?.role.name})',
      );
    } catch (e) {
      debugPrint('[AuthService] Failed to resolve session: $e');
      _status = AuthStatus.unauthenticated;
      _user = null;
    }
    notifyListeners();
  }

  // ── Actions ───────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepo.signInWithGoogle();
      // Auth state change listener will handle the rest
    } catch (e) {
      debugPrint('[AuthService] Google sign-in error: $e');
      _errorMessage = 'Sign-in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Force re-fetch role (useful after admin changes role in dashboard).
  Future<void> refreshRole() async {
    if (_authRepo.currentUser == null) return;
    _user = await _authRepo.buildAppUser();
    notifyListeners();
  }

  // ── Cleanup ───────────────────────────────────────────────
  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
