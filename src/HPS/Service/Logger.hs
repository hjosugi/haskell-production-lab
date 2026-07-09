module HPS.Service.Logger
  ( Priority(..)
  , Handle(..)
  , logDebug
  , logInfo
  , logWarn
  , logError
  ) where

import Data.Text (Text)

data Priority = Debug | Info | Warn | Error
  deriving stock (Eq, Ord, Show)

newtype Handle = Handle
  { writeLog :: Priority -> Text -> IO ()
  }

logDebug, logInfo, logWarn, logError :: Handle -> Text -> IO ()
logDebug h = writeLog h Debug
logInfo h = writeLog h Info
logWarn h = writeLog h Warn
logError h = writeLog h Error
