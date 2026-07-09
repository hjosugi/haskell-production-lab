module Main (main) where

import HPS.StaticSite (buildSite)
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [inputDir, outputDir] -> buildSite inputDir outputDir
    _ -> putStrLn "usage: hps-static-site <input-dir> <output-dir>"
