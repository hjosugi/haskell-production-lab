<!-- i18n: language-switcher -->
[English](ROADMAP.md) | [日本語](ROADMAP.ja.md)

# Roadmap

## Phase 1: local production-style suite

- [x] Servant API
- [x] Scotty service
- [x] CLI tools
- [x] Worker
- [x] Event store
- [x] Docs and issues

## Phase 2: real storage adapters

- [x] PostgreSQL adapter for KV
- [ ] PostgreSQL repository for ledger
- [x] SQLite/D1 adapter for blog articles, comments, and sessions
- [ ] R2/S3 adapter for object storage
- [ ] Redis/Cloudflare Queue adapter

## Phase 3: full-stack Haskell

- [ ] Miso frontend prototype
- [ ] Yesod blog complete version
- [ ] Servant OpenAPI docs
- [ ] Auth and sessions

## Phase 4: edge deployment

- [ ] GHC wasm build pipeline
- [ ] Worker bundle-size optimization
- [ ] Service Binding integration tests
- [x] D1 migrations in CI
- [ ] R2 upload smoke tests

## PDF-informed learning and hardening

The local PDF sources summarized in `docs/PDF_SOURCE_SYNTHESIS.md` suggest
focused follow-up work that supports the existing production-lab roadmap.

- [ ] Add property tests for ledger invariants, parser round trips, and service handle laws
- [ ] Expand `hps-mmlh` exercises for type errors, parser combinators, and IO boundary refactoring
- [ ] Add serialization/deserialization examples with structured validation errors
- [ ] Document STM queue and WebSocket concurrency choices before replacing them with production adapters
- [ ] Revisit API/domain type design during Servant OpenAPI work
