import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// User profile button shown in the header — displays avatar, role badge,
/// and sign-out option.
class UserProfileButton extends StatelessWidget {
  const UserProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: ThemeConfig.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeConfig.gold.withAlpha(40)),
      ),
      onSelected: (value) {
        if (value == 'sign_out') _showSignOutDialog(context, auth);
        if (value == 'refresh_role') auth.refreshRole();
      },
      itemBuilder: (_) => [
        // User info header
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'User',
                style: ThemeConfig.subHeading.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(user.email, style: ThemeConfig.label),
              const SizedBox(height: 6),
              _roleBadge(user.role),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'refresh_role',
          child: Row(
            children: [
              Icon(Icons.refresh, size: 16, color: ThemeConfig.neonCyan),
              SizedBox(width: 8),
              Text(
                'Refresh Role',
                style: TextStyle(color: ThemeConfig.white70),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'sign_out',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16, color: ThemeConfig.crimson),
              SizedBox(width: 8),
              Text('Sign Out', style: TextStyle(color: ThemeConfig.crimson)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: user.isAdmin
                ? ThemeConfig.gold.withAlpha(80)
                : ThemeConfig.white30,
          ),
          color: ThemeConfig.surfaceColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 14,
              backgroundColor: ThemeConfig.gold.withAlpha(40),
              backgroundImage: user.avatarUrl != null
                  ? CachedNetworkImageProvider(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      (user.displayName ?? user.email)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: ThemeConfig.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            // Role badge
            _miniRoleBadge(user.role),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: ThemeConfig.white50,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(AppRole role) {
    final isAdmin = role == AppRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isAdmin
            ? ThemeConfig.gold.withAlpha(25)
            : ThemeConfig.neonCyan.withAlpha(20),
        border: Border.all(
          color: isAdmin
              ? ThemeConfig.gold.withAlpha(80)
              : ThemeConfig.neonCyan.withAlpha(60),
        ),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'VIEWER',
        style: ThemeConfig.label.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isAdmin ? ThemeConfig.gold : ThemeConfig.neonCyan,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _miniRoleBadge(AppRole role) {
    final isAdmin = role == AppRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isAdmin
            ? ThemeConfig.gold.withAlpha(25)
            : ThemeConfig.neonCyan.withAlpha(15),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'VIEW',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isAdmin ? ThemeConfig.gold : ThemeConfig.neonCyan,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => _SignOutConfirmDialog(
        userName: auth.user?.displayName ?? 'User',
        onConfirm: () => auth.signOut(),
      ),
    );
  }
}

/// KGF-styled sign-out confirmation dialog with glow and cinematic flair.
class _SignOutConfirmDialog extends StatelessWidget {
  final String userName;
  final VoidCallback onConfirm;

  const _SignOutConfirmDialog({
    required this.userName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28),
        decoration:
            ThemeConfig.glassCard(
              borderColor: ThemeConfig.crimson.withAlpha(60),
            ).copyWith(
              boxShadow: [
                BoxShadow(
                  color: ThemeConfig.crimson.withAlpha(30),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing exit icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.crimson.withAlpha(20),
                border: Border.all(
                  color: ThemeConfig.crimson.withAlpha(60),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConfig.crimson.withAlpha(40),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: ThemeConfig.crimson,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'LEAVING THE ARENA?',
              style: ThemeConfig.subHeading.copyWith(
                color: ThemeConfig.crimson,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              'You\'re about to sign out, $userName.',
              textAlign: TextAlign.center,
              style: ThemeConfig.body.copyWith(color: ThemeConfig.white50),
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: _buildButton(
                    context,
                    label: 'STAY',
                    icon: Icons.shield,
                    color: ThemeConfig.white30,
                    textColor: ThemeConfig.white70,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm sign-out
                Expanded(
                  child: _buildButton(
                    context,
                    label: 'SIGN OUT',
                    icon: Icons.logout,
                    color: ThemeConfig.crimson,
                    textColor: ThemeConfig.white,
                    filled: true,
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color.withAlpha(filled ? 0 : 100)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? textColor : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: filled ? textColor : color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
