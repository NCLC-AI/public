CREATE TABLE obsidian_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filePath TEXT NOT NULL UNIQUE, -- "folder/note.md"
    fileName TEXT NOT NULL, -- "note.md"
    folder TEXT DEFAULT '', -- "folder"
    content TEXT NOT NULL,
    
    -- Obsidian 메타데이터 (outbound webhook에서 전송)
    size INTEGER,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_obsidian_notes_file_path ON obsidian_notes(filePath);
CREATE INDEX idx_obsidian_notes_updated_at ON obsidian_notes(updated_at);

-- 자동 updated_at 업데이트
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;

$$ language 'plpgsql';

CREATE TRIGGER update_obsidian_notes_timestamp
    BEFORE UPDATE ON obsidian_notes
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TABLE inbound_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename TEXT NOT NULL, -- inbound webhook 응답 format과 동일
    content TEXT NOT NULL,
    path TEXT DEFAULT '', -- optional folder path
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_inbound_queue_created_at ON inbound_queue(created_at);
