module HPS.AppState
  ( AppState(..)
  , newAppState
  ) where

import Control.Concurrent.STM (TQueue, TVar, newTQueueIO, newTVarIO)
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import Data.Time (getCurrentTime)
import HPS.Domain
import qualified HPS.Service.EventStore as EventStore
import qualified HPS.Service.Logger as Logger
import qualified HPS.Service.Logger.Console as ConsoleLogger
import qualified HPS.Service.Metrics as Metrics

-- | In production, replace these in-memory fields with Postgres, Redis, D1/R2, or Kafka handles.
data AppState = AppState
  { appArticles :: TVar (Map Text Article)
  , appUrls :: TVar (Map Text UrlMapping)
  , appLedger :: TVar [LedgerTransaction]
  , appJobs :: TVar (Map Text Job)
  , appProjects :: TVar (Map Text LabProject)
  , appLearningLogs :: TVar [LearningLog]
  , appReleases :: TVar [LabRelease]
  , appQueue :: TQueue Job
  , appEvents :: EventStore.Handle DomainEvent
  , appMetrics :: Metrics.Handle
  , appLogger :: Logger.Handle
  }

newAppState :: IO AppState
newAppState = do
  now <- getCurrentTime
  let starterProject =
        LabProject
          { projectId = "haskell-production-lab"
          , projectName = "Haskell Production Lab"
          , projectSummary = "A Haskell-built workspace for apps, learning logs, and release preparation."
          , projectRepository = Nothing
          , projectDemoUrl = Just "/lab"
          , projectTags = ["servant", "lucid", "stm"]
          , projectStage = ProjectBuilding
          , projectCreatedAt = now
          , projectUpdatedAt = now
          }
      starterLearning =
        LearningLog
          { learningId = "learn-servant-lucid"
          , learningTopic = "Servant + Lucid dashboard"
          , learningNotes = "Keep pure domain logic apart from HTTP handlers while still serving a usable site."
          , learningLinks = []
          , learningOutcome = LearningPracticed
          , learningCreatedAt = now
          }
  appArticles <- newTVarIO Map.empty
  appUrls <- newTVarIO Map.empty
  appLedger <- newTVarIO []
  appJobs <- newTVarIO Map.empty
  appProjects <- newTVarIO (Map.fromList [(projectId starterProject, starterProject)])
  appLearningLogs <- newTVarIO [starterLearning]
  appReleases <- newTVarIO []
  appQueue <- newTQueueIO
  appEvents <- EventStore.newMemoryHandle
  appMetrics <- Metrics.newMemoryHandle
  appLogger <- ConsoleLogger.newHandle
  pure AppState{..}
