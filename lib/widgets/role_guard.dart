import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

/// Wraps children that should only be visible/interactable for admin users.
/// For viewers, shows [placeholder] (defaults to nothing).
class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? placeholder;

  const AdminOnly({super.key, required this.child, this.placeholder});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthService>().isAdmin;
    if (isAdmin) return child;
    return placeholder ?? const SizedBox.shrink();
  }
}

/// Wraps interactive widgets — shows them to all users but disables
/// interaction for viewers with an optional tooltip.
class AdminAction extends StatelessWidget {
  final Widget child;
  final String tooltip;

  const AdminAction({
    super.key,
    required this.child,
    this.tooltip = 'View-only mode — admins can perform this action',
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthService>().isAdmin;
    if (isAdmin) return child;

    return Tooltip(
      message: tooltip,
      child: Opacity(opacity: 0.4, child: IgnorePointer(child: child)),
    );
  }
}
