<!-- i18n: language-switcher -->
[English](ARCHITECTURE.md) | [日本語](ARCHITECTURE.ja.md)

# Architecture

## Purpose

This repository is a production-style monorepo for practising, across the board, the kind of real services you can build in Haskell, and for managing the resulting artifacts, learning logs, and release preparation online.

There are three points of emphasis.

1. Separate pure domain logic from IO
2. Make logger / store / queue / metrics / event store swappable through the Service/Handle pattern
3. Build web APIs, HTML dashboards, CLIs, workers, edge/WASM, and learning tools on one design philosophy

## Haskell Production Lab

`/lab` is the admin UI, served with Lucid from a Servant API.

- `ProjectStage` expresses idea / building / shipped / maintained / archived as a type
- `LearningOutcome` expresses planned / practiced / understood / blocked as a type
- `LabRelease` holds the notes and artifact URL that precede a GitHub release
- The STM store is a local-first implementation, replaceable later by Postgres / D1

## High-level design

```text
              +-------------------+
HTTP/CLI ---> | app/* executable  |
              +---------+---------+
                        |
                        v
              +-------------------+
              | src/HPS/* library |
              +---------+---------+
                        |
                        v
        +---------------+----------------+
        | Service handles / adapters     |
        | Logger, KV, Queue, Metrics     |
        +--------------------------------+
```

## Core rule

Domain modules should not know about HTTP, files, or Cloudflare. IO modules depend on handles, not concrete implementations.

This allows:

- in-memory tests
- file-backed local demos
- PostgreSQL KV storage and a D1-backed Humblr Database Worker, plus future Redis / R2 adapters
- thinner Servant, Scotty, Yesod, and Workers layers

## Production upgrade path

| Area | Current implementation | Production replacement |
|---|---|---|
| Store | STM / JSON file; PostgreSQL KV adapter | Cloudflare D1, DynamoDB, domain-specific PostgreSQL repositories |
| Queue | STM TQueue | Cloudflare Queues, SQS, Redis Streams |
| Object storage | Blueprint | Cloudflare R2, S3 |
| Observability | in-memory metrics | Prometheus/OpenTelemetry |
| Auth | backlog | JWT/OAuth2, mTLS for internal service calls |
| Deploy | Docker/CI blueprint | Kubernetes, Nomad, Fly.io, Cloudflare Workers |
