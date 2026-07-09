module HPS.Service.Metrics
  ( Handle(..)
  , newMemoryHandle
  , renderPrometheus
  ) where

import Control.Concurrent.STM (atomically, modifyTVar', newTVarIO, readTVar)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import HPS.Util (tshow)

data Handle = Handle
  { increment :: Text -> IO ()
  , addBy :: Text -> Int -> IO ()
  , snapshot :: IO [(Text, Int)]
  }

newMemoryHandle :: IO Handle
newMemoryHandle = do
  ref <- newTVarIO Map.empty
  let addBy name delta = atomically (modifyTVar' ref (Map.insertWith (+) name delta))
      increment name = addBy name 1
      snapshot = Map.toList <$> atomically (readTVar ref)
  pure Handle{increment, addBy, snapshot}

renderPrometheus :: [(Text, Int)] -> Text
renderPrometheus = T.unlines . map render
  where
    render (name, value) = T.concat [sanitize name, " ", tshow value]
    sanitize = T.map \c -> if c == '-' then '_' else c
