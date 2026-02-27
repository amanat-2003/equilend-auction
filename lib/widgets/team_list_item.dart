import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../utils/bidding_utils.dart';

/// A single team row in the vertical sidebar with expandable details.
class TeamListItem extends StatefulWidget {
  final Team team;
  final bool isActiveBidder;
  final List<Player> boughtPlayers;
  final VoidCallback onTap;

  const TeamListItem({
    super.key,
    required this.team,
    this.isActiveBidder = false,
    this.boughtPlayers = const [],
    required this.onTap,
  });

  @override
  State<TeamListItem> createState() => _TeamListItemState();
}

class _TeamListItemState extends State<TeamListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: widget.isActiveBidder
            ? const LinearGradient(
                colors: [Color(0x40FFD700), Color(0x20DC143C)],
              )
            : null,
        color: widget.isActiveBidder ? null : ThemeConfig.surfaceColor,
        border: Border.all(
          color: widget.isActiveBidder ? ThemeConfig.gold : ThemeConfig.white30,
          width: widget.isActiveBidder ? 2 : 0.8,
        ),
        boxShadow: widget.isActiveBidder
            ? [
                BoxShadow(
                  color: ThemeConfig.gold.withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Main row (tappable for bidder selection) ───────
          GestureDetector(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // ── Logo ──────────────────────────────────
                  _buildLogo(),
                  const SizedBox(width: 10),

                  // ── Info ──────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.team.teamName,
                          style: ThemeConfig.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.isActiveBidder
                                ? ThemeConfig.gold
                                : ThemeConfig.white,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // Captain photo
                            _buildCaptainAvatar(),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.team.captainName,
                                style: ThemeConfig.label.copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Budget & Count ────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        BiddingUtils.formatPrice(widget.team.pointsLeft),
                        style: ThemeConfig.body.copyWith(
                          color: _budgetColor(widget.team),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people,
                            size: 13,
                            color: ThemeConfig.white50,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.team.playerCount}',
                            style: ThemeConfig.label.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  // ── Expand toggle ─────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.expand_more,
                        color: ThemeConfig.white50,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail section ─────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedDetails(),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ── Team Logo ───────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeConfig.cardColor,
        border: Border.all(
          color: widget.isActiveBidder ? ThemeConfig.gold : ThemeConfig.white30,
          width: 1.5,
        ),
        image: widget.team.logoUrl != null
            ? DecorationImage(
                image: NetworkImage(widget.team.logoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.team.logoUrl == null
          ? Center(
              child: Text(
                widget.team.teamName.isNotEmpty ? widget.team.teamName[0] : '?',
                style: TextStyle(
                  color: widget.isActiveBidder
                      ? ThemeConfig.gold
                      : ThemeConfig.white70,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            )
          : null,
    );
  }

  // ── Captain mini avatar ─────────────────────────────────────
  Widget _buildCaptainAvatar() {
    final hasCaptainPhoto = widget.team.captainPhoto != null;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeConfig.cardColor,
        border: Border.all(color: ThemeConfig.white30, width: 0.8),
        image: hasCaptainPhoto
            ? DecorationImage(
                image: NetworkImage(widget.team.captainPhoto!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasCaptainPhoto
          ? Center(
              child: Text(
                widget.team.captainName.isNotEmpty
                    ? widget.team.captainName[0]
                    : '?',
                style: const TextStyle(
                  color: ThemeConfig.white50,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }

  // ── Expanded Details ────────────────────────────────────────
  Widget _buildExpandedDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: ThemeConfig.white30, height: 1),
          const SizedBox(height: 8),
          // Captain info row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeConfig.cardColor,
                  border: Border.all(color: ThemeConfig.gold.withAlpha(80)),
                  image: widget.team.captainPhoto != null
                      ? DecorationImage(
                          image: NetworkImage(widget.team.captainPhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.team.captainPhoto == null
                    ? Center(
                        child: Text(
                          widget.team.captainName.isNotEmpty
                              ? widget.team.captainName[0]
                              : '?',
                          style: const TextStyle(
                            color: ThemeConfig.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Captain: ${widget.team.captainName}',
                style: ThemeConfig.label.copyWith(
                  color: ThemeConfig.goldLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Budget bar
          Row(
            children: [
              Text('Spent: ', style: ThemeConfig.label.copyWith(fontSize: 10)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.team.budgetUsage.clamp(0.0, 1.0),
                    backgroundColor: ThemeConfig.white30.withAlpha(30),
                    color: _budgetColor(widget.team),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${BiddingUtils.formatPrice(widget.team.pointsSpent)} / ${BiddingUtils.formatPrice(widget.team.totalPoints)}',
                style: ThemeConfig.label.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bought players
          Text(
            'SQUAD (${widget.boughtPlayers.length})',
            style: ThemeConfig.label.copyWith(
              color: ThemeConfig.white50,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          if (widget.boughtPlayers.isEmpty)
            Text(
              'No players bought yet.',
              style: ThemeConfig.label.copyWith(
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...widget.boughtPlayers.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    // Player avatar
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeConfig.surfaceColor,
                        image: p.photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(p.photoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: p.photoUrl == null
                          ? Center(
                              child: Text(
                                p.name.isNotEmpty ? p.name[0] : '?',
                                style: const TextStyle(
                                  color: ThemeConfig.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        p.name,
                        style: ThemeConfig.label.copyWith(
                          fontSize: 11,
                          color: ThemeConfig.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      BiddingUtils.formatPrice(p.biddingPrice),
                      style: ThemeConfig.label.copyWith(
                        fontSize: 10,
                        color: ThemeConfig.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _budgetColor(Team t) {
    final pct = t.budgetUsage;
    if (pct > 0.85) return ThemeConfig.crimson;
    if (pct > 0.6) return ThemeConfig.goldLight;
    return ThemeConfig.neonGreen;
  }
}
