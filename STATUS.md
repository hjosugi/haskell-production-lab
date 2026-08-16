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
nix develop -c cabal update
nix develop -c cabal build all
nix develop -c cabal test all

cd cloudflare/humblr-workers
npm run d1:migrate
npm run check
```

The toolchain comes from `flake.nix` and is pinned by `flake.lock`: GHC 9.8.4,
the same version CI installs. Earlier entries in this file recorded whatever
GHC happened to be on the machine, which is why they disagree with each other.

Smoke-tested:

- `GET /health`
- `GET /lab`
- `GET /lab/stats`
- `POST /lab/projects`
- `POST /lab/learning`
- `PUT /lab/projects/:projectId/stage`
- `POST /lab/releases`

## Local environment note

None. The development shell supplies GHC, cabal, haskell-language-server,
fourmolu, and the libpq and zlib that the dependencies link against, so no
machine-level setup is required.

Two workarounds recorded by earlier releases are retired by that shell and
should not be reintroduced:

- a `~/.local/bin/x86_64-conda-linux-gnu-ld` symlink to `/usr/bin/ld`, needed
  because a conda-built GHC looked for a linker under that name
- `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH` in front of `cabal`, needed
  because that GHC did not agree with the system libraries
