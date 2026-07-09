# Service / Handle Pattern

## Rule

Business logic should call small records of functions, not concrete infrastructure.

Example:

```haskell
data Handle k v = Handle
  { kvGet :: k -> IO (Maybe v)
  , kvPut :: k -> v -> IO ()
  , kvDelete :: k -> IO ()
  , kvList :: IO [(k, v)]
  }
```

Then the app can use:

- `newMemoryHandle` for tests
- `newJsonFileHandle` for local demos
- future `newPostgresHandle` for production
- future `newD1Handle` for Cloudflare Workers

## Why this is useful in interviews

A concise explanation:

> I keep domain logic pure. IO is hidden behind small Handle records. This makes tests fast, lets us swap storage or queues, and keeps the API layer thin.

## Where it appears

- `HPS.Service.Logger`
- `HPS.Service.KV`
- `HPS.Service.Queue`
- `HPS.Service.EventStore`
- `HPS.Service.Metrics`
