module Main (main) where

import HPS.Util (currentServicePort)
import HPS.WebSocket (runChatServer)

main :: IO ()
main = do
  port <- currentServicePort 8081
  runChatServer port
