/// User role enum matching Supabase `app_role` type.
enum AppRole { admin, viewer }

/// Authenticated user with their assigned role.
class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final AppRole role;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.role = AppRole.viewer,
  });

  bool get isAdmin => role == AppRole.admin;
  bool get isViewer => role == AppRole.viewer;

  factory AppUser.fromMap(Map<String, dynamic> map, {AppRole? role}) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      displayName: map['raw_user_meta_data']?['full_name'] as String?,
      avatarUrl: map['raw_user_meta_data']?['avatar_url'] as String?,
      role: role ?? AppRole.viewer,
    );
  }
}
