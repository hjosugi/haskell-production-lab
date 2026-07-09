module Main (main) where

import Data.Either (partitionEithers)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Time (UTCTime)
import HPS.Ledger
import HPS.Util (tshow)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [file] -> runFile file
    _ -> TIO.putStrLn "usage: hps-ledger <journal-file>"

runFile :: FilePath -> IO ()
runFile file = do
  rows <- T.lines <$> TIO.readFile file
  let parsed = zipWith parseOne [1 :: Int ..] rows
      (errors, txs) = partitionEithers parsed
  mapM_ (TIO.putStrLn . ("error: " <>)) errors
  TIO.putStrLn (renderBalances (balances txs))
  where
    parseOne n raw = do
      seed <- parseLedgerLine raw
      newTransaction nowish ("txn-" <> tshow n) seed
    nowish = unsafeFixedTime

-- The journal format is deterministic, so the sample CLI uses a stable timestamp.
unsafeFixedTime :: UTCTime
unsafeFixedTime = read "2026-01-01 00:00:00 UTC"
