# Humblr Workers Blueprint

Cloudflare Workers + Haskell/WASM blog engine blueprint.

This folder mirrors a production split:

```text
router-worker      public routes, auth, service orchestration
database-worker    D1 SQL access
storage-worker     R2 object storage
images-worker      image policy and transform boundary
ssr-worker         HTML rendering through Haskell/WASM or a fallback renderer
```

## Local commands

```bash
npm ci
npm run types
npm run d1:migrate
npm run dev
```

`d1:migrate` applies `schema/*.sql` to Wrangler's local-only D1 state under
`.wrangler/state`. It creates the `articles`, `comments`, and `sessions` tables;
it never touches a remote database. Inspect the local schema with:

```bash
npx wrangler d1 execute DB --local \
  --config wrangler.database.jsonc \
  --command "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name"
```

`npm run dev` starts Router Worker as the primary Worker and Database Worker as
a secondary Worker in Wrangler's multi-config development mode. The router's
`DATABASE` Service Binding is connected without a public HTTP hop. If the
experimental multi-config mode is unavailable, run these in separate terminals:

```bash
npm run dev:database
npm run dev:router
```

## D1 API boundary

Public routes forwarded by Router Worker:

- `GET/POST /api/articles`
- `GET /api/articles/:slug`
- `GET/POST /api/articles/:slug/comments`

The Database Worker also has Service-Binding-only session routes under
`/internal/sessions`. Session callers provide a SHA-256 hexadecimal token hash;
raw session tokens are never stored or returned. The Database Worker has
`workers_dev: false`, so deployment does not expose a `workers.dev` endpoint.

All D1 values are passed through prepared statements with `.bind()`. JSON input
is size-limited and validated before queries run, and database failures return
structured errors without exposing SQL details.

## Verification and deployment

```bash
npm run typecheck
npm test
npm run deploy:dry-run
npm run check
```

The first Database Worker deployment automatically provisions the D1 binding
because the template intentionally omits an account-specific `database_id`.
Deploy the Database Worker before applying remote migrations and deploying the
Router Worker; `npm run deploy` enforces that order. Remote migration commands
are explicit and never run as part of local development.

## Haskell/WASM build idea

```bash
wasm32-wasi-cabal build exe:humblr-router
cp $(wasm32-wasi-cabal list-bin exe:humblr-router) dist/humblr_router.wasm
npx wrangler deploy --config wrangler.router.jsonc
```

The `.hs` files here are intentionally not part of the root Cabal build. They document the Worker-facing contracts and keep edge experiments isolated from the local Servant apps.
