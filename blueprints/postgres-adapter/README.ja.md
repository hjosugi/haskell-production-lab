<!-- i18n: language-switcher -->
[English](README.md) | [日本語](README.ja.md)

# PostgreSQLアダプタの状態

汎用の `HPS.Service.KV` アダプタは `HPS.Service.KV.Postgres` に実装されています。プールの構築、マイグレーション手順、テスト、障害時の挙動については `docs/POSTGRESQL_KV.md` を参照してください。台帳リポジトリは今後の実装対象です。

## 形状

```haskell
newPostgresHandle :: (FromJSON v, ToJSON v) => Pool Connection -> Handle Text v
newLedgerRepository :: Pool Connection -> LedgerRepository
```

## マイグレーションの概要

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