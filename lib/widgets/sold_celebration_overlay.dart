import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../config/theme_config.dart';

/// Full-screen celebration overlay shown when a player is sold.
/// Features: confetti cannons, glowing "SOLD!" text, player + team + captain
/// info with animated entrance. Sound is managed by the caller.
class SoldCelebrationOverlay extends StatefulWidget {
  final String playerName;
  final String teamName;
  final String captainName;
  final String formattedPrice;
  final AudioPlayer audioPlayer;
  final VoidCallback onDismiss;

  const SoldCelebrationOverlay({
    super.key,
    required this.playerName,
    required this.teamName,
    required this.captainName,
    required this.formattedPrice,
    required this.audioPlayer,
    required this.onDismiss,
  });

  @override
  State<SoldCelebrationOverlay> createState() => _SoldCelebrationOverlayState();
}

class _SoldCelebrationOverlayState extends State<SoldCelebrationOverlay>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiLeft;
  late final ConfettiController _confettiRight;
  late final ConfettiController _confettiCenter;

  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _slideController;
  late final AnimationController _glowController;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    // Confetti controllers
    _confettiLeft = ConfettiController(duration: const Duration(seconds: 3));
    _confettiRight = ConfettiController(duration: const Duration(seconds: 3));
    _confettiCenter = ConfettiController(duration: const Duration(seconds: 2));

    // Fade in the background
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Scale bounce for "SOLD!" text
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Slide up for details card
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Pulsing glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startCelebration();
  }

  void _startCelebration() async {
    // Sequence the animations
    _fadeController.forward();
    _confettiLeft.play();
    _confettiRight.play();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _confettiCenter.play();

    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiLeft.dispose();
    _confettiRight.dispose();
    _confettiCenter.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Dark backdrop
            GestureDetector(
              onTap: widget.onDismiss,
              child: Container(color: Colors.black.withAlpha(200)),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gavel icon with glow
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: ThemeConfig.gold.withAlpha(
                                (80 * _glowAnim.value).toInt(),
                              ),
                              blurRadius: 40 * _glowAnim.value,
                              spreadRadius: 10 * _glowAnim.value,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.gavel,
                          color: ThemeConfig.gold,
                          size: 48,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // "SOLD!" text with scale bounce
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, child) {
                        return Text(
                          'SOLD!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: ThemeConfig.gold,
                            letterSpacing: 6,
                            shadows: [
                              Shadow(
                                color: ThemeConfig.gold.withAlpha(
                                  (150 * _glowAnim.value).toInt(),
                                ),
                                blurRadius: 30 * _glowAnim.value,
                              ),
                              Shadow(
                                color: ThemeConfig.crimson.withAlpha(
                                  (100 * _glowAnim.value).toInt(),
                                ),
                                blurRadius: 60 * _glowAnim.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details card slides up
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _slideController,
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.all(28),
                        decoration: ThemeConfig.glassCard(
                          borderColor: ThemeConfig.gold.withAlpha(100),
                          borderRadius: 24,
                        ),
                        child: Column(
                          children: [
                            // Player name
                            Text(
                              widget.playerName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Price badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00F0FF),
                                    Color(0xFF0080FF),
                                  ],
                                ),
                              ),
                              child: Text(
                                widget.formattedPrice,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Container(
                              height: 1,
                              color: ThemeConfig.gold.withAlpha(40),
                            ),
                            const SizedBox(height: 20),

                            // Team name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shield,
                                  color: ThemeConfig.gold,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.teamName,
                                    style: ThemeConfig.heading.copyWith(
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Captain
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: ThemeConfig.neonCyan,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Captain: ${widget.captainName}',
                                  style: ThemeConfig.body.copyWith(
                                    color: ThemeConfig.neonCyan,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Congratulations
                            Text(
                              'Congratulations!',
                              style: ThemeConfig.body.copyWith(
                                color: ThemeConfig.goldLight,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Dismiss button
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _slideController,
                      child: OutlinedButton.icon(
                        onPressed: widget.onDismiss,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('CONTINUE'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeConfig.gold,
                          side: const BorderSide(color: ThemeConfig.gold),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confetti — left cannon
            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController: _confettiLeft,
                blastDirection: -pi / 4, // up-right
                emissionFrequency: 0.06,
                numberOfParticles: 12,
                maxBlastForce: 30,
                minBlastForce: 10,
                gravity: 0.15,
                colors: const [
                  ThemeConfig.gold,
                  ThemeConfig.goldLight,
                  ThemeConfig.crimson,
                  ThemeConfig.neonCyan,
                  ThemeConfig.neonGreen,
                  Colors.white,
                ],
              ),
            ),

            // Confetti — right cannon
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: _confettiRight,
                blastDirection: -3 * pi / 4, // up-left
                emissionFrequency: 0.06,
                numberOfParticles: 12,
                maxBlastForce: 30,
                minBlastForce: 10,
                gravity: 0.15,
                colors: const [
                  ThemeConfig.gold,
                  ThemeConfig.goldLight,
                  ThemeConfig.crimson,
                  ThemeConfig.neonCyan,
                  ThemeConfig.neonGreen,
                  Colors.white,
                ],
              ),
            ),

            // Confetti — center burst
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCenter,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.04,
                numberOfParticles: 20,
                maxBlastForce: 25,
                minBlastForce: 5,
                gravity: 0.2,
                colors: const [
                  ThemeConfig.gold,
                  ThemeConfig.goldLight,
                  ThemeConfig.crimson,
                  ThemeConfig.neonCyan,
                  Colors.white,
                  Colors.orangeAccent,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
