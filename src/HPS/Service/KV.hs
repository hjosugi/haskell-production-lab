module HPS.Service.KV
  ( Handle(..)
  , newMemoryHandle
  , newJsonFileHandle
  ) where

import Control.Concurrent.MVar (modifyMVar, newMVar, withMVar)
import Control.Concurrent.STM (TVar, atomically, newTVarIO, readTVar, modifyTVar')
import Data.Aeson (FromJSON, ToJSON, decodeFileStrict, encodeFile)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import System.Directory (createDirectoryIfMissing, doesFileExist)
import System.FilePath (takeDirectory)

-- | A small Service/Handle interface for key-value storage.
data Handle k v = Handle
  { kvGet :: k -> IO (Maybe v)
  , kvPut :: k -> v -> IO ()
  , kvDelete :: k -> IO ()
  , kvList :: IO [(k, v)]
  }

newMemoryHandle :: Ord k => IO (Handle k v)
newMemoryHandle = do
  ref <- newTVarIO Map.empty
  pure Handle
    { kvGet = \k -> Map.lookup k <$> readTVarIO ref
    , kvPut = \k v -> atomically (modifyTVar' ref (Map.insert k v))
    , kvDelete = \k -> atomically (modifyTVar' ref (Map.delete k))
    , kvList = Map.toList <$> readTVarIO ref
    }

readTVarIO :: TVar a -> IO a
readTVarIO = atomically . readTVar

newJsonFileHandle :: forall v. (FromJSON v, ToJSON v) => FilePath -> IO (Handle Text v)
newJsonFileHandle path = do
  createDirectoryIfMissing True (takeDirectory path)
  exists <- doesFileExist path
  initial <- if exists
    then maybe Map.empty id <$> decodeFileStrict path
    else pure Map.empty
  lock <- newMVar initial
  let save :: Map Text v -> IO ()
      save = encodeFile path
      modifyStore :: (Map Text v -> (Map Text v, a)) -> IO a
      modifyStore f = modifyMVar lock \current -> do
        let (next, result) = f current
        save next
        pure (next, result)
  pure Handle
    { kvGet = \k -> Map.lookup k <$> withMVar lock pure
    , kvPut = \k v -> modifyStore \m -> (Map.insert k v m, ())
    , kvDelete = \k -> modifyStore \m -> (Map.delete k m, ())
    , kvList = Map.toList <$> withMVar lock pure
    }
