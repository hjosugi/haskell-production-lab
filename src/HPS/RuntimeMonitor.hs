module HPS.RuntimeMonitor
  ( evaluateThreshold
  , evaluateMany
  ) where

import Data.Text (Text)
import HPS.Domain

evaluateThreshold :: Text -> Double -> MonitorSample -> Maybe MonitorAlert
evaluateThreshold name threshold sample
  | sampleName sample == name && sampleValue sample > threshold =
      Just MonitorAlert
        { alertName = name
        , alertValue = sampleValue sample
        , alertThreshold = threshold
        , alertTimestamp = sampleTimestamp sample
        }
  | otherwise = Nothing

evaluateMany :: Text -> Double -> [MonitorSample] -> [MonitorAlert]
evaluateMany name threshold = foldMap (maybe [] pure . evaluateThreshold name threshold)
