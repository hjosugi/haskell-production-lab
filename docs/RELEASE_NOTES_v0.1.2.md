<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.2.md) | [日本語](RELEASE_NOTES_v0.1.2.ja.md)

# v0.1.2

Reproducible toolchain release for Haskell Production Lab.

## Included

- `flake.nix`, `flake.lock`, and `.envrc` declaring the development shell:
  GHC 9.8.4, cabal-install, haskell-language-server, and fourmolu, plus the
  libpq and zlib the dependencies link against.
- The shell's compiler is the same GHC 9.8.4 that
  `.github/workflows/ci.yml` installs, so a local build and a CI build no
  longer differ by whichever GHC happened to be on the machine.
- Release workflow fix: the notes file is now resolved per tag as
  `docs/RELEASE_NOTES_<tag>.md`. It was hard-coded to `RELEASE_NOTES_v0.1.0.md`,
  so any tag after v0.1.0 would have published v0.1.0's text as its own notes.
  A missing file now falls back to generated notes instead.
- README, README.ja, and STATUS updated for the shell-based workflow.

## Retired workarounds

Both came from a GHC installed outside any package manager and are no longer
needed. They should not be reintroduced.

- The `~/.local/bin/x86_64-conda-linux-gnu-ld` symlink to `/usr/bin/ld`, which
  a conda-built GHC needed to find a linker.
- `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH` in front of `cabal`, which
  v0.1.1 recorded as part of its validation commands.

## Validation

- `nix develop -c cabal build all`
- `nix develop -c cabal test all`
- `cabal test all` once more with `HPS_TEST_DATABASE_URL` pointing at a
  PostgreSQL 18.4 server started from the same shell, so the libpq path is
  exercised rather than skipped
- `nix flake check`

## Notes

- No library, executable, or API behaviour changed in this release.
- The PostgreSQL integration test still skips itself when
  `HPS_TEST_DATABASE_URL` is unset.
