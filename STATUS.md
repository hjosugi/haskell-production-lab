# Status

## What is implemented

- Cabal monorepo with shared library and 13 executable targets
- PostgreSQL JSONB adapter for `HPS.Service.KV`, with a versioned migration
- Cloudflare D1 adapter for Humblr articles, comments, and hashed sessions
- Servant REST API gateway
- `/lab` Haskell Production Lab dashboard for projects, learning logs, and release preparation
- Lucid-rendered HTML UI and typed JSON API
- Scotty URL shortener service
- CLI URL shortener
- fintech ledger CLI
- STM worker queue
- event sourcing demo
- stream analytics CLI
- search CLI
- static site generator
- mmlh-style learning CLI
- runtime monitor
- WebSocket chat server
- TUI kanban demo
- Cloudflare Workers + Haskell/WASM blog blueprint
- Yesod blog workshop blueprint
- Docker, docker-compose, CI, release workflow, issue templates, docs, examples

## Verification done

```bash
cabal update
cabal build all
cabal test hps-test

cd cloudflare/humblr-workers
npm run d1:migrate
npm run check
```

The local GHC is `8.10.7` and cabal-install is `3.16.1.0`.

Smoke-tested:

- `GET /health`
- `GET /lab`
- `GET /lab/stats`
- `POST /lab/projects`
- `POST /lab/learning`
- `PUT /lab/projects/:projectId/stage`
- `POST /lab/releases`

## Local environment note

This runtime's GHC expects a linker named `x86_64-conda-linux-gnu-ld`. A local symlink to `/usr/bin/ld` was created under `~/.local/bin` so Cabal could compile dependencies.
