# Cloudflare Workers + Haskell WASM blueprint

The `cloudflare/humblr-workers` folder is inspired by the Haskell-on-Cloudflare blog engine architecture in the provided article.

## Service split

```text
Router Worker  -> public HTTP routes
Database Worker -> D1 SQL access
Storage Worker  -> R2 object storage access
Images Worker   -> image transform boundary
SSR Worker      -> Haskell/Miso-like rendering boundary
```

## Why split services?

The split keeps each Worker small, avoids one giant module, and gives clear ownership:

- Router decides request flow.
- Database owns SQL and migrations.
- Storage owns object keys and upload policy.
- Images owns resize/format policy.
- SSR owns HTML rendering.

## Haskell/WASM caveat

Haskell-to-WASM through the GHC wasm backend is real, but Cloudflare Worker integration still needs a JS module boundary and careful bundle-size/memory testing. The blueprint therefore includes:

- Haskell shared API/domain modules
- Worker JS shims
- generated binding types from Wrangler config
- versioned D1 migrations for articles, comments, and hashed sessions
- Router-to-Database Service Binding routing
- workerd/Vitest integration tests and deploy dry-runs
- explicit issue backlog for production hardening

## D1 workflow

The executable workflow is documented in
`cloudflare/humblr-workers/README.md`. In short, `npm run d1:migrate` applies
only to Wrangler's local state, `npm test` runs migrations and Database Worker
requests inside workerd, and `npm run deploy` deploys Database Worker before
the Router Worker. Remote migrations require the explicit
`d1:migrate:remote` command.

## Local alternative

Use `hps-api` as the local Servant version of the same blog/service idea before moving pieces to edge workers.
