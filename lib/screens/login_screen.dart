import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../services/auth_service.dart';

/// KGF-styled Google sign-in screen with dark cinematic aesthetic.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthService>(
        builder: (context, auth, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D0D1A),
                  Color(0xFF0A0A0F),
                  Color(0xFF1A0A00),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ──────────────────────────────────
                    _buildLogo(),
                    const SizedBox(height: 48),

                    // ── Login Card ───────────────────────────
                    _buildLoginCard(context, auth),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Glow ring around logo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ThemeConfig.gold.withAlpha(80), width: 2),
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.gold.withAlpha(40),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.gavel_rounded,
            size: 64,
            color: ThemeConfig.gold,
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          'EQUILEND',
          style: ThemeConfig.heading.copyWith(fontSize: 36, letterSpacing: 6),
        ),
        const SizedBox(height: 4),
        Text(
          'AUCTION LEAGUE',
          style: ThemeConfig.label.copyWith(
            fontSize: 14,
            letterSpacing: 4,
            color: ThemeConfig.white50,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthService auth) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: ThemeConfig.glassCard(
        borderColor: ThemeConfig.gold.withAlpha(60),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle
          Text(
            'ENTER THE ARENA',
            style: ThemeConfig.subHeading.copyWith(
              letterSpacing: 2,
              color: ThemeConfig.gold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to join the auction',
            style: ThemeConfig.body.copyWith(color: ThemeConfig.white50),
          ),
          const SizedBox(height: 32),

          // ── Google Sign-In Button ──────────────────────
          _GoogleSignInButton(
            isLoading: auth.isLoading,
            onPressed: () => auth.signInWithGoogle(),
          ),

          // ── Error Message ──────────────────────────────
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ThemeConfig.crimson.withAlpha(20),
                border: Border.all(color: ThemeConfig.crimson.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: ThemeConfig.crimson,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.errorMessage!,
                      style: ThemeConfig.body.copyWith(
                        color: ThemeConfig.crimson,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Footer
          Text(
            'Powered by Supabase & Google OAuth',
            style: ThemeConfig.label.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Custom Google sign-in button with KGF neon styling.
class _GoogleSignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovering ? ThemeConfig.gold : ThemeConfig.white30,
            width: 1.5,
          ),
          color: _hovering
              ? ThemeConfig.gold.withAlpha(15)
              : ThemeConfig.surfaceColor,
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: ThemeConfig.gold.withAlpha(30),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeConfig.gold,
                      ),
                    )
                  else ...[
                    // Google "G" icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ThemeConfig.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4285F4),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Continue with Google',
                      style: ThemeConfig.subHeading.copyWith(
                        fontSize: 16,
                        color: ThemeConfig.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
