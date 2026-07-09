# Yesod Blog Workshop Blueprint

This blueprint mirrors the GREE-style internal tutorial idea: start with templates, add forms, then add Persistent, Aeson, and auth.

## Suggested steps

1. Single-file Yesod app
2. Blog route and Hamlet template
3. Form submission
4. Persistent models
5. JSON endpoints through Aeson
6. Auth skeleton
7. Deployment checklist

The code below is intentionally separate from the root Cabal build because Yesod project scaffolding usually owns its own package and config.
