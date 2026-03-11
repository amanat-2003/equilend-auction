import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../repositories/player_repository.dart';
import '../repositories/team_repository.dart';
import '../utils/bidding_utils.dart';

/// Service that orchestrates the auction flow.
/// Acts as the single source of truth for auction state and
/// exposes a [ChangeNotifier] interface for Provider.
class AuctionService extends ChangeNotifier {
  final PlayerRepository _playerRepo = PlayerRepository();
  final TeamRepository _teamRepo = TeamRepository();

  // ── State ─────────────────────────────────────────────────
  List<Player> _allPlayers = [];
  List<Player> _availablePlayers = [];
  List<Team> _teams = [];

  Player? _currentPlayer;
  Team? _activeBidder;
  double _currentBid = 0;
  bool _isLoading = true;
  String? _errorMessage;

  /// Round to 1 decimal place to avoid floating-point drift (e.g. 0.8999…).
  static double _round1(double v) => (v * 10).round() / 10;

  StreamSubscription? _playerSub;
  StreamSubscription? _teamSub;

  // ── Getters ───────────────────────────────────────────────
  List<Player> get allPlayers => _allPlayers;
  List<Player> get availablePlayers => _availablePlayers;
  List<Team> get teams => _teams;
  Player? get currentPlayer => _currentPlayer;
  Team? get activeBidder => _activeBidder;
  double get currentBid => _currentBid;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  static const double maxBid = 100.0; // 100 Cr cap

  double get increment => BiddingUtils.getIncrement(_currentBid);
  double get decrement => BiddingUtils.getDecrement(_currentBid);
  String get formattedBid => BiddingUtils.formatPrice(_currentBid);
  bool get canIncrement => _currentBid + increment <= maxBid;

  // ── Initialization ────────────────────────────────────────
  Future<void> init() async {
    // Cancel any previous subscriptions to avoid duplicates
    await _playerSub?.cancel();
    await _teamSub?.cancel();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Initial data fetch
      _allPlayers = await _playerRepo.fetchAll();
      _availablePlayers = _allPlayers.where((p) => p.isAvailable).toList();
      _teams = await _teamRepo.fetchAll();
    } catch (e) {
      debugPrint('[AuctionService] Init fetch failed: $e');
      _errorMessage =
          'Could not connect to server. This may be a temporary issue — please check your connection and try again.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = false;
    notifyListeners();

    // Start real-time listeners (fire after initial data is shown)
    _playerSub = _playerRepo.streamAll().listen((rows) {
      _allPlayers = rows.map((e) => Player.fromMap(e)).toList();
      _rebuildAvailablePlayers();
      // Refresh current player if it exists
      if (_currentPlayer != null) {
        final updated = _allPlayers
            .where((p) => p.id == _currentPlayer!.id)
            .firstOrNull;
        if (updated != null) _currentPlayer = updated;
      }
      notifyListeners();
      debugPrint(
        '[AuctionService] Player stream: ${_allPlayers.length} total, ${_availablePlayers.length} available',
      );
    }, onError: (e) => debugPrint('[AuctionService] Player stream error: $e'));

    _teamSub = _teamRepo.streamAll().listen((rows) {
      _teams = rows.map((e) => Team.fromMap(e)).toList();
      // Refresh active bidder
      if (_activeBidder != null) {
        final updated = _teams
            .where((t) => t.teamId == _activeBidder!.teamId)
            .firstOrNull;
        if (updated != null) _activeBidder = updated;
      }
      notifyListeners();
      debugPrint('[AuctionService] Team stream: ${_teams.length} teams');
    }, onError: (e) => debugPrint('[AuctionService] Team stream error: $e'));
  }

  /// Rebuild the available players list from _allPlayers.
  void _rebuildAvailablePlayers() {
    _availablePlayers = _allPlayers.where((p) => p.isAvailable).toList();
  }

  /// Force refresh all data from Supabase (manual fallback).
  Future<void> refreshAll() async {
    try {
      _allPlayers = await _playerRepo.fetchAll();
      _rebuildAvailablePlayers();
      _teams = await _teamRepo.fetchAll();
      _errorMessage = null;
      notifyListeners();
      debugPrint('[AuctionService] Manual refresh complete');
    } catch (e) {
      debugPrint('[AuctionService] Refresh failed: $e');
      _errorMessage =
          'Refresh failed. The server may be temporarily unavailable — please try again shortly.';
      notifyListeners();
    }
  }

  // ── Player Selection ──────────────────────────────────────
  void selectPlayer(Player player) {
    _currentPlayer = player;
    _currentBid = _round1(player.basePrice);
    _activeBidder = null;
    notifyListeners();
  }

  void selectNextAvailable() {
    if (_availablePlayers.isNotEmpty) {
      selectPlayer(_availablePlayers.first);
    }
  }

  /// Randomly pick an available player from the given [tier].
  void selectRandomByTier(int tier) {
    final candidates = _availablePlayers
        .where((p) => p.tier == tier && p.id != _currentPlayer?.id)
        .toList();
    if (candidates.isEmpty) return;
    candidates.shuffle();
    selectPlayer(candidates.first);
  }

  // ── Team Selection ────────────────────────────────────────
  void setActiveBidder(Team team) {
    _activeBidder = team;
    notifyListeners();
  }

  void clearActiveBidder() {
    _activeBidder = null;
    notifyListeners();
  }

  // ── Bidding Controls ──────────────────────────────────────
  void incrementBid() {
    if (_currentPlayer == null) return;
    if (!canIncrement) return;
    _currentBid = _round1(_currentBid + increment);
    notifyListeners();
  }

  void decrementBid() {
    if (_currentPlayer == null) return;
    final dec = decrement;
    if (dec <= 0) return;
    final newBid = _round1(_currentBid - dec);
    if (newBid < 0.4) return;
    _currentBid = newBid;
    notifyListeners();
  }

  // ── Safety Check ──────────────────────────────────────────
  /// Returns null if the sale is safe, or an error message otherwise.
  String? validateSale() {
    if (_currentPlayer == null) return 'No player selected.';
    if (_activeBidder == null) return 'No team selected as active bidder.';
    if (!BiddingUtils.canAffordBid(_currentBid, _activeBidder!.pointsLeft)) {
      return '${_activeBidder!.teamName} cannot afford ${BiddingUtils.formatPrice(_currentBid)}. '
          'Budget left: ${BiddingUtils.formatPrice(_activeBidder!.pointsLeft)}.';
    }
    return null;
  }

  // ── Confirm Sale ──────────────────────────────────────────
  Future<bool> confirmSale() async {
    if (_currentPlayer == null || _activeBidder == null) return false;

    final soldPlayer = _currentPlayer!;
    final buyingTeam = _activeBidder!;
    final price = _currentBid;

    try {
      // 1. Write to Supabase
      await _playerRepo.markSold(soldPlayer.id, buyingTeam.teamId, price);
      await _teamRepo.deductPoints(buyingTeam.teamId, price);

      // 2. Optimistically update LOCAL state immediately
      //    (so UI updates instantly, without waiting for streams)
      _applyLocalSale(soldPlayer, buyingTeam, price);

      // Clear auction state
      _currentPlayer = null;
      _activeBidder = null;
      _currentBid = 0;
      notifyListeners();

      debugPrint(
        '[AuctionService] Sale confirmed: ${soldPlayer.name} → ${buyingTeam.teamName} for ${BiddingUtils.formatPrice(price)}',
      );
      return true;
    } catch (e) {
      debugPrint('[AuctionService] Sale failed: $e');
      return false;
    }
  }

  /// Apply sale changes to local in-memory lists immediately.
  void _applyLocalSale(Player soldPlayer, Team buyingTeam, double price) {
    // Update the player in _allPlayers
    final pIndex = _allPlayers.indexWhere((p) => p.id == soldPlayer.id);
    if (pIndex != -1) {
      _allPlayers[pIndex] = _allPlayers[pIndex].copyWith(
        soldToTeamId: buyingTeam.teamId,
        biddingPrice: price,
        isUnsold: false,
      );
    }
    _rebuildAvailablePlayers();

    // Update the team in _teams
    final tIndex = _teams.indexWhere((t) => t.teamId == buyingTeam.teamId);
    if (tIndex != -1) {
      _teams[tIndex] = _teams[tIndex].copyWith(
        pointsLeft: _teams[tIndex].pointsLeft - price,
        playerCount: _teams[tIndex].playerCount + 1,
      );
    }
  }

  // ── Mark Unsold ───────────────────────────────────────────
  Future<void> markUnsold() async {
    if (_currentPlayer == null) return;
    final player = _currentPlayer!;

    await _playerRepo.markUnsold(player.id);

    // Optimistic local update
    final pIndex = _allPlayers.indexWhere((p) => p.id == player.id);
    if (pIndex != -1) {
      _allPlayers[pIndex] = _allPlayers[pIndex].copyWith(
        isUnsold: true,
        soldToTeamId: null,
        biddingPrice: 0,
      );
    }
    _rebuildAvailablePlayers();

    _currentPlayer = null;
    _activeBidder = null;
    _currentBid = 0;
    notifyListeners();
  }

  // ── Cleanup ───────────────────────────────────────────────
  @override
  void dispose() {
    _playerSub?.cancel();
    _teamSub?.cancel();
    super.dispose();
  }

  // ── Reset Auction ─────────────────────────────────────────
  /// Resets ALL players and teams to starting state.
  /// Does NOT delete any rows.
  Future<void> resetAuction() async {
    try {
      debugPrint('[AuctionService] Starting auction reset...');

      // 1. Write to Supabase
      await _playerRepo.resetAllPlayers();
      debugPrint('[AuctionService] All players reset in DB');
      await _teamRepo.resetAllTeams();
      debugPrint('[AuctionService] All teams reset in DB');

      // 2. Re‑fetch fresh data from DB to guarantee consistency
      _allPlayers = await _playerRepo.fetchAll();
      _rebuildAvailablePlayers();
      _teams = await _teamRepo.fetchAll();

      // 3. Clear session state
      _currentPlayer = null;
      _activeBidder = null;
      _currentBid = 0;
      notifyListeners();

      debugPrint(
        '[AuctionService] Auction reset complete — '
        '${_availablePlayers.length} players available, '
        '${_teams.length} teams refreshed',
      );
    } catch (e, st) {
      debugPrint('[AuctionService] Auction reset FAILED: $e\n$st');
      rethrow;
    }
  }
}
