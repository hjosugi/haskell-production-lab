# Future issues backlog

Use this file as a GitHub issue seed list. Copy each item into a separate issue when you start work.

## Epic: Database and persistence

### [feature] Add PostgreSQL adapter for `HPS.Service.KV`

Labels: `enhancement`, `database`, `production`

Acceptance criteria:

- [ ] `newPostgresHandle :: Pool Connection -> Handle Text v`
- [ ] migration file included
- [ ] JSONB encode/decode covered by tests
- [ ] failure cases documented

### [feature] Add D1 adapter for Cloudflare blueprint

Labels: `enhancement`, `cloudflare`, `database`

Acceptance criteria:

- [ ] D1 migrations for articles, comments, sessions
- [ ] local `wrangler d1` workflow documented
- [ ] Router Worker calls Database Worker through Service Bindings

## Epic: API production hardening

### [feature] Add auth to write endpoints

Labels: `security`, `api`

Acceptance criteria:

- [ ] API key middleware for local dev
- [ ] JWT/OAuth2 design doc
- [ ] unauthorized requests return structured JSON
- [ ] tests for read/write permissions

### [feature] Add request id and structured JSON logging

Labels: `observability`

Acceptance criteria:

- [ ] request id propagated to logger
- [ ] logs are JSON lines
- [ ] error logs include endpoint and status

## Epic: Full-stack Haskell

### [feature] Add Miso frontend for articles

Labels: `frontend`, `miso`, `wasm`

Acceptance criteria:

- [ ] article list page
- [ ] article editor page
- [ ] Servant client generated or manually typed
- [ ] build docs for browser target

### [feature] Complete Yesod blog workshop blueprint

Labels: `yesod`, `education`

Acceptance criteria:

- [ ] routes for blog CRUD
- [ ] persistent models
- [ ] auth skeleton
- [ ] tutorial notes from beginner to production

## Epic: Workers/WASM

### [feature] Build Haskell WASM router module

Labels: `cloudflare`, `wasm`, `edge`

Acceptance criteria:

- [ ] `wasm32-wasi-cabal build` documented
- [ ] generated `.wasm` imported from Worker shim
- [ ] bundle size checked in CI
- [ ] fallback JS handler for local development

### [feature] Split Humblr service bindings

Labels: `cloudflare`, `architecture`

Acceptance criteria:

- [ ] Router Worker binding to Database Worker
- [ ] Router Worker binding to Storage Worker
- [ ] Router Worker binding to Images Worker
- [ ] SSR Worker contract documented

## Epic: Learning platform

### [feature] Add real compiler feedback to `hps-mmlh`

Labels: `education`, `compiler`

Acceptance criteria:

- [ ] run `ghc -fno-code` on submissions
- [ ] parse type errors into hints
- [ ] store attempt history
- [ ] add difficulty levels

## Epic: Reliability

### [feature] Dead-letter queue for worker

Labels: `worker`, `reliability`

Acceptance criteria:

- [ ] max retry count
- [ ] failed job store
- [ ] replay command
- [ ] metrics for failures and retries

### [feature] Ledger idempotency keys

Labels: `fintech`, `ledger`

Acceptance criteria:

- [ ] reject duplicate transaction keys
- [ ] ensure exactly-once posting per key
- [ ] add property tests for zero-sum invariant
