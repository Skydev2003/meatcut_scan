-- MeatCut Scan Database Schema
-- Run this SQL in Supabase SQL Editor

-- Create samples table
CREATE TABLE IF NOT EXISTS samples (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  label TEXT NOT NULL,
  embedding FLOAT8[] NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE samples ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can access their own samples" ON samples;

-- Create policy for users to access their own samples
CREATE POLICY "Users can access their own samples"
  ON samples
  FOR ALL
  USING (auth.uid() = user_id);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_samples_user_id ON samples(user_id);
CREATE INDEX IF NOT EXISTS idx_samples_label ON samples(label);
CREATE INDEX IF NOT EXISTS idx_samples_created_at ON samples(created_at DESC);

-- Create storage bucket for images
INSERT INTO storage.buckets (id, name, public)
VALUES ('meat-images', 'meat-images', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage policy
CREATE POLICY "Users can upload their own images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'meat-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view their own images"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'meat-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create function to get user statistics
CREATE OR REPLACE FUNCTION get_user_stats(user_uuid UUID)
RETURNS TABLE (
  total_samples BIGINT,
  labels_count BIGINT,
  latest_sample TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::BIGINT as total_samples,
    COUNT(DISTINCT label)::BIGINT as labels_count,
    MAX(created_at) as latest_sample
  FROM samples
  WHERE user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
