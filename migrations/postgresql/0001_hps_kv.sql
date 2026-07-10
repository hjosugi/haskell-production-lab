BEGIN;

CREATE TABLE IF NOT EXISTS hps_kv (
    kv_key TEXT PRIMARY KEY,
    kv_value JSONB NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE hps_kv IS
    'Generic JSONB key-value storage for HPS.Service.KV.Postgres';

COMMIT;
