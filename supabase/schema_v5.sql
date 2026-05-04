-- Migration v5: Fix admin_config save for authenticated users
-- Run in Supabase SQL Editor AFTER schema_v4.sql

DO $$ BEGIN
  CREATE POLICY "auth_read_config"
    ON admin_config FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_insert_config"
    ON admin_config FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_update_config"
    ON admin_config FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
