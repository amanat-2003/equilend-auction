-- ============================================================
-- Equilend Auction League — Supabase SQL Schema
-- ============================================================

-- 1. Teams table
CREATE TABLE IF NOT EXISTS teams (
  team_id     UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  team_name   TEXT NOT NULL UNIQUE,
  captain_name TEXT NOT NULL,
  captain_photo TEXT,
  logo_url    TEXT,
  total_points DOUBLE PRECISION NOT NULL DEFAULT 125,   -- 125 Cr
  points_left  DOUBLE PRECISION NOT NULL DEFAULT 125,   -- 125 Cr
  player_count INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- 2. Players table
CREATE TABLE IF NOT EXISTS players (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name            TEXT NOT NULL,
  department      TEXT,
  badminton       BOOLEAN NOT NULL DEFAULT FALSE,
  tt              BOOLEAN NOT NULL DEFAULT FALSE,
  foosball        BOOLEAN NOT NULL DEFAULT FALSE,
  tier            INT NOT NULL DEFAULT 3 CHECK (tier IN (1, 2, 3)),
  photo_url       TEXT,
  base_price      DOUBLE PRECISION NOT NULL DEFAULT 1,   -- in Cr (1 = 1 Cr, 0.4 = 40L)
  bidding_price   DOUBLE PRECISION NOT NULL DEFAULT 0,
  sold_to_team_id UUID REFERENCES teams(team_id) ON DELETE SET NULL,
  is_unsold       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- 3. Enable Realtime on both tables
ALTER PUBLICATION supabase_realtime ADD TABLE players;
ALTER PUBLICATION supabase_realtime ADD TABLE teams;

-- 4. Row-Level Security (open for demo — lock down in production)
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow full access to teams" ON teams
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow full access to players" ON players
  FOR ALL USING (true) WITH CHECK (true);

-- 5. Indexes
CREATE INDEX idx_players_team ON players (sold_to_team_id);
CREATE INDEX idx_players_unsold ON players (is_unsold);

-- ============================================================
-- Seed: Example Teams (adjust as needed)
-- ============================================================
INSERT INTO teams (team_name, captain_name, logo_url, total_points, points_left)
VALUES
  ('Royal Strikers',  'Amit Kumar',   NULL, 125, 125),
  ('Thunder Hawks',   'Priya Sharma', NULL, 125, 125),
  ('Blaze Warriors',  'Rahul Verma',  NULL, 125, 125),
  ('Storm Chasers',   'Neha Gupta',   NULL, 125, 125);

-- ============================================================
-- Seed: 10 Example Players
-- base_price: 0.40 = 40L | 0.50 = 50L | 1.0 = 1Cr | 2.0 = 2Cr
-- tier: 1 = star, 2 = mid, 3 = base
-- ============================================================
INSERT INTO players (name, department, badminton, tt, foosball, tier, base_price)
VALUES
  -- Tier 1 — Star players (high base price)
  ('Arjun Mehta',    'Technology',       TRUE,  TRUE,  FALSE, 1, 2.0),
  ('Priya Nair',     'Sales',            TRUE,  FALSE, TRUE,  1, 2.0),

  -- Tier 2 — Mid-range players
  ('Rohan Das',      'Finance',          FALSE, TRUE,  TRUE,  2, 1.0),
  ('Sneha Kapoor',   'Operations',       TRUE,  FALSE, FALSE, 2, 1.0),
  ('Vikram Singh',   'Risk',             FALSE, FALSE, TRUE,  2, 1.0),
  ('Anjali Verma',   'Compliance',       TRUE,  TRUE,  FALSE, 2, 0.75),

  -- Tier 3 — Base players (low base price)
  ('Karan Malhotra', 'Technology',       FALSE, TRUE,  FALSE, 3, 0.50),
  ('Divya Reddy',    'HR',               TRUE,  FALSE, TRUE,  3, 0.50),
  ('Suresh Pillai',  'Sales',            FALSE, TRUE,  TRUE,  3, 0.40),
  ('Meera Joshi',    'Finance',          TRUE,  TRUE,  TRUE,  3, 0.40);
