# Equilend Auction League 🏏

A Flutter-based real-time auction platform for equilend sports leagues, featuring KGF-inspired dark UI with neon accents, Supabase backend, and live bidding mechanics.

## 🎯 Features

- **Real-time Bidding** — Live auction updates via Supabase realtime
- **KGF-Themed UI** — Dark backgrounds with neon gold/cyan/crimson accents
- **Team Management** — Manage teams, budgets, and player rosters
- **Player Cards** — Tier-based pricing with sport specializations
- **Celebration Effects** — Confetti and sound effects on player sales
- **Authentication** — Role-based access (Admin/Viewer) with Supabase Auth

## 🚀 Live Demo

**[View Live App →](https://amanat-2003.github.io/equilend-auction/)**

## 🛠️ Tech Stack

- **Frontend:** Flutter Web
- **Backend:** Supabase (PostgreSQL + Realtime)
- **State Management:** Provider
- **UI Theme:** KGF-inspired dark mode with glassmorphism
- **Deployment:** GitHub Pages

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/amanat-2003/equilend-auction.git
cd equilend-auction

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on mobile
flutter run
```

## 🔧 Configuration

Update Supabase credentials in `lib/config/supabase_config.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## 🗄️ Database Setup

Run the SQL schema files in your Supabase SQL Editor:

1. `supabase_schema.sql` — Creates tables and seed data
2. `supabase_auth_schema.sql` — Sets up authentication
3. `supabase_secure_rls.sql` — Enables Row Level Security (optional)

## 🚢 Deployment

Deploy to GitHub Pages with one command:

```bash
./deploy.sh
```

Or manually:

```bash
flutter build web --release --base-href /equilend-auction/
cd build/web && git init && git add -A && git commit -m "Deploy"
git push -f https://github.com/amanat-2003/equilend-auction.git main:gh-pages
cd ../.. && rm -rf build/web/.git
```

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── config/                      # Configuration files
│   ├── supabase_config.dart     # Supabase setup
│   └── theme_config.dart        # KGF theme constants
├── models/                      # Data models
├── repositories/                # Data access layer
├── services/                    # Business logic
├── screens/                     # Full-page views
├── widgets/                     # Reusable components
└── utils/                       # Helper functions
```

## 🎨 Design Guidelines

See [AGENTS.md](AGENTS.md) for detailed coding conventions and KGF styling rules.

## 📝 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

**Amanat Singh** — [GitHub](https://github.com/amanat-2003)
