module HPS.Service.Queue
  ( Handle(..)
  , newSTMHandle
  ) where

import Control.Concurrent.STM

-- | Simple durable-queue boundary. Swap implementation for Redis, SQS, or Cloudflare Queues.
data Handle a = Handle
  { enqueue :: a -> IO ()
  , dequeue :: IO a
  , tryDequeue :: IO (Maybe a)
  , queueSize :: IO Int
  }

newSTMHandle :: IO (Handle a)
newSTMHandle = do
  queue <- newTQueueIO
  sizeRef <- newTVarIO 0
  let enqueue item = atomically do
        writeTQueue queue item
        modifyTVar' sizeRef (+ 1)
      dequeue = atomically do
        item <- readTQueue queue
        modifyTVar' sizeRef (max 0 . subtract 1)
        pure item
      tryDequeue = atomically do
        item <- tryReadTQueue queue
        case item of
          Nothing -> pure Nothing
          Just _ -> modifyTVar' sizeRef (max 0 . subtract 1) *> pure item
      queueSize = atomically (readTVar sizeRef)
  pure Handle{enqueue, dequeue, tryDequeue, queueSize}
