/// Data model for a Player in the auction.
class Player {
  final String id;
  final String name;
  final String? department;
  final bool badminton;
  final bool tt;
  final bool foosball;
  final int tier; // 1, 2, or 3
  final String? photoUrl;
  final double basePrice;
  double biddingPrice;
  String? soldToTeamId;
  bool isUnsold;

  Player({
    required this.id,
    required this.name,
    this.department,
    this.badminton = false,
    this.tt = false,
    this.foosball = false,
    this.tier = 3,
    this.photoUrl,
    this.basePrice = 1,
    this.biddingPrice = 0,
    this.soldToTeamId,
    this.isUnsold = false,
  });

  /// Sports the player participates in.
  List<String> get sports {
    final list = <String>[];
    if (badminton) list.add('Badminton');
    if (tt) list.add('Table Tennis');
    if (foosball) list.add('Foosball');
    return list;
  }

  /// Tier label for UI display.
  String get tierLabel => 'Tier $tier';

  /// Whether this player is still available for bidding.
  bool get isAvailable => soldToTeamId == null && !isUnsold;

  // ── Serialization ─────────────────────────────────────────
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      name: map['name'] as String,
      department: map['department'] as String?,
      badminton: map['badminton'] as bool? ?? false,
      tt: map['tt'] as bool? ?? false,
      foosball: map['foosball'] as bool? ?? false,
      tier: map['tier'] as int? ?? 3,
      photoUrl: map['photo_url'] as String?,
      basePrice: (map['base_price'] as num?)?.toDouble() ?? 1,
      biddingPrice: (map['bidding_price'] as num?)?.toDouble() ?? 0,
      soldToTeamId: map['sold_to_team_id'] as String?,
      isUnsold: map['is_unsold'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'badminton': badminton,
      'tt': tt,
      'foosball': foosball,
      'tier': tier,
      'photo_url': photoUrl,
      'base_price': basePrice,
      'bidding_price': biddingPrice,
      'sold_to_team_id': soldToTeamId,
      'is_unsold': isUnsold,
    };
  }

  /// Sentinel used to distinguish "not provided" from "explicitly null".
  static const _sentinel = Object();

  Player copyWith({
    String? id,
    String? name,
    String? department,
    bool? badminton,
    bool? tt,
    bool? foosball,
    int? tier,
    String? photoUrl,
    double? basePrice,
    double? biddingPrice,
    Object? soldToTeamId = _sentinel,
    bool? isUnsold,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      badminton: badminton ?? this.badminton,
      tt: tt ?? this.tt,
      foosball: foosball ?? this.foosball,
      tier: tier ?? this.tier,
      photoUrl: photoUrl ?? this.photoUrl,
      basePrice: basePrice ?? this.basePrice,
      biddingPrice: biddingPrice ?? this.biddingPrice,
      soldToTeamId: identical(soldToTeamId, _sentinel)
          ? this.soldToTeamId
          : soldToTeamId as String?,
      isUnsold: isUnsold ?? this.isUnsold,
    );
  }
}
