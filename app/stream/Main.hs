module Main (main) where

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import HPS.Stream

main :: IO ()
main = do
  input <- TIO.getContents
  TIO.putStrLn (renderStatusCounts (countStatuses (T.lines input)))
