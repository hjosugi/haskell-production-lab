module Main (main) where

import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BL8
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import HPS.Learning
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["list"] -> mapM_ (TIO.putStrLn . renderExercise) exercises
    ["show", ident] -> maybe notFound (TIO.putStrLn . renderExercise) (findExercise (T.pack ident))
    ["check", ident, file] -> do
      submission <- TIO.readFile file
      case findExercise (T.pack ident) of
        Nothing -> notFound
        Just ex -> BL8.putStrLn (encode (evaluateSubmission ex submission))
    _ -> TIO.putStrLn "usage: hps-mmlh list | show <id> | check <id> <file>"
  where
    notFound = TIO.putStrLn "exercise not found"
