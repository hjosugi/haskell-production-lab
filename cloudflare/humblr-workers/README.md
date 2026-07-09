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
npm install
npx wrangler dev --config wrangler.router.jsonc
```

## Haskell/WASM build idea

```bash
wasm32-wasi-cabal build exe:humblr-router
cp $(wasm32-wasi-cabal list-bin exe:humblr-router) dist/humblr_router.wasm
npx wrangler deploy --config wrangler.router.jsonc
```

The `.hs` files here are intentionally not part of the root Cabal build. They document the Worker-facing contracts and keep edge experiments isolated from the local Servant apps.
