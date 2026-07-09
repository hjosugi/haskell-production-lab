module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (async)
import Control.Concurrent.STM
import Control.Monad (forM_)
import qualified Data.Map.Strict as Map
import qualified Data.Text.IO as TIO
import Data.Time (getCurrentTime)
import HPS.AppState
import HPS.Domain
import HPS.Handlers (runWorkerLoop)
import HPS.Util (tshow)

main :: IO ()
main = do
  state <- newAppState
  _ <- async (runWorkerLoop state)
  forM_ [1 :: Int .. 10] \n -> enqueueDemo state n
  threadDelay 4000000
  jobs <- atomically (readTVar (appJobs state))
  TIO.putStrLn ("processed jobs: " <> tshow (Map.elems jobs))

enqueueDemo :: AppState -> Int -> IO ()
enqueueDemo state n = do
  now <- getCurrentTime
  let job = Job
        { jobId = "demo-" <> tshow n
        , jobKind = if n == 7 then "fail" else "demo"
        , jobBody = "background job payload"
        , jobStatus = JobQueued
        , jobAttempts = 0
        , jobCreatedAt = now
        , jobUpdatedAt = now
        }
  atomically do
    modifyTVar' (appJobs state) (Map.insert (jobId job) job)
    writeTQueue (appQueue state) job
