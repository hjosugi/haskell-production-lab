<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.0.md) | [日本語](RELEASE_NOTES_v0.1.0.ja.md)

# v0.1.0

Initial public release of Haskell Production Lab.

## Included

- Servant API with `/lab` dashboard
- project, learning log, and release tracking models
- Lucid-rendered HTML management UI
- in-memory STM stores for local development
- typed JSON API for project stages and learning outcomes
- production-style examples for CLI, web, workers, ledger, event sourcing, streaming, search, static site generation, monitoring, WebSockets, and Cloudflare Workers / Haskell WASM blueprints

## Validation

- `cabal test hps-test`
