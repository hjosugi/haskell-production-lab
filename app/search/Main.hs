module Main (main) where

import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BL8
import qualified Data.Text as T
import HPS.Search (searchFiles)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    query:files -> searchFiles (T.pack query) files >>= BL8.putStrLn . encode
    _ -> putStrLn "usage: hps-search <query> <files...>"
