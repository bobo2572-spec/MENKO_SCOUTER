-- MENKO SCOUTER: Supabase schema
-- Run this in the Supabase SQL Editor

CREATE TABLE IF NOT EXISTS menko_records (
  id          BIGSERIAL PRIMARY KEY,
  device_id   TEXT        NOT NULL,
  name        TEXT        NOT NULL,
  bp          INTEGER     NOT NULL,
  seismic     REAL,
  jerk        REAL,
  peak_g      REAL,
  waveform    JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_menko_device
  ON menko_records (device_id, created_at DESC);

-- Row Level Security: data is filtered by device_id in the client.
-- Anon users can read/write only; no cross-device data is exposed.
ALTER TABLE menko_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_all"
  ON menko_records
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);
