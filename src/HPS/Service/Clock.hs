module HPS.Service.Clock
  ( Handle(..)
  , systemClock
  , fixedClock
  ) where

import Data.Time (UTCTime, getCurrentTime)

newtype Handle = Handle
  { getTime :: IO UTCTime
  }

systemClock :: Handle
systemClock = Handle{getTime = getCurrentTime}

fixedClock :: UTCTime -> Handle
fixedClock t = Handle{getTime = pure t}
