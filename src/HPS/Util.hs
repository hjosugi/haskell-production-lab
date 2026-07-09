module HPS.Util
  ( tshow
  , slugify
  , stableSlug
  , splitWords
  , atomicModifyTVarIO
  , readPort
  , currentServicePort
  ) where

import Control.Concurrent.STM (TVar, atomically, modifyTVar')
import Data.Char (isAlphaNum, isSpace, toLower)
import Data.Text (Text)
import qualified Data.Text as T
import Numeric (showHex)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)

-- | Show a value as strict Text.
tshow :: Show a => a -> Text
tshow = T.pack . show

slugify :: Text -> Text
slugify = cleanup . T.map normalize
  where
    normalize c
      | isAlphaNum c = toLower c
      | isSpace c = '-'
      | c == '-' = '-'
      | otherwise = '-'
    cleanup = T.intercalate "-" . filter (not . T.null) . T.splitOn "-"

stableSlug :: Text -> Text
stableSlug input = base <> "-" <> T.pack (showHex (hashText input) "")
  where
    base = T.take 36 (slugify input)

hashText :: Text -> Integer
hashText = T.foldl' step 5381
  where
    step acc c = (acc * 33 + toInteger (fromEnum c)) `mod` 0xffffffff

splitWords :: Text -> [Text]
splitWords = filter (not . T.null) . T.words . T.toLower

atomicModifyTVarIO :: TVar a -> (a -> a) -> IO ()
atomicModifyTVarIO ref f = atomically (modifyTVar' ref f)

readPort :: String -> Maybe Int
readPort raw = do
  n <- readMaybe raw
  if n > 0 && n < 65536 then pure n else Nothing

currentServicePort :: Int -> IO Int
currentServicePort defaultPort = do
  envPort <- lookupEnv "PORT"
  pure (maybe defaultPort (maybe defaultPort id . readPort) envPort)
