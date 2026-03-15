import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// KGF-styled splash screen shown while auth state is resolving.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF0A0A0F)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing gavel icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.gold.withAlpha(50),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 56,
                  color: ThemeConfig.gold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'EQUILEND AUCTION',
                style: ThemeConfig.heading.copyWith(
                  fontSize: 24,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: ThemeConfig.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
