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
- Wrangler config
- D1 schema
- explicit issue backlog for production hardening

## Local alternative

Use `hps-api` as the local Servant version of the same blog/service idea before moving pieces to edge workers.
