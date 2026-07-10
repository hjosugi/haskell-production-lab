# PostgreSQL adapter status

The generic `HPS.Service.KV` adapter is implemented in
`HPS.Service.KV.Postgres`. See `docs/POSTGRESQL_KV.md` for pool construction,
migration steps, tests, and failure behavior. The ledger repository remains a
future implementation target.

## Shape

```haskell
newPostgresHandle :: (FromJSON v, ToJSON v) => Pool Connection -> Handle Text v
newLedgerRepository :: Pool Connection -> LedgerRepository
```

## Migration sketch

```sql
create table hps_kv (
  kv_key text primary key,
  kv_value jsonb not null,
  updated_at timestamptz not null default now()
);

create table ledger_transactions (
  id text primary key,
  description text not null,
  created_at timestamptz not null
);

create table ledger_postings (
  transaction_id text references ledger_transactions(id),
  account text not null,
  amount numeric not null
);
```
