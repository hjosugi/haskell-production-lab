module Main (main) where

import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BL8
import HPS.Domain
import qualified HPS.Service.EventStore as EventStore

main :: IO ()
main = do
  store <- EventStore.newMemoryHandle
  EventStore.appendEvent store (ArticlePublished "hello-haskell")
  EventStore.appendEvent store (UrlShortened "hps" "https://www.haskell.org")
  EventStore.appendEvent store (LedgerAccepted "txn-1")
  events <- EventStore.loadEvents store
  BL8.putStrLn (encode events)
