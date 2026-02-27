import 'package:flutter/material.dart';

/// KGF-inspired dark theme — gold / red / black palette with neon accents.
class ThemeConfig {
  // ── Core palette ──────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFF0A0A0F);
  static const Color surfaceColor = Color(0xFF141420);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE44D);
  static const Color crimson = Color(0xFFDC143C);
  static const Color crimsonDark = Color(0xFF8B0000);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color white = Colors.white;
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);

  // ── Text styles ───────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: gold,
    letterSpacing: 1.2,
  );

  static const TextStyle subHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: white,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: white70,
  );

  static const TextStyle bidPrice = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 42,
    fontWeight: FontWeight.w900,
    color: neonCyan,
    letterSpacing: 2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: white50,
    letterSpacing: 0.8,
  );

  // ── Glassmorphism decoration ──────────────────────────────
  static BoxDecoration glassCard({
    Color borderColor = const Color(0x33FFD700),
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x1AFFD700), // gold 10%
          Color(0x0DFFFFFF), // white 5%
          Color(0x1ADC143C), // crimson 10%
        ],
      ),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(color: gold.withAlpha(25), blurRadius: 30, spreadRadius: 2),
      ],
    );
  }

  // ── Theme Data ────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: surfaceColor,
      cardColor: cardColor,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: crimson,
        surface: surfaceColor,
        error: crimson,
        onPrimary: scaffoldBg,
        onSecondary: white,
        onSurface: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: heading,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: scaffoldBg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x33FFD700)),
        ),
      ),
    );
  }
}
