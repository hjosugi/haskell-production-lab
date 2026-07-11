<!-- i18n: language-switcher -->
[English](PDF_SOURCE_SYNTHESIS.md) | [日本語](PDF_SOURCE_SYNTHESIS.ja.md)

# PDF source synthesis

This document summarizes three local PDF reference materials used as learning
and research inputs for Haskell Production Lab. The PDFs are local working
materials only, are not included in source control, and should not be committed
to this repository.

The notes below are synthesized from PDF metadata and high-level chapter or
section structure. They intentionally avoid long verbatim excerpts.

## Local sources reviewed

| Local file | Bibliographic metadata from PDF | High-level scope | Contribution to this repo |
|---|---|---|---|
| `haskell book` | Subject: Haskell Programming. Authors: Chris Allen and Julie Moronuki. Keywords include Haskell, lambda calculus, functional programming, and type theory. 1908 pages. PDF creation date: 2020-01-26 JST. | A deep foundational Haskell curriculum covering lambda calculus, basic syntax, types, type classes, ADTs, error signaling, modules, IO, testing, algebraic abstractions, parser combinators, monad transformers, non-strictness, core libraries, and a final project. | Provides the long-form learning backbone for the lab: pure domain modeling, algebraic data types, type-class driven design, parser exercises, law-oriented tests, and the staged path from beginner code to larger Haskell programs. |
| `Haskell.pdf` | Title: Effective Haskell. Author: Rebecca Skinner. Publisher metadata: Pragmatic Bookshelf. 663 pages. PDF creation date: 2023-08-02 JST. | A practical Haskell book moving from interactive development and types into project structure, type classes, IO, local-system applications, monads, mutable references, serialization/deserialization, parser construction, effect stacks, performance, and type-level programming. | Closely matches the production-lab goal: application structure, procedural shell with functional core, IO boundaries, metrics, serialization, parsing, effect composition, efficient data handling, and type-level design for maintainable services. |
| `FP pragpub0.pdf` | Title: Functional Programming: A PragPub Anthology. Author metadata: Michael Swaine, and the PragPub writers. 263 pages. PDF creation date: 2017-07-26 JST. | A cross-language functional programming anthology covering the functional paradigm, Scala, Clojure, Elixir, Haskell, Swift, Lua, concurrency, testing, pattern matching, and type systems. Haskell-focused chapters cover functional thinking, hands-on search, the type system, and property testing native code. | Adds comparative context for why the lab uses immutability, pure functions, typed interfaces, property testing, and explicit concurrency boundaries. It is useful for explaining Haskell choices to engineers coming from other ecosystems. |

## Topic map to Haskell Production Lab

| Lab area | PDF topics to carry forward | Repo mapping |
|---|---|---|
| Servant API | Type-level API thinking, module boundaries, JSON contracts, explicit errors, application structure. | `HPS.Api`, `HPS.Handlers`, `HPS.Domain`, `hps-api`, `/lab`, future Servant OpenAPI work. |
| Service pattern | Reader-style environment passing, effect stacks, type classes as interfaces, separating behavior from concrete infrastructure. | `HPS.Service.*`, `HPS.Service.KV.Postgres`, the D1 Database Worker, `docs/SERVICE_PATTERN.md`, and future R2 adapters. |
| IO and pure core | Project/module structure, IO sequencing, procedural shell with functional core, local system programs, error handling. | `HPS.Ledger`, `HPS.StaticSite`, `HPS.Search`, `HPS.RuntimeMonitor`, `app/*` executable shells over shared library code. |
| Type classes and algebra | Eq/Ord/Show/Read, deriving, Semigroup/Monoid, Functor, Applicative, Monad, Foldable, Traversable, laws, higher-kinded types. | Domain instances, validation combinators, search scoring, renderers, service handles, future law-oriented tests. |
| Parsing and serialization | Parser combinators, monadic parsers, deserialization, heterogeneous data, Aeson-style contracts, file/archive examples. | `HPS.Ledger` journal parsing, `HPS.Search`, `HPS.Stream`, API JSON payloads, `examples/ledger.journal`, `examples/requests.http`. |
| Concurrency and STM | Mutable references, metrics state, state management, cross-language concurrency models, actors/messages as comparison points. | `HPS.Service.Queue`, `HPS.AppState`, `HPS.Service.Metrics`, `hps-worker`, `hps-websocket`, future queue/dead-letter work. |
| Testing | Conventional tests, QuickCheck/property thinking, law checks for abstractions, test data construction, model-vs-implementation comparisons. | `test/Main.hs`, ledger invariants, parser round trips, service handle behavior, API smoke tests, future property tests. |
| Deployment and operations | Package/project structure, module exports, efficient programs, local-system tooling, runtime metrics, production reliability framing. | Cabal monorepo, Docker/CI docs, `docs/PRODUCTION_CHECKLIST.md`, Cloudflare Workers/WASM blueprint, future build and release hardening. |

## Source-specific takeaways

### Haskell Programming

Use this source as the comprehensive curriculum for the lab. Its strongest
alignment is with the repository's learning path: start from lambda calculus,
expressions, functions, datatypes, lists, folds, and recursion; move into
algebraic datatypes, `Maybe`/`Either` style error modeling, projects/modules,
testing, Semigroup/Monoid, Functor, Applicative, Monad, Foldable, and
Traversable; then use Reader, State, parser combinators, monad transformers,
non-strictness, libraries, and IO to explain larger programs.

Repo follow-through:

- Turn selected topics into `hps-mmlh` practice exercises.
- Add parser-combinator exercises around the ledger journal and search CLI.
- Add law-focused tests for small algebraic abstractions used by renderers,
  validators, and service handles.
- Use the project/module chapters as review material for keeping `src/HPS/*`
  modules cohesive and export lists intentional.

### Effective Haskell

Use this source as the applied engineering companion. Its chapter progression
tracks the lab's production concerns: interactive exploration, type-guided
development, new data types, modules and exports, type classes, IO, local
system tools, monads, mutable state for metrics, serialization and parsing,
effect stacks, efficient data structures, and type-level programming.

Repo follow-through:

- Keep the app shape as a procedural shell over a functional core.
- Treat metrics and mutable runtime state as explicit service boundaries.
- Use serialization/deserialization chapters to harden API JSON contracts and
  CLI file formats.
- Use effect-stack material to evaluate whether future adapters should stay as
  simple handle records or introduce a richer application monad.
- Use efficiency chapters as a guide for stream/search optimization work.

### Functional Programming: A PragPub Anthology

Use this source for positioning and comparative design vocabulary. The
Haskell chapters reinforce cheap data modeling, pattern matching, recursion,
higher-order functions, search, the type system, interfaces/type classes, and
property testing. The non-Haskell chapters are useful when comparing Haskell's
approach to immutability, concurrency, pattern matching, testing, and function
composition with Scala, Clojure, Elixir, Swift, and Lua.

Repo follow-through:

- Use the anthology's comparative lens in docs and interview notes to explain
  why this lab favors immutable state transitions and typed interfaces.
- Compare STM queues and WebSocket broadcast handling with actor/message
  models when documenting concurrency tradeoffs.
- Use the Haskell search and type-system topics to enrich `hps-search` and
  `docs/HASKELL_STRENGTHS.md`.

## Suggested PDF-informed backlog

- Add property tests for ledger balance invariants, parser round trips, and
  service handle laws.
- Expand `hps-mmlh` with exercises on type errors, parser combinators, and
  IO boundary refactoring.
- Add a small serialization/deserialization example that reuses the service
  pattern and validates structured errors.
- Document concurrency choices for the STM worker queue and WebSocket server,
  including when a future external queue would replace in-memory STM.
- Revisit `HPS.Api` and `HPS.Domain` after the OpenAPI phase to ensure the
  public API types remain intentional, versionable, and easy to test.
