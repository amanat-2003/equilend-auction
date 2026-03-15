# Equilend Auction League — Agent Instructions

A Flutter-based real-time auction platform for equilend sports leagues, featuring KGF-inspired dark UI with neon accents, Supabase backend, and live bidding mechanics.

---

## Core Principles (CRITICAL - Follow for ALL Code)

### 1. Modular Architecture
- **Strictly organize code** into dedicated folders: `config/`, `models/`, `repositories/`, `screens/`, `services/`, `widgets/`, `utils/`
- **One responsibility per folder** — never mix concerns (e.g., no UI logic in repositories)
- **Keep files focused** — complex widgets/classes should be in separate files

### 2. Code Quality
- **Write concise, readable code** with clear variable/function names
- **Add comments strategically** — explain "why" not "what"
- **Divide complex logic** into multiple smaller files for better understanding
- **Use descriptive naming** — avoid abbreviations

### 3. KGF-Inspired UI (Non-Negotiable)
- **Always use dark backgrounds** (`#0A0A0F`, `#141420`, `#1A1A2E`)
- **Apply neon accents** — gold (`#FFD700`), cyan (`#00F0FF`), crimson (`#DC143C`), green (`#39FF14`)
- **Add glow effects** to interactive elements (box shadows, borders)
- **Use ThemeConfig constants** — never hardcode colors in widgets
- **Maintain glassmorphism** aesthetic with `ThemeConfig.glassCard()`

---

## Build & Development

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on mobile
flutter run

# Build for web
flutter build web

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## Architecture & Structure

### Modular Organization

```
lib/
├── main.dart                # Entry point, Provider setup
├── config/                  # Configuration files
│   ├── supabase_config.dart # Supabase initialization
│   └── theme_config.dart    # KGF-themed styling
├── models/                  # Data models
│   ├── player.dart          # Player entity
│   └── team.dart            # Team entity
├── repositories/            # Data layer (Supabase CRUD)
│   ├── player_repository.dart
│   └── team_repository.dart
├── services/                # Business logic layer
│   └── auction_service.dart # Main auction state & logic
├── screens/                 # Full-page UI screens
│   └── auction_screen.dart  # Main auction view
├── widgets/                 # Reusable UI components
│   ├── bidding_controls.dart
│   ├── player_card.dart
│   ├── player_picker_dialog.dart
│   ├── sold_celebration_overlay.dart
│   ├── team_list_item.dart
│   └── team_selection_grid.dart
└── utils/                   # Helper functions
    └── bidding_utils.dart   # Bid increment logic
```

### State Management

- **Provider** for global state (AuctionService)
- **ChangeNotifier** pattern for reactive UI updates
- **Consumer** widgets for selective rebuilds

### Data Flow

```
UI → Service → Repository → Supabase
                 ↓
             notifyListeners()
                 ↓
        Consumer rebuilds UI
```

---

## Theme & Styling (KGF-Inspired)

### Color Palette

All themes defined in `lib/config/theme_config.dart`:

| Variable         | Hex       | Usage                              |
|------------------|-----------|-------------------------------------|
| `scaffoldBg`     | `#0A0A0F` | Main background (near-black)        |
| `surfaceColor`   | `#141420` | Mid-layer surfaces                  |
| `cardColor`      | `#1A1A2E` | Card backgrounds                    |
| `gold`           | `#FFD700` | Primary accent (headings, borders)  |
| `crimson`        | `#DC143C` | Secondary accent (sold/unsold)      |
| `neonCyan`       | `#00F0FF` | Bid prices, highlights              |
| `neonGreen`      | `#39FF14` | Success states, sold indicators     |
| `white70`        | 70% white | Body text                           |
| `white30`        | 30% white | Subtle borders                      |

### Design Patterns

- **Glassmorphism**: Use `ThemeConfig.glassCard()` for card decorations
- **Glow effects**: Box shadows with `color.withAlpha(25)` for subtle neon glow
- **Typography**: Poppins font family (install via `google_fonts` package)
- **Spacing**: Use 8, 16, 24, 32 px multiples for consistent rhythm
- **Border radius**: 12-20px for smooth, modern feel

### Components to Maintain KGF Style

1. **Dark backgrounds** with subtle gradients
2. **Gold/neon borders** on interactive elements
3. **Glowing shadows** on hover/active states
4. **Bold typography** with high letter-spacing for headings
5. **Smooth animations** (200-300ms duration, Curves.easeOut)

---

## Database Schema (Supabase)

### Tables

#### `teams`
- `team_id` (UUID, PK)
- `team_name` (TEXT, unique)
- `captain_name` (TEXT)
- `captain_photo`, `logo_url` (TEXT, nullable)
- `total_points`, `points_left` (DOUBLE) — budget in Cr (125 default)
- `player_count` (INT)

#### `players`
- `id` (UUID, PK)
- `name`, `department` (TEXT)
- `badminton`, `tt`, `foosball` (BOOLEAN) — sports flags
- `tier` (INT, 1-3)
- `photo_url` (TEXT, nullable)
- `base_price`, `bidding_price` (DOUBLE) — in Cr
- `sold_to_team_id` (UUID, FK to teams)
- `is_unsold` (BOOLEAN)

### Realtime Updates

Both tables have realtime enabled via:
```sql
ALTER PUBLICATION supabase_realtime ADD TABLE players;
ALTER PUBLICATION supabase_realtime ADD TABLE teams;
```

Listen to changes in `AuctionService` using `supabase.channel().on()`.

---

## Coding Conventions

### General Principles

1. **One widget per file** for complex widgets (>50 lines)
2. **Descriptive variable names** — avoid abbreviations
3. **Concise comments** — explain "why", not "what"
4. **Null safety** — use late, ?, !, required appropriately
5. **Const constructors** — use `const` wherever possible for performance

### File Naming

- `snake_case.dart` for all Dart files
- Match class name to file name (e.g., `AuctionService` → `auction_service.dart`)

### Code Style

```dart
// ✅ Good: Named parameters for >2 args, const constructor
const Player({
  required this.id,
  required this.name,
  this.department,
});

// ✅ Good: Clear separation of concerns
class PlayerRepository {
  Future<List<Player>> fetchAll() async { ... }
}

class AuctionService extends ChangeNotifier {
  Future<void> loadPlayers() async {
    _players = await _playerRepo.fetchAll();
    notifyListeners();
  }
}

// ❌ Avoid: Mixing UI and business logic
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Don't do Supabase calls here!
    supabase.from('players').select(); // Wrong!
  }
}
```

### Comments

```dart
/// Three-slash doc comments for public APIs.
class Player {
  /// Sports the player participates in (Badminton, TT, Foosball).
  List<String> get sports { ... }
}

// Single-line for implementation notes.
// This prevents negative balance after sale.
if (team.pointsLeft - price < 0) return;
```

---

## Common Tasks

### Adding a New Model

1. Create `lib/models/new_model.dart`
2. Add `fromMap()`, `toMap()`, `copyWith()` methods
3. Create corresponding `lib/repositories/new_model_repository.dart`
4. Update `AuctionService` to load/manage the model

### Adding a New Screen

1. Create `lib/screens/new_screen.dart`
2. Use `Scaffold` with `ThemeConfig.scaffoldBg`
3. Wrap dynamic UI in `Consumer<AuctionService>`
4. Add route in `MaterialApp` routes if needed

### Adding a New Widget

1. Create `lib/widgets/new_widget.dart`
2. Use `ThemeConfig` constants for colors/text styles
3. Prefer `StatelessWidget` unless local state is needed
4. Extract magic numbers to named constants

### Styling a Component

```dart
Container(
  decoration: ThemeConfig.glassCard(
    borderColor: ThemeConfig.gold.withAlpha(80),
  ),
  padding: const EdgeInsets.all(24),
  child: Text(
    'Your Text',
    style: ThemeConfig.heading.copyWith(color: ThemeConfig.neonCyan),
  ),
)
```

---

## Dependencies

| Package                | Purpose                            |
|------------------------|------------------------------------|
| `supabase_flutter`     | Realtime database & auth           |
| `provider`             | State management                   |
| `google_fonts`         | Poppins font family                |
| `confetti`             | Celebration effects on player sold |
| `audioplayers`         | Sound effects (hammer, applause)   |
| `cached_network_image` | Efficient image loading            |

---

## Gotchas & Troubleshooting

### Supabase Connection Issues

- Ensure `.env` or `SupabaseConfig` has correct URL & anon key
- Check RLS policies if data doesn't load (should be open for demo)

### Theme Not Applying

- Verify `ThemeConfig.darkTheme` is set in `MaterialApp(theme: ...)`
- Check if a widget overrides with `Theme.of(context).copyWith()`

### Realtime Not Working

- Confirm `ALTER PUBLICATION` was run in Supabase SQL Editor
- Check `.on()` subscriptions in `AuctionService.init()`

### Bidding Logic Edge Cases

- Negative budget: Block bids if `team.pointsLeft < bidAmount`
- Highest bidder edge case: Gray out "Bid" button for current highest bidder
- Unsold players: Mark `is_unsold = true` if all teams pass

---

## Testing

- **Unit tests**: Place in `test/` directory, mirror `lib/` structure
- **Widget tests**: Test UI components in isolation
- **Integration tests**: Use `integration_test/` for full flows

```bash
flutter test                    # Run all tests
flutter test test/utils/        # Test specific folder
```

---

## Deployment

### Web

```bash
flutter build web --release
# Deploy build/web/ to Netlify, Vercel, or Firebase Hosting
```

### Mobile (Android/iOS)

```bash
flutter build apk --release     # Android
flutter build ios --release     # iOS (requires macOS)
```

---

## Future Enhancements

- **Undo last sale**: Add rollback functionality
- **Timer per player**: Countdown for each bidding session
- **Bid history**: Show previous bids in a timeline
- **Analytics dashboard**: Team-wise spend breakdown
- **Dark/Light toggle**: Optional light mode (if needed)

---

## AI Agent Checklist (Before Completing Any Task)

When writing code for this project, **ALWAYS** verify:

### ✅ Modular Organization
- [ ] Code placed in correct folder (`config/`, `models/`, `repositories/`, `screens/`, `services/`, `widgets/`, `utils/`)
- [ ] Complex components split into separate files (>50 lines = new file)
- [ ] No mixed concerns (UI separated from business logic)

### ✅ Code Quality
- [ ] Concise, readable code with descriptive names
- [ ] Strategic comments explaining "why", not "what"
- [ ] Proper null safety (`required`, `?`, `!`, `late`)
- [ ] Used `const` constructors where possible

### ✅ KGF Styling (CRITICAL)
- [ ] **ONLY** used `ThemeConfig` constants (no hardcoded colors)
- [ ] Applied dark backgrounds and neon accents
- [ ] Added glow effects with `boxShadow` on interactive elements
- [ ] Used `ThemeConfig.glassCard()` for card decorations
- [ ] Maintained 12-20px border radius for consistency

### ✅ Final Steps
- [ ] Run `flutter analyze` — fix all issues
- [ ] Test on web/mobile if UI changes made
- [ ] Verify realtime updates work if DB changes made

---

## Questions?

For AI agents assisting with this codebase:

- **Always** use `ThemeConfig` constants for colors/styles
- **Never** hardcode hex values in widgets
- **Prefer** creating new widgets over inline complexity
- **Divide** complex logic into multiple focused files
- **Maintain** strict folder separation (models, services, widgets, etc.)
- **Run** `flutter analyze` before marking changes complete
- **Follow** the existing folder structure religiously
