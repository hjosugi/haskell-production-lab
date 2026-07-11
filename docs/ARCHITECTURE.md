<!-- i18n: language-switcher -->
[English](ARCHITECTURE.md) | [日本語](ARCHITECTURE.ja.md)

# Architecture

## 目的

この repository は「Haskell で作れる実サービス」を横断的に練習し、その制作物・学習ログ・release 準備を online で管理するための production-style monorepo です。

重点は次の3つです。

1. pure domain logic と IO を分離する
2. Service/Handle pattern で logger / store / queue / metrics / event store を差し替え可能にする
3. Web API、HTML dashboard、CLI、worker、edge/WASM、学習ツールまで同じ設計思想で作る

## Haskell Production Lab

`/lab` は Servant API から Lucid で配信される管理 UI です。

- `ProjectStage` で idea / building / shipped / maintained / archived を型として表す
- `LearningOutcome` で planned / practiced / understood / blocked を型として表す
- `LabRelease` で GitHub release 前の notes と artifact URL を管理する
- STM store は local-first な実装で、将来 Postgres / D1 に置き換えられる

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
