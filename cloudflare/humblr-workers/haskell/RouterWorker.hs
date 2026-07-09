module RouterWorker where

import Data.Text (Text)
import qualified Data.Text as T

-- This file documents the future Haskell/WASM boundary.
-- The JavaScript Worker calls exported functions from the compiled wasm module.

route :: Text -> Text
route path
  | path == "/api/health" = "database:/api/health"
  | "/api/articles" `T.isPrefixOf` path = "database:" <> path
  | "/uploads" `T.isPrefixOf` path = "storage:" <> path
  | "/images" `T.isPrefixOf` path = "images:" <> path
  | otherwise = "ssr:" <> path
