-- 1. Create alarms table
CREATE TABLE IF NOT EXISTS alarms (
    id TEXT PRIMARY KEY,
    pair_code TEXT NOT NULL,
    title TEXT NOT NULL DEFAULT 'Wake up ❤️',
    hour INTEGER NOT NULL,
    minute INTEGER NOT NULL,
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    repeat_days JSONB NOT NULL DEFAULT '[]'::jsonb,
    require_both_to_dismiss BOOLEAN NOT NULL DEFAULT true,
    dismissed_by JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_by_name TEXT NOT NULL DEFAULT 'Partner',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. Create index for fast pair_code queries
CREATE INDEX IF NOT EXISTS idx_alarms_pair_code ON alarms (pair_code);

-- 3. Enable Row Level Security (RLS) with open public access for paired devices
ALTER TABLE alarms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all access for all users" ON alarms
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- 4. Enable Realtime updates
ALTER PUBLICATION supabase_realtime ADD TABLE alarms;
