module HPS.WebSocket
  ( runChatServer
  ) where

import Control.Concurrent (forkIO)
import Control.Concurrent.STM
import Control.Exception (finally)
import Control.Monad (forever, void)
import Data.Text (Text)
import qualified Data.Text as T
import Network.HTTP.Types (status200)
import Network.Wai (Application, responseLBS)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Handler.WebSockets (websocketsOr)
import qualified Network.WebSockets as WS

type Client = (Text, WS.Connection)

runChatServer :: Int -> IO ()
runChatServer port = do
  clients <- newTVarIO []
  run port (application clients)

application :: TVar [Client] -> Application
application clients = websocketsOr WS.defaultConnectionOptions (chatApp clients) fallback
  where
    fallback _ respond = respond $ responseLBS status200 [("content-type", "text/plain")] "websocket endpoint is /"

chatApp :: TVar [Client] -> WS.ServerApp
chatApp clients pending = do
  conn <- WS.acceptRequest pending
  WS.withPingThread conn 30 (pure ()) do
    WS.sendTextData conn ("send your name" :: Text)
    name <- WS.receiveData conn
    atomically (modifyTVar' clients ((name, conn) :))
    broadcast clients (name <> " joined")
    finally (loop name conn) do
      atomically (modifyTVar' clients (filter ((/= name) . fst)))
      broadcast clients (name <> " left")
  where
    loop name conn = forever do
      msg <- WS.receiveData conn
      broadcast clients (name <> ": " <> (msg :: Text))

broadcast :: TVar [Client] -> Text -> IO ()
broadcast clients message = do
  snapshot <- atomically (readTVar clients)
  void $ forkIO $ mapM_ (send message) snapshot
  where
    send payload (_, conn) = WS.sendTextData conn (T.strip payload)
