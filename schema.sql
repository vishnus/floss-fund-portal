CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -- entities
-- DROP TYPE IF EXISTS entity_type CASCADE; CREATE TYPE entity_type AS ENUM ('individual', 'group', 'organisation', 'other');
-- DROP TYPE IF EXISTS entity_role CASCADE; CREATE TYPE entity_role AS ENUM ('owner', 'steward', 'maintainer', 'contributor', 'other');
-- DROP TABLE IF EXISTS entities CASCADE;
-- CREATE TABLE IF NOT EXISTS entities (
--     id                  SERIAL PRIMARY KEY,
--     uuid                UUID NOT NULL UNIQUE DEFAULT GEN_RANDOM_UUID(),

--     type                entity_type NOT NULL,
--     role                entity_role NOT NULL,
--     name                TEXT NOT NULL,
--     email               TEXT NOT NULL,
--     telephone           TEXT NOT NULL DEFAULT '',
--     webpage_url         TEXT NOT NULL,
--     webpage_wellknown   TEXT NULL,
--     meta                JSONB NOT NULL DEFAULT '{}',
--     entry_id             INTEGER REFERENCES manifests(id) ON DELETE CASCADE ON UPDATE CASCADE

--     created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--     updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- DROP INDEX IF EXISTS idx_entity_entry; CREATE INDEX idx_entity_entry ON entities(entry_id);


-- -- projects
-- DROP TABLE IF EXISTS projects CASCADE;
-- CREATE TABLE IF NOT EXISTS projects (
--     id                   SERIAL PRIMARY KEY,
--     uuid                 UUID NOT NULL UNIQUE DEFAULT GEN_RANDOM_UUID(),

--     name                 TEXT NOT NULL,
--     description          TEXT NOT NULL,
--     webpage_url          TEXT NOT NULL,
--     webpage_wellknown    TEXT NULL,
--     repository_url       TEXT NOT NULL,
--     repository_wellknown TEXT NULL,
--     license              TEXT NOT NULL,
--     languages            TEXT[] NOT NULL,
--     tags                 TEXT[] NOT NULL,
--     meta                 JSONB NOT NULL DEFAULT '{}',
--     entry_id             INTEGER REFERENCES manifests(id) ON DELETE CASCADE ON UPDATE CASCADE

--     created_at           TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
--     updated_at           TIMESTAMP WITH TIME ZONE DEFAULT NOW()
-- );
-- DROP INDEX IF EXISTS idx_project_entry; CREATE INDEX idx_project_entry ON projects(entry_id);


-- manifests
DROP TYPE IF EXISTS entry_status CASCADE; CREATE TYPE entry_status AS ENUM ('pending', 'enabled', 'expiring', 'disabled');
DROP TABLE IF EXISTS manifests CASCADE;
CREATE TABLE manifests (
    id                   SERIAL PRIMARY KEY,
    uuid                 UUID NOT NULL UNIQUE DEFAULT GEN_RANDOM_UUID(),

    version              TEXT NOT NULL,
    url                  TEXT NOT NULL UNIQUE,
    body                 JSONB NOT NULL,
    entity               JSONB NOT NULL DEFAULT '{}',
    projects             JSONB NOT NULL DEFAULT '[]',
    funding_channels     JSONB NOT NULL DEFAULT '[]',
    funding_plans        JSONB NOT NULL DEFAULT '[]',
    funding_history      JSONB NOT NULL DEFAULT '[]',
    meta                 JSONB NOT NULL DEFAULT '{}',
    status               entry_status NOT NULL DEFAULT 'pending',
    status_message       TEXT NULL,

    created_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
DROP INDEX IF EXISTS idx_uuid; CREATE UNIQUE INDEX idx_uuid ON manifests(uuid);
DROP INDEX IF EXISTS idx_version; CREATE UNIQUE INDEX idx_version ON manifests(version);
DROP INDEX IF EXISTS idx_status; CREATE UNIQUE INDEX idx_status ON manifests(status);
DROP INDEX IF EXISTS idx_entity_email; CREATE INDEX idx_entity_email ON manifests USING GIN ((entity ->> 'email'));
DROP INDEX IF EXISTS idx_entity_name; CREATE INDEX idx_entity_name ON manifests USING GIN (to_tsvector('english', entity ->> 'name'));
DROP INDEX IF EXISTS idx_entity_webpage; CREATE INDEX idx_entity_webpage ON manifests USING GIN ((entity ->> 'webpage_url'));
DROP INDEX IF EXISTS idx_project_webpage; CREATE INDEX idx_project_webpage ON manifests ((entity ->> 'webpage_url'));
DROP INDEX IF EXISTS idx_project_repository; CREATE INDEX idx_project_repository ON manifests ((entity ->> 'repository_url'));
DROP INDEX IF EXISTS idx_project_license; CREATE INDEX idx_project_license ON manifests ((entity ->> 'license'));
DROP INDEX IF EXISTS idx_project_frameworks; CREATE INDEX idx_project_frameworks ON manifests USING GIN ((entity -> 'frameworks') jsonb_path_ops);
DROP INDEX IF EXISTS idx_project_tags; CREATE INDEX idx_project_tags ON manifests USING GIN ((entity -> 'tags') jsonb_path_ops);


-- settings
DROP TABLE IF EXISTS settings CASCADE;
CREATE TABLE settings (
    key                 TEXT NOT NULL UNIQUE,
    value               JSONB NOT NULL DEFAULT '{}',
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
DROP INDEX IF EXISTS idx_settings_key; CREATE INDEX idx_settings_key ON settings(key);