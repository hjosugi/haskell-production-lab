<!-- i18n: language-switcher -->
[English](PRODUCTION_CHECKLIST.md) | [日本語](PRODUCTION_CHECKLIST.ja.md)

# Production checklist

## Build and release

- [ ] `cabal build all` passes
- [ ] `cabal test all` passes
- [ ] Haddock builds
- [ ] Docker image builds
- [ ] CI runs on pull request
- [ ] Release artifact is reproducible

## Runtime

- [ ] `/health` returns service name and version
- [ ] `/metrics` is scrapeable
- [ ] logs include timestamp, level, and correlation id
- [ ] graceful shutdown is implemented
- [ ] worker retries are bounded
- [ ] queues have dead-letter handling

## Data

- [ ] DB migrations are versioned
- [ ] backups are tested
- [ ] PII fields are classified
- [ ] idempotency keys are required for money movement
- [ ] event log schema is append-only

## Security

- [ ] authn/authz added to write endpoints
- [ ] request size limit added
- [ ] input validation returns structured errors
- [ ] secrets are not committed
- [ ] dependency audit is part of CI

## Observability

- [ ] metrics by endpoint and status
- [ ] structured JSON logs
- [ ] tracing across service handles
- [ ] alert rules for error rate, latency, queue depth
