import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../utils/bidding_utils.dart';

/// Admin bidding controls: +/- increment, SOLD.
class BiddingControls extends StatelessWidget {
  final double currentBid;
  final bool hasPlayer;
  final bool hasActiveBidder;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onSold;

  const BiddingControls({
    super.key,
    required this.currentBid,
    required this.hasPlayer,
    required this.hasActiveBidder,
    this.canIncrement = true,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSold,
  });

  @override
  Widget build(BuildContext context) {
    final inc = BiddingUtils.getIncrement(currentBid);
    final dec = BiddingUtils.getDecrement(currentBid);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.white30, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Increment / Decrement Row ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _controlButton(
                icon: Icons.remove,
                label: '- ${BiddingUtils.formatPrice(dec)}',
                color: ThemeConfig.crimson,
                enabled: hasPlayer && dec > 0,
                onTap: onDecrement,
              ),
              const SizedBox(width: 20),
              // ── Current Bid Display ───────────────────────
              Column(
                children: [
                  Text('CURRENT BID', style: ThemeConfig.label),
                  const SizedBox(height: 4),
                  Text(
                    BiddingUtils.formatPrice(currentBid),
                    style: ThemeConfig.bidPrice.copyWith(fontSize: 36),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              _controlButton(
                icon: Icons.add,
                label: '+ ${BiddingUtils.formatPrice(inc)}',
                color: ThemeConfig.neonGreen,
                enabled: hasPlayer && canIncrement,
                onTap: onIncrement,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Action Button ─────────────────────────────────
          _actionButton(
            label: 'SOLD!',
            icon: Icons.gavel,
            color: ThemeConfig.gold,
            textColor: ThemeConfig.scaffoldBg,
            enabled: hasPlayer && hasActiveBidder,
            onTap: onSold,
            wide: true,
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(120), width: 1.5),
            color: color.withAlpha(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: ThemeConfig.label.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    Color? textColor,
    required bool enabled,
    required VoidCallback onTap,
    bool wide = false,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? ThemeConfig.white,
          disabledBackgroundColor: color.withAlpha(40),
          disabledForegroundColor: ThemeConfig.white30,
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 40 : 24,
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
