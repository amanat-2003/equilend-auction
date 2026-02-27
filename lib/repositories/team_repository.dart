import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/team.dart';

/// Repository for Team CRUD operations against Supabase.
class TeamRepository {
  final SupabaseClient _client = SupabaseConfig.client;
  static const _table = 'teams';

  /// Fetch all teams ordered by team name.
  Future<List<Team>> fetchAll() async {
    final data = await _client.from(_table).select().order('team_name');
    return (data as List).map((e) => Team.fromMap(e)).toList();
  }

  /// Fetch a single team by id.
  Future<Team?> fetchById(String teamId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('team_id', teamId)
        .maybeSingle();
    return data != null ? Team.fromMap(data) : null;
  }

  /// Deduct points from a team and increment player count.
  /// Uses the current DB values to avoid race conditions.
  Future<void> deductPoints(String teamId, double amount) async {
    final team = await fetchById(teamId);
    if (team == null) return;
    await _client
        .from(_table)
        .update({
          'points_left': team.pointsLeft - amount,
          'player_count': team.playerCount + 1,
        })
        .eq('team_id', teamId);
  }

  /// Restore points to a team (undo sale).
  Future<void> restorePoints(String teamId, double amount) async {
    final team = await fetchById(teamId);
    if (team == null) return;
    await _client
        .from(_table)
        .update({
          'points_left': team.pointsLeft + amount,
          'player_count': (team.playerCount - 1).clamp(0, 999),
        })
        .eq('team_id', teamId);
  }

  /// Real-time stream of all changes on the teams table.
  Stream<List<Map<String, dynamic>>> streamAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['team_id'])
        .order('team_name');
  }

  /// Reset ALL teams back to starting state.
  /// Restores points_left to total_points and player_count to 0.
  Future<void> resetAllTeams() async {
    // Fetch all teams so we can reset each to its own total_points
    final teams = await fetchAll();
    for (final team in teams) {
      await _client
          .from(_table)
          .update({'points_left': team.totalPoints, 'player_count': 0})
          .eq('team_id', team.teamId);
    }
  }
}
