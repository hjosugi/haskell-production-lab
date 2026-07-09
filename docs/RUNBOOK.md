# Runbook

## Start local API

```bash
cabal run hps-api
```

## Smoke test

```bash
curl localhost:8080/health
curl localhost:8080/metrics
curl localhost:8080/lab/stats
```

Open the management UI:

```text
http://localhost:8080/lab
```

## Add lab project

```bash
curl -X POST localhost:8080/lab/projects \
  -H 'content-type: application/json' \
  -d '{"projectNameSeed":"Typed calculator","projectSummarySeed":"Pure calculation core and CLI wrapper.","projectRepoSeed":null,"projectDemoSeed":null,"projectTagsSeed":["calculator","types"]}'
```

## Log learning

```bash
curl -X POST localhost:8080/lab/learning \
  -H 'content-type: application/json' \
  -d '{"learningTopicSeed":"Servant API types","learningNotesSeed":"API shape is a type, handler order follows the type.","learningLinksSeed":[],"learningOutcomeSeed":"practiced"}'
```

## Add article

```bash
curl -X POST localhost:8080/articles \
  -H 'content-type: application/json' \
  -d '{"seedTitle":"Hello","seedSlug":"hello","seedBody":"body","seedTags":["demo"]}'
```

## Debug queue

```bash
cabal run hps-worker
```

## Common failure cases

### Cabal solver fails

Run:

```bash
cabal update
cabal clean
cabal build all --allow-newer
```

Then pin versions in `cabal.project.freeze`.

### Port already in use

```bash
PORT=9000 cabal run hps-api
```

### Cloudflare Worker bundle too large

Reduce Haskell/WASM dependencies, strip symbols, split services, and keep heavy rendering outside latency-sensitive Workers.
