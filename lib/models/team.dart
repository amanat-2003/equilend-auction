/// Data model for a Team in the auction.
class Team {
  final String teamId;
  final String teamName;
  final String captainName;
  final String? captainPhoto;
  final String? logoUrl;
  final double totalPoints; // default 125 Cr
  double pointsLeft;
  int playerCount;

  Team({
    required this.teamId,
    required this.teamName,
    required this.captainName,
    this.captainPhoto,
    this.logoUrl,
    this.totalPoints = 125,
    this.pointsLeft = 125,
    this.playerCount = 0,
  });

  /// Budget spent so far.
  double get pointsSpent => totalPoints - pointsLeft;

  /// Budget usage percentage (0-1).
  double get budgetUsage => totalPoints > 0 ? pointsSpent / totalPoints : 0;

  // ── Serialization ─────────────────────────────────────────
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      teamId: map['team_id'] as String,
      teamName: map['team_name'] as String,
      captainName: map['captain_name'] as String,
      captainPhoto: map['captain_photo'] as String?,
      logoUrl: map['logo_url'] as String?,
      totalPoints: (map['total_points'] as num?)?.toDouble() ?? 125,
      pointsLeft: (map['points_left'] as num?)?.toDouble() ?? 125,
      playerCount: map['player_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'team_name': teamName,
      'captain_name': captainName,
      'captain_photo': captainPhoto,
      'logo_url': logoUrl,
      'total_points': totalPoints,
      'points_left': pointsLeft,
      'player_count': playerCount,
    };
  }

  Team copyWith({
    String? teamId,
    String? teamName,
    String? captainName,
    String? captainPhoto,
    String? logoUrl,
    double? totalPoints,
    double? pointsLeft,
    int? playerCount,
  }) {
    return Team(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      captainName: captainName ?? this.captainName,
      captainPhoto: captainPhoto ?? this.captainPhoto,
      logoUrl: logoUrl ?? this.logoUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      pointsLeft: pointsLeft ?? this.pointsLeft,
      playerCount: playerCount ?? this.playerCount,
    );
  }
}
