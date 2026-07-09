module Main (main) where

import qualified Data.Text as T
import HPS.Ledger
import HPS.StaticSite
import HPS.Util

main :: IO ()
main = do
  assert "slugify basic" (slugify "Hello, Haskell Service!" == "hello-haskell-service")
  assert "stable slug is total" (stableSlug "Typed calculator-2" == "typed-calculator-2-33694dea")
  assert "markdown h1" ("<h1>Hello</h1>" `T.isInfixOf` markdownToHtml "# Hello")
  case parseLedgerLine "sale; cash:100; revenue:-100" of
    Right _ -> pure ()
    Left err -> fail ("ledger parse failed: " <> show err)
  putStrLn "hps-test passed"

assert :: String -> Bool -> IO ()
assert name ok = if ok then pure () else fail name
