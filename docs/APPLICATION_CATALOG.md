# Application catalog

## Included executable apps

| Executable | Category | What it demonstrates |
|---|---|---|
| `hps-api` | Servant REST service + Lab dashboard | `/lab` project management, learning logs, release prep, typed API, health, metrics, articles, URL shortener, ledger, jobs, search, event log |
| `hps-scotty-shortener` | Scotty HTTP service | lightweight Sinatra-style URL shortener |
| `hps-url-shortener` | CLI + JSON store | file-backed local service boundary |
| `hps-ledger` | fintech CLI | double-entry accounting validation |
| `hps-worker` | background jobs | STM queue, retries, worker lifecycle |
| `hps-event-sourcing` | event sourcing | append-only events and projections |
| `hps-stream` | analytics CLI | streaming log processing |
| `hps-search` | parser/search | simple text search and ranking |
| `hps-static-site` | static site generator | pure renderer + IO shell |
| `hps-mmlh` | learning tool | mistake-driven exercises inspired by mmlh |
| `hps-monitor` | runtime monitoring | threshold-based alert generation |
| `hps-websocket` | realtime server | WebSocket broadcast server |
| `hps-tui-kanban` | terminal app | interactive stateful CLI/TUI |

## Blueprints

| Blueprint | Purpose |
|---|---|
| `cloudflare/humblr-workers` | D1-backed Workers blog architecture, split into Router / Database / Storage / Images / SSR with Service Bindings |
| `blueprints/yesod-blog-workshop` | Yesod/GREE-style blog workshop skeleton |
| `blueprints/postgres-adapter` | Implemented PostgreSQL KV adapter and future ledger repository direction |

## Real-world inspiration map

| Real-world pattern | Implemented practice |
|---|---|
| Typed APIs with Servant | `HPS.Api`, `HPS.Handlers`, `hps-api` |
| Haskell production lab | `HPS.Lab`, `HPS.Lab.Html`, `/lab` |
| Sinatra-style small service | `hps-scotty-shortener` |
| Yesod blog workshop | `blueprints/yesod-blog-workshop` |
| mmlh-style mistake learning | `HPS.Learning`, `hps-mmlh` |
| Service/Handle pattern | `HPS.Service.*` |
| Edge/WASM blog engine | `cloudflare/humblr-workers` |
| finance / reliable accounting | `HPS.Ledger`, `hps-ledger` |
| runtime verification / monitoring | `HPS.RuntimeMonitor`, `hps-monitor` |
| awesome-haskell style tools | static site, search, monitor, CLI, worker |
