import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/app_user.dart';

/// Handles Supabase auth operations and role lookups.
class AuthRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Current Supabase auth user (null if not signed in).
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes (sign-in, sign-out, token refresh).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with Google OAuth.
  /// On web, redirects to Google consent screen.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirectUrl,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Fetch the role for [userId] from the `user_roles` table.
  /// Returns `AppRole.viewer` if no row is found (safe default).
  Future<AppRole> fetchUserRole(String userId) async {
    final data = await _client
        .from('user_roles')
        .select('role')
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return AppRole.viewer;
    final roleStr = data['role'] as String? ?? 'viewer';
    return roleStr == 'admin' ? AppRole.admin : AppRole.viewer;
  }

  /// Build an [AppUser] from the current session.
  Future<AppUser?> buildAppUser() async {
    final user = currentUser;
    if (user == null) return null;

    final role = await fetchUserRole(user.id);
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      role: role,
    );
  }

  /// Redirect URL after OAuth — includes full path for GitHub Pages.
  String get _redirectUrl {
    // For web, construct full URL including base path (e.g., /equilend-auction/)
    // Uri.base already includes the path, so we can use it directly
    final uri = Uri.base;

    // If path is root ('/'), just return origin. Otherwise include the path.
    if (uri.path == '/' || uri.path.isEmpty) {
      return uri.origin;
    }

    // For GitHub Pages subdirectories, return origin + base path
    // E.g., https://amanat-2003.github.io/equilend-auction/
    final basePath =
        uri.path.split('/').where((s) => s.isNotEmpty).firstOrNull ?? '';
    return basePath.isNotEmpty ? '${uri.origin}/$basePath/' : uri.origin;
  }
}
