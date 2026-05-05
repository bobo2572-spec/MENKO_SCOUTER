-- Migration v6: Storage bucket policies + menko_measurements UPDATE policy
-- Run in Supabase SQL Editor AFTER schema_v5.sql

-- ================================================================
-- STEP 1: Storage bucket policies for "menko-photos"
-- ================================================================
-- IMPORTANT: First confirm the bucket exists in Supabase Dashboard
--   Storage → Buckets → "menko-photos" (Public: ON)
--   If it doesn't exist, create it there first.

-- Public read (anyone can view photos)
DO $$ BEGIN
  CREATE POLICY "public_read_menko_photos"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'menko-photos');
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- Authenticated users can upload (INSERT)
DO $$ BEGIN
  CREATE POLICY "auth_insert_menko_photos"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'menko-photos');
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- Authenticated users can overwrite (UPDATE) — needed for upsert
DO $$ BEGIN
  CREATE POLICY "auth_update_menko_photos"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'menko-photos');
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- Authenticated users can delete their photos
DO $$ BEGIN
  CREATE POLICY "auth_delete_menko_photos"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'menko-photos');
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- ================================================================
-- STEP 2: Add missing UPDATE policy for menko_measurements
-- ================================================================
-- Without this, saving a photo URL to a measurement record fails.

DO $$ BEGIN
  CREATE POLICY "auth_update_measurements"
    ON menko_measurements FOR UPDATE TO authenticated
    USING (true) WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;
