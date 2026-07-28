<!-- i18n: language-switcher -->
[English](README.md) | [日本語](README.ja.md)

# Haskell Production Lab

Haskell Production Lab is a public, production-style monorepo for going deep on Haskell by building real applications and tracking the work online.

The main app is a Haskell-built lab dashboard served from the Servant API at `/lab`. It manages:

- Haskell app ideas and shipped projects
- learning logs and practice notes
- release notes and artifact links
- health, metrics, event logs, search, jobs, ledger demos, and supporting CLI apps

The repository also includes focused examples: URL shorteners, a double-entry ledger, STM workers, event sourcing, streaming analytics, parser/search, a static site generator, an mmlh-style learning CLI, runtime monitoring, WebSocket chat, TUI Kanban, and Cloudflare Workers / Haskell WASM blueprints.

## Quick Start

```bash
cabal update
cabal build all
cabal test all

cabal run hps-api
```

Open:

```text
http://localhost:8080/lab
```

The API defaults to port `8080`. Override it with:

```bash
PORT=9000 cabal run hps-api
```

## Lab API

```bash
curl localhost:8080/health
curl localhost:8080/lab/stats
curl localhost:8080/lab/projects

curl -X POST localhost:8080/lab/projects \
  -H 'content-type: application/json' \
  -d '{
    "projectNameSeed": "Typed calculator",
    "projectSummarySeed": "Pure calculation core with a CLI wrapper.",
    "projectRepoSeed": null,
    "projectDemoSeed": null,
    "projectTagsSeed": ["calculator", "types"]
  }'
```

## Repository Map

```text
src/                       Shared Haskell library
src/HPS/Lab*.hs            Project, learning, release dashboard
app/                       Executable applications
cloudflare/humblr-workers/ Haskell/WASM Cloudflare Workers blog blueprint
migrations/postgresql/     Versioned PostgreSQL schema migrations
docs/                      Architecture, runbooks, production notes, references
issues/                    Markdown issue backlog and future features
examples/                  Sample inputs and request files
.github/                   CI, release workflow, issue templates
```

## Why Haskell Here?

The code keeps pure business logic separate from IO handles. Project stages, learning outcomes, release records, ledger invariants, and job states are modeled with algebraic data types instead of loose strings. That makes the system easier to refactor, test, and move from in-memory STM storage to PostgreSQL, Cloudflare D1/R2, or another production backend.

## Release Flow

Create a tag and push it:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The GitHub release workflow builds a source archive and publishes a release from the tag. A first release can also be created manually with:

```bash
gh release create v0.1.0 --title "v0.1.0" --notes-file docs/RELEASE_NOTES_v0.1.0.md
```
