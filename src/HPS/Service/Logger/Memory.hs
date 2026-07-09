module HPS.Service.Logger.Memory
  ( newHandle
  ) where

import Data.IORef (atomicModifyIORef', newIORef, readIORef)
import Data.Text (Text)
import HPS.Service.Logger

newHandle :: IO (Handle, IO [(Priority, Text)])
newHandle = do
  ref <- newIORef []
  let writeLog priority message = atomicModifyIORef' ref \xs -> ((priority, message) : xs, ())
      snapshot = reverse <$> readIORef ref
  pure (Handle{writeLog}, snapshot)
