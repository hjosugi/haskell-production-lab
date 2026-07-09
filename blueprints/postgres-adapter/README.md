# Postgres adapter blueprint

Future implementation target for `HPS.Service.KV` and ledger storage.

## Shape

```haskell
newPostgresKVHandle :: Pool Connection -> Handle Text Value
newLedgerRepository :: Pool Connection -> LedgerRepository
```

## Migration sketch

```sql
create table kv_store (
  key text primary key,
  value jsonb not null,
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
