-- ============================================================
-- SECURE Row-Level Security Policies
-- Run this in Supabase SQL Editor to replace open policies
-- ============================================================

-- Drop existing insecure policies
DROP POLICY IF EXISTS "Allow full access to teams" ON teams;
DROP POLICY IF EXISTS "Allow full access to players" ON players;

-- ============================================================
-- OPTION 1: Authentication-Based (Recommended)
-- Only logged-in users can read. Only admins can write.
-- ============================================================

-- Teams: Everyone can read, only admins can modify
CREATE POLICY "Allow read access to teams" ON teams
  FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Allow admin write access to teams" ON teams
  FOR ALL
  USING (
    auth.role() = 'authenticated' 
    AND (auth.jwt() ->> 'user_role')::text = 'admin'
  );

-- Players: Everyone can read, only admins can modify
CREATE POLICY "Allow read access to players" ON players
  FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Allow admin write access to players" ON players
  FOR ALL
  USING (
    auth.role() = 'authenticated' 
    AND (auth.jwt() ->> 'user_role')::text = 'admin'
  );

-- ============================================================
-- OPTION 2: IP Allowlist (If you want public read access)
-- Anyone can read, but only specific users can write
-- ============================================================

-- Uncomment if you want public read access:
/*
CREATE POLICY "Public read teams" ON teams
  FOR SELECT USING (true);

CREATE POLICY "Public read players" ON players
  FOR SELECT USING (true);

CREATE POLICY "Admin only write teams" ON teams
  FOR ALL
  USING (
    auth.role() = 'authenticated' 
    AND (auth.jwt() ->> 'user_role')::text = 'admin'
  );

CREATE POLICY "Admin only write players" ON players
  FOR ALL
  USING (
    auth.role() = 'authenticated' 
    AND (auth.jwt() ->> 'user_role')::text = 'admin'
  );
*/

-- ============================================================
-- OPTION 3: Demo/Testing Mode (Use carefully!)
-- Public read, but write requires authentication
-- ============================================================

-- Uncomment for demo mode:
/*
CREATE POLICY "Public read teams" ON teams
  FOR SELECT USING (true);

CREATE POLICY "Auth write teams" ON teams
  FOR INSERT, UPDATE, DELETE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Public read players" ON players
  FOR SELECT USING (true);

CREATE POLICY "Auth write players" ON players
  FOR INSERT, UPDATE, DELETE
  USING (auth.role() = 'authenticated');
*/
