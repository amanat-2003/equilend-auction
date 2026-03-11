import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../models/player.dart';
import '../utils/bidding_utils.dart';

/// Dropdown / list to pick the next player for auction, with search.
class PlayerPickerDialog extends StatefulWidget {
  final List<Player> availablePlayers;
  final ValueChanged<Player> onPlayerSelected;

  const PlayerPickerDialog({
    super.key,
    required this.availablePlayers,
    required this.onPlayerSelected,
  });

  @override
  State<PlayerPickerDialog> createState() => _PlayerPickerDialogState();
}

class _PlayerPickerDialogState extends State<PlayerPickerDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Player> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.availablePlayers;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.availablePlayers;
      } else {
        _filtered = widget.availablePlayers.where((p) {
          return p.name.toLowerCase().contains(q) ||
              (p.department?.toLowerCase().contains(q) ?? false) ||
              p.tierLabel.toLowerCase().contains(q) ||
              p.sports.any((s) => s.toLowerCase().contains(q));
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeConfig.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x33FFD700)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ThemeConfig.white30, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_add,
                    color: ThemeConfig.gold,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SELECT NEXT PLAYER',
                    style: ThemeConfig.subHeading.copyWith(
                      color: ThemeConfig.gold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: ThemeConfig.white50,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                style: ThemeConfig.body.copyWith(color: ThemeConfig.white),
                decoration: InputDecoration(
                  hintText: 'Search by name, department, sport...',
                  hintStyle: ThemeConfig.label,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: ThemeConfig.white50,
                    size: 20,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: ThemeConfig.white50,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchCtrl.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: ThemeConfig.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ThemeConfig.white30,
                      width: 0.8,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ThemeConfig.white30,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ThemeConfig.gold,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            // Result count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} player${_filtered.length == 1 ? '' : 's'} found',
                  style: ThemeConfig.label.copyWith(fontSize: 11),
                ),
              ),
            ),
            // List
            Flexible(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'No matching players.',
                          style: ThemeConfig.body,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final p = _filtered[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: p.photoUrl != null
                                ? CachedNetworkImageProvider(p.photoUrl!)
                                : null,
                            backgroundColor: ThemeConfig.surfaceColor,
                            child: p.photoUrl == null
                                ? Text(
                                    p.name.isNotEmpty ? p.name[0] : '?',
                                    style: const TextStyle(
                                      color: ThemeConfig.gold,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            p.name,
                            style: ThemeConfig.body.copyWith(
                              color: ThemeConfig.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${p.tierLabel}  •  Base: ${BiddingUtils.formatPrice(p.basePrice)}',
                            style: ThemeConfig.label,
                          ),
                          trailing: Text(
                            p.sports.join(', '),
                            style: ThemeConfig.label.copyWith(
                              color: ThemeConfig.neonCyan,
                            ),
                          ),
                          onTap: () {
                            onPlayerSelected(p);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void onPlayerSelected(Player p) => widget.onPlayerSelected(p);
}
