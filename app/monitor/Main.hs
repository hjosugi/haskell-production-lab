module Main (main) where

import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BL8
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Time (UTCTime, getCurrentTime)
import HPS.Domain
import HPS.RuntimeMonitor
import System.Environment (getArgs)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [metricName, rawThreshold] -> do
      threshold <- pure (read rawThreshold)
      input <- TIO.getContents
      now <- getCurrentTime
      let samples = mapMaybe (parseSample now) (T.lines input)
      BL8.putStrLn (encode (evaluateMany (T.pack metricName) threshold samples))
    _ -> putStrLn "usage: hps-monitor <metric-name> <threshold> < samples.txt"

mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe f = foldr (maybe id (:) . f) []

parseSample :: UTCTime -> T.Text -> Maybe MonitorSample
parseSample now line =
  case T.words line of
    [name, rawValue] ->
      case reads (T.unpack rawValue) of
        [(value, "")] -> Just MonitorSample{sampleName = name, sampleValue = value, sampleTimestamp = now}
        _ -> Nothing
    _ -> Nothing
