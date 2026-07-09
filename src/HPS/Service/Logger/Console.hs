module HPS.Service.Logger.Console
  ( newHandle
  ) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Time (getCurrentTime)
import HPS.Service.Logger

newHandle :: IO Handle
newHandle = pure Handle{writeLog = write}
  where
    write :: Priority -> Text -> IO ()
    write priority message = do
      now <- getCurrentTime
      TIO.putStrLn $ T.concat
        [ "ts=", T.pack (show now)
        , " level=", T.pack (show priority)
        , " msg=\"", message, "\""
        ]
