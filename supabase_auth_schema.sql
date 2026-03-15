-- ═══════════════════════════════════════════════════════════
--  USER ROLES TABLE — Role-based access control
-- ═══════════════════════════════════════════════════════════
-- Roles: 'admin' (full CRUD) | 'viewer' (read-only)
-- To promote a user: UPDATE user_roles SET role = 'admin' WHERE user_id = '<uuid>';

-- 1. Create enum type for roles
CREATE TYPE app_role AS ENUM ('admin', 'viewer');

-- 2. Create user_roles table
CREATE TABLE IF NOT EXISTS user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role app_role NOT NULL DEFAULT 'viewer',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- 3. Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Users can read their own role
CREATE POLICY "Users can read own role"
  ON user_roles FOR SELECT
  USING (auth.uid() = user_id);

-- Only service_role can insert/update roles (via Supabase dashboard or edge functions)
-- No INSERT/UPDATE policy for authenticated users — admins manage via dashboard.

-- 4. Auto-assign 'viewer' role on new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'viewer');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 5. Enable realtime for user_roles
ALTER PUBLICATION supabase_realtime ADD TABLE user_roles;

-- 6. RLS policies for players/teams based on role
-- READ: Any authenticated user can read
CREATE POLICY "Authenticated users can read players"
  ON players FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can read teams"
  ON teams FOR SELECT
  USING (auth.role() = 'authenticated');

-- WRITE: Only admin users can modify
CREATE POLICY "Admins can insert players"
  ON players FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can update players"
  ON players FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can delete players"
  ON players FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can insert teams"
  ON teams FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can update teams"
  ON teams FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can delete teams"
  ON teams FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  );
