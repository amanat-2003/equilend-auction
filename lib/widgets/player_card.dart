import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../models/player.dart';
import '../utils/bidding_utils.dart';

/// Glassmorphism-styled Player Spotlight card with neon accents.
class PlayerCard extends StatelessWidget {
  final Player? player;
  final double currentBid;

  const PlayerCard({super.key, required this.player, required this.currentBid});

  @override
  Widget build(BuildContext context) {
    if (player == null) return _emptyState();

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: ThemeConfig.glassCard(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Player Photo (left) ───────────────────────────
          _buildAvatar(),
          const SizedBox(width: 28),

          // ── Info (right) ──────────────────────────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name ────────────────────────────────────
                Text(
                  player!.name.toUpperCase(),
                  style: ThemeConfig.heading.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 4),

                // ── Department ──────────────────────────────
                if (player!.department != null)
                  Text(player!.department!, style: ThemeConfig.body),
                const SizedBox(height: 12),

                // ── Tier Badge + Sports ─────────────────────
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [_buildTierBadge(), ..._buildSportsChips()],
                ),
                const SizedBox(height: 20),

                // ── Price Row ───────────────────────────────
                Row(
                  children: [
                    _priceColumn('BASE PRICE', player!.basePrice),
                    const SizedBox(width: 24),
                    Container(width: 1, height: 40, color: ThemeConfig.white30),
                    const SizedBox(width: 24),
                    _priceColumn('CURRENT BID', currentBid, highlight: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Private Helpers ─────────────────────────────────────────

  Widget _buildAvatar() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ThemeConfig.gold, width: 3),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.gold.withAlpha(60),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
        image: player!.photoUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(player!.photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: ThemeConfig.cardColor,
      ),
      child: player!.photoUrl == null
          ? const Icon(Icons.person, size: 72, color: ThemeConfig.white50)
          : null,
    );
  }

  Widget _buildTierBadge() {
    final colors = {
      1: ThemeConfig.gold,
      2: ThemeConfig.neonCyan,
      3: ThemeConfig.white50,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[player!.tier] ?? ThemeConfig.white30),
        color: (colors[player!.tier] ?? ThemeConfig.white30).withAlpha(25),
      ),
      child: Text(
        player!.tierLabel.toUpperCase(),
        style: ThemeConfig.label.copyWith(
          color: colors[player!.tier],
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<Widget> _buildSportsChips() {
    return player!.sports.map((s) {
      final icon = _sportIcon(s);
      return Chip(
        avatar: Icon(icon, size: 16, color: ThemeConfig.neonGreen),
        label: Text(
          s,
          style: ThemeConfig.label.copyWith(color: ThemeConfig.white),
        ),
        backgroundColor: ThemeConfig.surfaceColor,
        side: const BorderSide(color: ThemeConfig.white30),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );
    }).toList();
  }

  IconData _sportIcon(String sport) {
    switch (sport) {
      case 'Badminton':
        return Icons.sports_tennis;
      case 'Table Tennis':
        return Icons.sports_baseball;
      case 'Foosball':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }

  Widget _priceColumn(String label, double price, {bool highlight = false}) {
    return Column(
      children: [
        Text(label, style: ThemeConfig.label),
        const SizedBox(height: 4),
        Text(
          BiddingUtils.formatPrice(price),
          style: highlight
              ? ThemeConfig.bidPrice
              : ThemeConfig.subHeading.copyWith(
                  color: ThemeConfig.gold,
                  fontSize: 22,
                ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: ThemeConfig.glassCard(
        borderColor: ThemeConfig.white30.withAlpha(40),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search, size: 80, color: ThemeConfig.white30),
          const SizedBox(height: 16),
          Text(
            'SELECT A PLAYER\nTO BEGIN AUCTION',
            textAlign: TextAlign.center,
            style: ThemeConfig.subHeading.copyWith(color: ThemeConfig.white30),
          ),
        ],
      ),
    );
  }
}
