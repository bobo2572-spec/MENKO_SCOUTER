-- Migration v3: Google OAuth + user ownership
-- Run in Supabase SQL Editor AFTER schema_v2.sql
--
-- ================================================================
-- STEP 1: Update menko_records table
-- ================================================================

ALTER TABLE menko_records
  ADD COLUMN IF NOT EXISTS user_id TEXT;

CREATE INDEX IF NOT EXISTS idx_menko_user_id ON menko_records(user_id);

-- ================================================================
-- STEP 2: Add RLS policies for authenticated users (Google OAuth)
-- ================================================================
-- Existing "anon_all" policy covers anon (non-logged-in) operations.
-- These new policies cover Google-authenticated users.

DO $$ BEGIN
  CREATE POLICY "auth_select"
    ON menko_records FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_insert"
    ON menko_records FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_update_own"
    ON menko_records FOR UPDATE TO authenticated
    USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_delete_own"
    ON menko_records FOR DELETE TO authenticated
    USING (auth.uid()::text = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- ================================================================
-- STEP 3: Configure Google OAuth in Supabase Dashboard
-- ================================================================
-- 1. Supabase Dashboard → Authentication → Providers → Google → Enable
-- 2. Enter Google Client ID and Client Secret
--    (Google Cloud Console → APIs & Services → Credentials → OAuth 2.0)
-- 3. Copy "Callback URL (for OAuth)" from Supabase and add it to
--    Google Cloud Console → OAuth 2.0 Client → Authorized redirect URIs
-- 4. Supabase Dashboard → Authentication → URL Configuration
--    Add to "Redirect URLs": https://YOUR-APP.vercel.app/**
--    (also add http://localhost:3000/** for local testing)
