module HPS.Stream
  ( countStatuses
  , renderStatusCounts
  ) where

import Data.List (foldl')
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import HPS.Util (tshow)

-- | Parse log lines shaped like: "method path status latencyMs".
countStatuses :: [Text] -> Map Text Int
countStatuses = foldl' step Map.empty
  where
    step acc line =
      case T.words line of
        (_method:_path:status:_) -> Map.insertWith (+) status 1 acc
        _ -> Map.insertWith (+) "malformed" 1 acc

renderStatusCounts :: Map Text Int -> Text
renderStatusCounts counts = T.unlines ("status,count" : map render (Map.toList counts))
  where
    render (status, count) = status <> "," <> tshow count
