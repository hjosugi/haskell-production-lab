<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.4.md) | [日本語](RELEASE_NOTES_v0.1.4.ja.md)

# v0.1.4

Maintenance release for Haskell Production Lab.

## Included

- Cloudflare Workers blueprint (`cloudflare/humblr-workers`) development
  dependencies take the open security advisories while staying on vitest 4,
  because `@cloudflare/vitest-pool-workers` still peers on `vitest ^4.1.0`
  (#6):
  - vitest and @vitest/mocker 4.1.11 (GHSA-82fw-gwwq-j7x9)
  - undici 7.29.0, through @cloudflare/vitest-pool-workers 0.22.0 and
    wrangler ^4.124.0, whose miniflare pins it
  - sharp 0.35.4 (GHSA-rgj7-g3m4-5g8c), as an `overrides` entry: miniflare
    pins sharp exactly and the newest vitest-pool-workers still pins 0.35.2.
    The override can go once vitest-pool-workers ships a newer miniflare.

## Validation

- `cloudflare/humblr-workers` on Node 22: `npm ci`, `npm audit`
  (0 vulnerabilities), `CI=true npm run d1:migrate`, and `npm run check`
  (Wrangler type check, `tsc --noEmit`, Vitest, and
  `wrangler deploy --dry-run` for both workers)
- CI on `main`: the `workers` job, and the `cabal` job running
  `cabal build all` and `cabal test all` on GHC 9.8.4 against PostgreSQL 16

## Notes

- No library, executable, or API behaviour changed in this release.
