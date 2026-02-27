import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/player.dart';

/// Repository for Player CRUD operations against Supabase.
class PlayerRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  static const _table = 'players';

  /// Fetch all players ordered by name.
  Future<List<Player>> fetchAll() async {
    final data = await _client.from(_table).select().order('name');
    return (data as List).map((e) => Player.fromMap(e)).toList();
  }

  /// Fetch players that are still available (not sold and not unsold).
  Future<List<Player>> fetchAvailable() async {
    final data = await _client
        .from(_table)
        .select()
        .isFilter('sold_to_team_id', null)
        .eq('is_unsold', false)
        .order('tier')
        .order('name');
    return (data as List).map((e) => Player.fromMap(e)).toList();
  }

  /// Fetch a single player by id.
  Future<Player?> fetchById(String id) async {
    final data = await _client.from(_table).select().eq('id', id).maybeSingle();
    return data != null ? Player.fromMap(data) : null;
  }

  /// Update bidding price for a player.
  Future<void> updateBiddingPrice(String playerId, double price) async {
    await _client
        .from(_table)
        .update({'bidding_price': price})
        .eq('id', playerId);
  }

  /// Mark a player as sold to a team.
  Future<void> markSold(
    String playerId,
    String teamId,
    double finalPrice,
  ) async {
    await _client
        .from(_table)
        .update({
          'sold_to_team_id': teamId,
          'bidding_price': finalPrice,
          'is_unsold': false,
        })
        .eq('id', playerId);
  }

  /// Mark a player as unsold.
  Future<void> markUnsold(String playerId) async {
    await _client
        .from(_table)
        .update({
          'is_unsold': true,
          'sold_to_team_id': null,
          'bidding_price': 0,
        })
        .eq('id', playerId);
  }

  /// Reset a player for re-auction.
  Future<void> resetPlayer(String playerId) async {
    await _client
        .from(_table)
        .update({
          'is_unsold': false,
          'sold_to_team_id': null,
          'bidding_price': 0,
        })
        .eq('id', playerId);
  }

  /// Real-time stream of all changes on the players table.
  Stream<List<Map<String, dynamic>>> streamAll() {
    return _client.from(_table).stream(primaryKey: ['id']).order('name');
  }

  /// Reset ALL players back to auction-ready state.
  /// Does not delete rows — only clears sold/unsold fields.
  Future<void> resetAllPlayers() async {
    // Cannot use .neq('id','') because id is UUID (Postgres type mismatch).
    // Fetch all IDs first, then update each.
    final players = await fetchAll();
    for (final player in players) {
      await _client
          .from(_table)
          .update({
            'is_unsold': false,
            'sold_to_team_id': null,
            'bidding_price': 0,
          })
          .eq('id', player.id);
    }
  }
}
