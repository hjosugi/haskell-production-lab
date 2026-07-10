# PostgreSQL KV adapter

`HPS.Service.KV.Postgres` provides a PostgreSQL implementation of the existing
`Handle Text v` interface. Values are encoded with Aeson and stored in the
`hps_kv.kv_value` JSONB column.

## Prerequisites

- PostgreSQL 14 or newer
- PostgreSQL client headers and pkg-config (`libpq-dev` and `pkg-config` on Ubuntu) when building
- `psql` or another migration runner

For local development, start the Compose database and apply the migration:

```bash
docker compose up -d postgres
docker compose exec -T postgres \
  psql -U hps -d hps < migrations/postgresql/0001_hps_kv.sql
```

The default local connection string is:

```text
postgresql://hps:hps@localhost:5432/hps
```

## Constructing the handle

The application owns the connection pool. The adapter checks out one connection
per operation and never closes the pool itself.

```haskell
import qualified Data.ByteString.Char8 as BS8
import Data.Pool (defaultPoolConfig, newPool)
import Data.Text (Text)
import Database.PostgreSQL.Simple (close, connectPostgreSQL)
import HPS.Service.KV (Handle)
import HPS.Service.KV.Postgres (newPostgresHandle)

pool <- newPool $ defaultPoolConfig
  (connectPostgreSQL (BS8.pack databaseUrl))
  close
  30 -- idle seconds
  10 -- maximum connections

let store = newPostgresHandle pool :: Handle Text MyValue
```

`kvPut` uses `INSERT ... ON CONFLICT`, so writing an existing key replaces its
value and updates `updated_at`. `kvList` is ordered by key for deterministic
results. Each operation is atomic, but a sequence of handle calls is not a
transaction.

## Failure behavior

| Failure | Behavior | Caller action |
|---|---|---|
| Migration missing | PostgreSQL `SqlError` (normally SQLSTATE `42P01`) propagates | Run `0001_hps_kv.sql` before serving traffic |
| Connection/query failure | Original `postgresql-simple` exception propagates; `withResource` discards the failed connection | Retry only transient SQLSTATE classes and use bounded backoff |
| Pool exhausted | `withResource` waits for a connection | Size the pool and add a request-level timeout |
| Stored JSON does not match `v` | `PostgresKVDecodeError` includes the affected key and Aeson message | Repair/migrate the row; do not blindly retry |
| One malformed row during `kvList` | The whole list operation fails with `PostgresKVDecodeError` | Repair the named row or provide a schema migration |
| PostgreSQL rejects a text key, such as one containing NUL | Original `SqlError` propagates | Validate keys at the application boundary |

The table is generic but a handle assumes every row has the same Haskell value
type `v`. Do not use one `hps_kv` table for unrelated value schemas without an
explicit envelope/version field. JSON schema evolution should be deployed with
a data migration before readers require the new shape.

The adapter does not log connection strings or values. Keep credentials in
`DATABASE_URL` or a secret manager, not in source control.

## Tests

The default test suite always checks successful and rejected JSONB codec paths.
Set `HPS_TEST_DATABASE_URL` to additionally apply the migration in an isolated
schema and exercise insert, fetch, ordered list, update, and delete against a
real PostgreSQL server:

```bash
HPS_TEST_DATABASE_URL=postgresql://hps:hps@localhost:5432/hps cabal test all
```

The integration test only creates and drops the dedicated
`hps_kv_integration_test` schema. CI runs this integration path against its
ephemeral PostgreSQL service.
