<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.1.md) | [日本語](RELEASE_NOTES_v0.1.1.ja.md)

# v0.1.1

PDF-informed documentation release for Haskell Production Lab.

## Included

- Local PDF source synthesis for three working reference materials:
  `haskell book`, `Haskell.pdf`, and `FP pragpub0.pdf`.
- Topic mapping from the PDF material to the Servant API, service pattern,
  pure-core/IO boundary, type classes, parsing, serialization, STM concurrency,
  testing, and deployment areas of this repository.
- References documentation that records the local PDFs as non-committed working
  material.
- Roadmap items for property tests, parser exercises, serialization examples,
  concurrency documentation, and API/domain type review.

## Validation

- `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH cabal build all`
- `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH cabal test all`

## Notes

- The source PDFs remain local untracked files and are not included in this
  release.
- Long verbatim excerpts from the PDFs are intentionally excluded.
