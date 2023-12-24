CREATE TABLE IF NOT EXISTS "data" (
    id_data INTEGER PRIMARY KEY AUTOINCREMENT,
    uuid_data TEXT,
    value_data TEXT,
    type_data TEXT,
    parent_uuid_data TEXT,
    key_data TEXT,
    meta_data TEXT,
    date_add_data NUMERIC,
    date_update_data NUMERIC,
    revision_data INTEGER DEFAULT (0),
    is_remove_data INTEGER DEFAULT (0),
    lazy_sync_data TEXT
);
CREATE UNIQUE INDEX IF NOT EXISTS uuid_data_IDX ON "data" (uuid_data);
CREATE INDEX IF NOT EXISTS key_data_IDX ON "data" (key_data);
CREATE INDEX IF NOT EXISTS parent_uuid_data_IDX ON "data" (parent_uuid_data);