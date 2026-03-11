import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../models/team.dart';

/// Grid of team logos for selecting the active bidder.
class TeamSelectionGrid extends StatelessWidget {
  final List<Team> teams;
  final String? activeBidderId;
  final ValueChanged<Team> onTeamSelected;

  const TeamSelectionGrid({
    super.key,
    required this.teams,
    this.activeBidderId,
    required this.onTeamSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.white30, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.group, color: ThemeConfig.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'SELECT ACTIVE BIDDER',
                style: ThemeConfig.label.copyWith(
                  color: ThemeConfig.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: teams.map((t) => _teamChip(t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _teamChip(Team team) {
    final isActive = team.teamId == activeBidderId;
    final isExhausted = team.pointsLeft <= 0;
    return Opacity(
      opacity: isExhausted ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: isExhausted ? null : () => onTeamSelected(team),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isExhausted
                ? ThemeConfig.crimson.withAlpha(20)
                : isActive
                ? ThemeConfig.gold.withAlpha(30)
                : ThemeConfig.cardColor,
            border: Border.all(
              color: isExhausted
                  ? ThemeConfig.crimson.withAlpha(80)
                  : isActive
                  ? ThemeConfig.gold
                  : ThemeConfig.white30,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: ThemeConfig.gold.withAlpha(30),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeConfig.surfaceColor,
                  border: Border.all(
                    color: isExhausted
                        ? ThemeConfig.crimson.withAlpha(80)
                        : isActive
                        ? ThemeConfig.gold
                        : ThemeConfig.white30,
                  ),
                  image: team.logoUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(team.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: team.logoUrl == null
                    ? Center(
                        child: Text(
                          team.teamName.isNotEmpty ? team.teamName[0] : '?',
                          style: TextStyle(
                            color: isActive
                                ? ThemeConfig.gold
                                : ThemeConfig.white70,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    team.teamName,
                    style: ThemeConfig.body.copyWith(
                      color: isExhausted
                          ? ThemeConfig.white50
                          : isActive
                          ? ThemeConfig.gold
                          : ThemeConfig.white,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (isExhausted)
                    Text(
                      'BUDGET EXHAUSTED',
                      style: ThemeConfig.label.copyWith(
                        color: ThemeConfig.crimson,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle,
                  color: ThemeConfig.gold,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
