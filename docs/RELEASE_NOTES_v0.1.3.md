<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.3.md) | [日本語](RELEASE_NOTES_v0.1.3.ja.md)

# v0.1.3

Maintenance release for Haskell Production Lab.

## Included

- Release workflow: the language switcher at the top of each
  `docs/RELEASE_NOTES_<tag>.md` is stripped from the release body. Its links
  are relative to `docs/` and 404 under `/releases/`. The files keep it.
- CI caches the cabal store, keyed on the resolved build plan
  (`cabal build all --dry-run` writes `plan.json` before anything compiles),
  so the cabal job no longer rebuilds every Hackage dependency on every run.
- Cloudflare Workers blueprint (`cloudflare/humblr-workers`) development
  dependencies: wrangler 4.114.0, @cloudflare/vitest-pool-workers 0.18.8,
  miniflare 4.20260722.0, postcss 8.5.25, and sharp 0.35.2 (#4).

## Validation

- `cloudflare/humblr-workers` on Node 22: `npm ci`,
  `CI=true npm run d1:migrate`, and `npm run check` (Wrangler type check,
  `tsc --noEmit`, Vitest, and `wrangler deploy --dry-run` for both workers)
- CI on `main`: the `workers` job, and the `cabal` job running
  `cabal build all` and `cabal test all` on GHC 9.8.4 against PostgreSQL 16

## Notes

- No library, executable, or API behaviour changed in this release.
