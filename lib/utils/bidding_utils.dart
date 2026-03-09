/// IPL-style bidding increment / decrement utility.
///
/// Currency convention (double):
///   1 Lakh  = 0.01  (i.e. 1 unit of "Lakh" stored as  0.01 Cr)
///   1 Crore = 1.0
///
/// Increment bands:
///   40L (0.40) → 1Cr (1.0)   : +10L (0.10)
///   1Cr        → 2Cr          : +20L (0.20)
///   2Cr        → 5Cr          : +50L (0.50)
///   5Cr        → 20Cr         : +1Cr (1.00)
///   20Cr       → 50Cr         : +2Cr (2.00)
///   >50Cr                     : +5Cr (5.00)
class BiddingUtils {
  /// Returns the increment value for the given [currentBid].
  static double getIncrement(double currentBid) {
    if (currentBid < 1.0) return 0.10; // +10L
    if (currentBid < 2.0) return 0.20; // +20L
    if (currentBid < 5.0) return 0.50; // +50L
    if (currentBid < 20.0) return 1.0; // +1Cr
    if (currentBid < 50.0) return 2.0; // +2Cr
    return 5.0; // +5Cr
  }

  /// Returns the decrement value for the given [currentBid].
  /// Mirrors the increment bands but reduces one step.
  static double getDecrement(double currentBid) {
    if (currentBid <= 0.40) return 0; // can't go below base
    if (currentBid <= 1.0) return 0.10;
    if (currentBid <= 2.0) return 0.20;
    if (currentBid <= 5.0) return 0.50;
    if (currentBid <= 20.0) return 1.0;
    if (currentBid <= 50.0) return 2.0;
    return 5.0;
  }

  /// Formats a Crore-based double to a human-readable string.
  ///   - 0.40 → "40L"
  ///   - 1.50 → "1.5 Cr"
  ///   - 2.00 → "2 Cr"
  static String formatPrice(double price) {
    if (price < 1.0) {
      final lakhs = (price * 100).round();
      return '${lakhs}L';
    }
    if (price == price.roundToDouble()) {
      return '${price.toInt()} Cr';
    }
    // Remove trailing zeros
    String formatted = price.toStringAsFixed(2);
    if (formatted.endsWith('0')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return '$formatted Cr';
  }

  /// Returns true if the team can afford the next bid.
  static bool canAffordBid(double nextBid, double teamPointsLeft) {
    return nextBid <= teamPointsLeft;
  }
}
