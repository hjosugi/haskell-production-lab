module Main (main) where

import Control.Concurrent.Async (async)
import HPS.AppState (newAppState)
import HPS.Handlers (app, runWorkerLoop)
import HPS.Util (currentServicePort, tshow)
import Network.Wai.Handler.Warp (run)
import qualified Data.Text.IO as TIO

main :: IO ()
main = do
  port <- currentServicePort 8080
  state <- newAppState
  _ <- async (runWorkerLoop state)
  TIO.putStrLn ("hps-api listening on port " <> tshow port)
  run port (app state)
