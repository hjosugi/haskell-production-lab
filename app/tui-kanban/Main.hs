module Main (main) where

import Control.Concurrent.STM
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Time (getCurrentTime)
import HPS.Domain
import HPS.Util (tshow)

main :: IO ()
main = do
  cards <- newTVarIO Map.empty
  TIO.putStrLn "commands: add <title> | move <id> <status> | list | quit"
  loop cards

loop :: TVar (Map.Map T.Text KanbanCard) -> IO ()
loop cards = do
  line <- TIO.getLine
  case T.words line of
    ["add", title] -> do
      now <- getCurrentTime
      existing <- atomically (readTVar cards)
      let ident = "card-" <> tshow (Map.size existing + 1)
          card = KanbanCard{cardId = ident, cardTitle = title, cardStatus = "todo", cardCreatedAt = now}
      atomically (modifyTVar' cards (Map.insert ident card))
      TIO.putStrLn ("added " <> ident)
      loop cards
    ["move", ident, status] -> do
      atomically (modifyTVar' cards (Map.adjust (\c -> c{cardStatus = status}) ident))
      TIO.putStrLn "moved"
      loop cards
    ["list"] -> do
      snapshot <- atomically (readTVar cards)
      mapM_ (TIO.putStrLn . tshow) (Map.elems snapshot)
      loop cards
    ["quit"] -> TIO.putStrLn "bye"
    _ -> TIO.putStrLn "unknown command" >> loop cards
