import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../services/auction_service.dart';
import '../utils/bidding_utils.dart';
import '../widgets/bidding_controls.dart';
import '../widgets/player_card.dart';
import '../widgets/player_picker_dialog.dart';
import '../widgets/team_list_item.dart';
import '../widgets/sold_celebration_overlay.dart';
import '../widgets/team_selection_grid.dart';

/// Main auction screen — responsive split-view for web.
/// Left (70%): Active auction + controls.
/// Right (30%): Team sidebar with live budgets.
class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize auction service on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionService>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuctionService>(
        builder: (context, auction, _) {
          if (auction.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeConfig.gold),
            );
          }
          if (auction.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: ThemeConfig.gold,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connection Error',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auction.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => auction.init(),
                    ),
                  ],
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive breakpoint
              if (constraints.maxWidth >= 900) {
                return _wideLayout(auction);
              }
              return _narrowLayout(auction);
            },
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  WIDE LAYOUT  (≥ 900px)  — 70/30 split
  // ════════════════════════════════════════════════════════════
  Widget _wideLayout(AuctionService auction) {
    return Row(
      children: [
        // ── LEFT: Auction Area (70%) ────────────────────────
        Expanded(flex: 7, child: _auctionArea(auction)),
        // ── Divider ─────────────────────────────────────────
        Container(width: 1, color: ThemeConfig.white30),
        // ── RIGHT: Team Sidebar (30%) ───────────────────────
        Expanded(flex: 3, child: _teamSidebar(auction)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  //  NARROW LAYOUT  (< 900px)  — stacked
  // ════════════════════════════════════════════════════════════
  Widget _narrowLayout(AuctionService auction) {
    return Column(
      children: [
        Expanded(flex: 7, child: _auctionArea(auction)),
        Container(height: 1, color: ThemeConfig.white30),
        Expanded(flex: 3, child: _teamSidebar(auction)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  //  AUCTION AREA
  // ════════════════════════════════════════════════════════════
  Widget _auctionArea(AuctionService auction) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0D1A), Color(0xFF0A0A0F)],
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          _buildHeader(auction),
          const SizedBox(height: 8),
          // ── Scrollable Body ─────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Column(
                children: [
                  // Player Card
                  PlayerCard(
                    player: auction.currentPlayer,
                    currentBid: auction.currentBid,
                  ),
                  const SizedBox(height: 24),

                  // Team Selection Grid
                  if (auction.currentPlayer != null)
                    TeamSelectionGrid(
                      teams: auction.teams,
                      activeBidderId: auction.activeBidder?.teamId,
                      onTeamSelected: (team) => auction.setActiveBidder(team),
                    ),
                  const SizedBox(height: 20),

                  // Bidding Controls
                  BiddingControls(
                    currentBid: auction.currentBid,
                    hasPlayer: auction.currentPlayer != null,
                    hasActiveBidder: auction.activeBidder != null,
                    canIncrement: auction.canIncrement,
                    onIncrement: () => auction.incrementBid(),
                    onDecrement: () => auction.decrementBid(),
                    onSold: () => _handleSold(auction),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TEAM SIDEBAR
  // ════════════════════════════════════════════════════════════
  Widget _teamSidebar(AuctionService auction) {
    return Container(
      color: ThemeConfig.scaffoldBg,
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ThemeConfig.white30, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.leaderboard,
                  color: ThemeConfig.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'TEAM STANDINGS',
                  style: ThemeConfig.label.copyWith(
                    color: ThemeConfig.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Team List (sorted by highest remaining purse)
          Expanded(
            child: Builder(
              builder: (_) {
                final sorted = List.of(auction.teams)
                  ..sort((a, b) => b.pointsLeft.compareTo(a.pointsLeft));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final team = sorted[i];
                    final boughtPlayers = auction.allPlayers
                        .where((p) => p.soldToTeamId == team.teamId)
                        .toList();
                    return TeamListItem(
                      team: team,
                      isActiveBidder:
                          auction.activeBidder?.teamId == team.teamId,
                      boughtPlayers: boughtPlayers,
                      onTap: () => auction.setActiveBidder(team),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════════════════
  Widget _buildHeader(AuctionService auction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0A00), Color(0xFF0D0D1A)],
        ),
        border: Border(bottom: BorderSide(color: Color(0x33FFD700), width: 1)),
      ),
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/equilend.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Available count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ThemeConfig.neonCyan.withAlpha(20),
              border: Border.all(color: ThemeConfig.neonCyan.withAlpha(60)),
            ),
            child: Text(
              '${auction.availablePlayers.length} Players Left',
              style: ThemeConfig.label.copyWith(
                color: ThemeConfig.neonCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Pick next player
          ElevatedButton.icon(
            onPressed: () => _showPlayerPicker(auction),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('SELECT PLAYER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.gold,
              foregroundColor: ThemeConfig.scaffoldBg,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Random player by tier
          PopupMenuButton<int>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ThemeConfig.neonCyan.withAlpha(20),
                border: Border.all(color: ThemeConfig.neonCyan.withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shuffle,
                    size: 16,
                    color: ThemeConfig.neonCyan,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'RANDOM',
                    style: ThemeConfig.label.copyWith(
                      color: ThemeConfig.neonCyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            color: ThemeConfig.cardColor,
            onSelected: (tier) => auction.selectRandomByTier(tier),
            itemBuilder: (_) => [
              _tierMenuItem(1, 'Tier 1 — Star', ThemeConfig.gold),
              _tierMenuItem(2, 'Tier 2 — Mid', ThemeConfig.neonCyan),
              _tierMenuItem(3, 'Tier 3 — Base', ThemeConfig.white50),
            ],
          ),
          const SizedBox(width: 8),
          // Manual refresh button
          IconButton(
            onPressed: () async {
              await auction.refreshAll();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data refreshed'),
                    duration: Duration(seconds: 1),
                    backgroundColor: ThemeConfig.neonGreen,
                  ),
                );
              }
            },
            tooltip: 'Refresh data',
            icon: const Icon(
              Icons.refresh,
              color: ThemeConfig.white50,
              size: 20,
            ),
          ),
          // Restart Auction button
          IconButton(
            onPressed: () => _handleResetAuction(auction),
            tooltip: 'Restart Auction',
            icon: const Icon(
              Icons.restart_alt,
              color: ThemeConfig.crimson,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  ACTIONS
  // ════════════════════════════════════════════════════════════

  PopupMenuEntry<int> _tierMenuItem(int tier, String label, Color color) {
    return PopupMenuItem<int>(
      value: tier,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(label, style: ThemeConfig.body.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  void _showPlayerPicker(AuctionService auction) {
    showDialog(
      context: context,
      builder: (_) => PlayerPickerDialog(
        availablePlayers: auction.availablePlayers,
        onPlayerSelected: (player) => auction.selectPlayer(player),
      ),
    );
  }

  void _handleResetAuction(AuctionService auction) async {
    // First confirmation
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: ThemeConfig.crimson,
              size: 28,
            ),
            const SizedBox(width: 10),
            const Text(
              'RESTART AUCTION?',
              style: TextStyle(
                color: ThemeConfig.crimson,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will reset the ENTIRE auction:',
              style: ThemeConfig.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _resetWarningItem('All players will become available again'),
            _resetWarningItem('All team budgets will be restored to full'),
            _resetWarningItem('All squad assignments will be cleared'),
            _resetWarningItem('Current bidding session will be lost'),
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
                      'This action CANNOT be undone!',
                      style: ThemeConfig.body.copyWith(
                        color: ThemeConfig.crimson,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.crimson,
            ),
            child: const Text('YES, RESTART'),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // Second confirmation — type to confirm
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ResetConfirmDialog(),
    );

    if (secondConfirm == true) {
      await auction.resetAuction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Auction has been reset. All players are available again.',
            ),
            backgroundColor: ThemeConfig.neonGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _resetWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(
            Icons.remove_circle_outline,
            size: 14,
            color: ThemeConfig.crimson,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: ThemeConfig.body.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _handleSold(AuctionService auction) async {
    // Safety check
    final error = auction.validateSale();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: ThemeConfig.crimson),
      );
      return;
    }

    // Capture sale details before confirmSale() clears them
    final playerName = auction.currentPlayer!.name;
    final teamName = auction.activeBidder!.teamName;
    final captainName = auction.activeBidder!.captainName;
    final formattedPrice = BiddingUtils.formatPrice(auction.currentBid);

    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.gavel, color: ThemeConfig.gold),
            const SizedBox(width: 10),
            const Text(
              'Confirm Sale',
              style: TextStyle(color: ThemeConfig.gold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(playerName, style: ThemeConfig.subHeading),
            const SizedBox(height: 8),
            Text('Sold to: $teamName', style: ThemeConfig.body),
            Text(
              'Price: $formattedPrice',
              style: ThemeConfig.body.copyWith(color: ThemeConfig.neonCyan),
            ),
            const SizedBox(height: 8),
            Text(
              'Team budget after: ${BiddingUtils.formatPrice(auction.activeBidder!.pointsLeft - auction.currentBid)}',
              style: ThemeConfig.label,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM SOLD'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await auction.confirmSale();
      if (mounted) {
        if (success) {
          _showCelebration(
            playerName: playerName,
            teamName: teamName,
            captainName: captainName,
            formattedPrice: formattedPrice,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sale failed.'),
              backgroundColor: ThemeConfig.crimson,
            ),
          );
        }
      }
    }
  }

  void _showCelebration({
    required String playerName,
    required String teamName,
    required String captainName,
    required String formattedPrice,
  }) {
    // Start audio here (closer to user gesture) to avoid browser autoplay blocks.
    // Use UrlSource for reliable web path resolution.
    final audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.play(UrlSource('assets/sounds/celebration.mp3')).catchError((
      _,
    ) {
      // Sound is optional — don't fail if audio isn't available
      return null;
    });

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (_) => SoldCelebrationOverlay(
        playerName: playerName,
        teamName: teamName,
        captainName: captainName,
        formattedPrice: formattedPrice,
        audioPlayer: audioPlayer,
        onDismiss: () {
          audioPlayer.stop();
          audioPlayer.dispose();
          overlayEntry.remove();
        },
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }
}

/// Second-step confirmation dialog: user must type "RESTART" to proceed.
class _ResetConfirmDialog extends StatefulWidget {
  @override
  State<_ResetConfirmDialog> createState() => _ResetConfirmDialogState();
}

class _ResetConfirmDialogState extends State<_ResetConfirmDialog> {
  final _controller = TextEditingController();
  bool _matches = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final matches = _controller.text.trim().toUpperCase() == 'RESTART';
      if (matches != _matches) setState(() => _matches = matches);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Type RESTART to confirm',
        style: TextStyle(
          color: ThemeConfig.crimson,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This is the final confirmation. Type RESTART below to reset the entire auction.',
            style: ThemeConfig.body.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Type RESTART here',
              hintStyle: TextStyle(color: Colors.white24),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ThemeConfig.crimson.withAlpha(100),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: ThemeConfig.crimson,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: const TextStyle(
              color: ThemeConfig.crimson,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _matches ? () => Navigator.pop(context, true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _matches ? ThemeConfig.crimson : Colors.grey,
          ),
          child: const Text('RESET AUCTION'),
        ),
      ],
    );
  }
}
