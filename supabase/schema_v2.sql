-- Migration v2: owner / birth / surface columns + admin_config table
-- Run in Supabase SQL Editor AFTER schema.sql

ALTER TABLE menko_records
  ADD COLUMN IF NOT EXISTS owner       TEXT    DEFAULT '不明',
  ADD COLUMN IF NOT EXISTS birth_year  INTEGER,
  ADD COLUMN IF NOT EXISTS birth_month INTEGER,
  ADD COLUMN IF NOT EXISTS surface     TEXT    DEFAULT 'concrete';

CREATE TABLE IF NOT EXISTS admin_config (
  id         TEXT        PRIMARY KEY,
  value      JSONB       NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_read_config"
  ON admin_config FOR SELECT TO anon USING (true);

CREATE POLICY "anon_write_config"
  ON admin_config FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "anon_update_config"
  ON admin_config FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Default parameters
INSERT INTO admin_config (id, value) VALUES
  ('surface_params', '{
    "concrete": {"thresholdMult": 4, "bpScale": 1.0},
    "asphalt":  {"thresholdMult": 4, "bpScale": 1.0},
    "dirt":     {"thresholdMult": 3, "bpScale": 1.3}
  }'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO admin_config (id, value) VALUES
  ('bp_params', '{
    "W": 60,
    "jerkNormDivisor": 30,
    "jerkPower": 1.5
  }'::jsonb)
ON CONFLICT (id) DO NOTHING;
