module HPS.Service.EventStore
  ( Handle(..)
  , newMemoryHandle
  ) where

import Control.Concurrent.STM (atomically, modifyTVar', newTVarIO, readTVar, writeTVar)

-- | Append-only event store. Replace this with Postgres, Kafka, or Cloudflare D1.
data Handle event = Handle
  { appendEvent :: event -> IO ()
  , loadEvents :: IO [event]
  , clearEvents :: IO ()
  }

newMemoryHandle :: IO (Handle event)
newMemoryHandle = do
  ref <- newTVarIO []
  pure Handle
    { appendEvent = \event -> atomically (modifyTVar' ref (<> [event]))
    , loadEvents = atomically (readTVar ref)
    , clearEvents = atomically (writeTVar ref [])
    }
