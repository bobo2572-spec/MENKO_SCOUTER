-- Migration v4: photo_url + measurement history
-- Run in Supabase SQL Editor AFTER schema_v3.sql

-- ================================================================
-- STEP 1: Add photo_url to menko_records
-- ================================================================
ALTER TABLE menko_records
  ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- ================================================================
-- STEP 2: Measurement history table
-- ================================================================
CREATE TABLE IF NOT EXISTS menko_measurements (
  id          UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  menko_id    BIGINT      NOT NULL REFERENCES menko_records(id) ON DELETE CASCADE,
  bp          INTEGER     NOT NULL,
  surface     TEXT        DEFAULT 'concrete',
  waveform    JSONB,
  photo_url   TEXT,
  notes       TEXT,
  user_id     TEXT,
  measured_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_measurements_menko
  ON menko_measurements(menko_id, measured_at ASC);

ALTER TABLE menko_measurements ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "anon_read_measurements"
    ON menko_measurements FOR SELECT TO anon USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "anon_insert_measurements"
    ON menko_measurements FOR INSERT TO anon WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_read_measurements"
    ON menko_measurements FOR SELECT TO authenticated USING (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
  CREATE POLICY "auth_insert_measurements"
    ON menko_measurements FOR INSERT TO authenticated WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- ================================================================
-- STEP 3: Create Storage bucket (manual in Supabase Dashboard)
-- ================================================================
-- Storage → New bucket → Name: "menko-photos" → Public: ON
-- Then add policies:
--   SELECT: allow all (public read)
--   INSERT: allow authenticated users
