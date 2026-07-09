module HPS.Handlers
  ( server
  , app
  , runWorkerLoop
  ) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.STM
import Control.Monad (forever, when)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (encode)
import Data.List (sortOn)
import qualified Data.Map.Strict as Map
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (getCurrentTime)
import HPS.Api
import HPS.AppState
import HPS.Domain
import HPS.Lab
import HPS.Lab.Html (renderLabDashboard)
import HPS.Ledger
import HPS.Search (searchText)
import qualified HPS.Service.EventStore as EventStore
import qualified HPS.Service.Logger as Logger
import qualified HPS.Service.Metrics as Metrics
import HPS.Util (stableSlug, tshow)
import HPS.Validation
import Servant

server :: AppState -> Server API
server state =
       healthH
  :<|> metricsH
  :<|> labDashboardH
  :<|> labStatsH
  :<|> listProjectsH
  :<|> createProjectH
  :<|> changeProjectStageH
  :<|> listLearningH
  :<|> createLearningH
  :<|> listReleasesH
  :<|> createReleaseH
  :<|> listArticlesH
  :<|> createArticleH
  :<|> createUrlH
  :<|> getUrlH
  :<|> createLedgerH
  :<|> balancesH
  :<|> enqueueJobH
  :<|> listJobsH
  :<|> listEventsH
  :<|> searchH
  where
    healthH = liftIO do
      now <- getCurrentTime
      pure Health
        { healthService = "haskell-production-lab"
        , healthStatus = "ok"
        , healthVersion = "0.1.0"
        , healthCheckedAt = now
        }

    metricsH = liftIO do
      Metrics.renderPrometheus <$> Metrics.snapshot (appMetrics state)

    labDashboardH = liftIO do
      projects <- readProjects
      learning <- readLearning
      releases <- readReleases
      pure (renderLabDashboard (sortProjects projects) (sortLearningLogs learning) (sortReleases releases))

    labStatsH = liftIO do
      projects <- readProjects
      learning <- readLearning
      releases <- readReleases
      pure (labStats projects learning releases)

    listProjectsH = liftIO do
      sortProjects <$> readProjects

    createProjectH seed = do
      requireValid validateProjectSeed seed
      liftIO do
        now <- getCurrentTime
        projects <- atomically (readTVar (appProjects state))
        let project = makeProject now (Map.size projects + 1) seed
        atomically (modifyTVar' (appProjects state) (Map.insert (projectId project) project))
        EventStore.appendEvent (appEvents state) (ProjectCreated (projectId project))
        Metrics.increment (appMetrics state) "lab_projects_created_total"
        Logger.logInfo (appLogger state) ("lab.project.created id=" <> projectId project)
        pure project

    changeProjectStageH ident ProjectStagePatch{patchStage} = do
      updated <- liftIO do
        now <- getCurrentTime
        atomically do
          projects <- readTVar (appProjects state)
          case Map.lookup ident projects of
            Nothing -> pure Nothing
            Just project -> do
              let changed = updateProjectStage now patchStage project
              writeTVar (appProjects state) (Map.insert ident changed projects)
              pure (Just changed)
      case updated of
        Nothing -> throwError err404{errBody = "project not found"}
        Just project -> do
          liftIO do
            EventStore.appendEvent (appEvents state) (ProjectStageChanged ident patchStage)
            Metrics.increment (appMetrics state) "lab_project_stage_changes_total"
          pure project

    listLearningH = liftIO do
      sortLearningLogs <$> readLearning

    createLearningH seed = do
      requireValid validateLearningLogSeed seed
      liftIO do
        now <- getCurrentTime
        learning <- atomically (readTVar (appLearningLogs state))
        let entry = makeLearningLog now (length learning + 1) seed
        atomically (modifyTVar' (appLearningLogs state) (<> [entry]))
        EventStore.appendEvent (appEvents state) (LearningLogged (learningId entry))
        Metrics.increment (appMetrics state) "lab_learning_logs_total"
        pure entry

    listReleasesH = liftIO do
      sortReleases <$> readReleases

    createReleaseH seed = do
      requireValid validateReleaseSeed seed
      projects <- liftIO (atomically (readTVar (appProjects state)))
      when (Map.notMember (releaseProjectIdSeed seed) projects) do
        throwError err404{errBody = "release project not found"}
      liftIO do
        now <- getCurrentTime
        releases <- atomically (readTVar (appReleases state))
        let release = makeRelease now (length releases + 1) seed
        atomically (modifyTVar' (appReleases state) (<> [release]))
        EventStore.appendEvent (appEvents state) (ReleasePrepared (releaseProjectId release) (releaseVersion release))
        Metrics.increment (appMetrics state) "lab_releases_prepared_total"
        pure release

    listArticlesH = liftIO do
      atomically (Map.elems <$> readTVar (appArticles state))

    createArticleH seed = do
      requireValid validateArticleSeed seed
      liftIO do
        now <- getCurrentTime
        let slug = maybe (stableSlug (seedTitle seed)) stableSlug (seedSlug seed)
            article = Article
              { articleSlug = slug
              , articleTitle = seedTitle seed
              , articleBody = seedBody seed
              , articleTags = seedTags seed
              , articleCreatedAt = now
              , articleUpdatedAt = now
              }
        atomically (modifyTVar' (appArticles state) (Map.insert slug article))
        EventStore.appendEvent (appEvents state) (ArticlePublished slug)
        Metrics.increment (appMetrics state) "articles_created_total"
        Logger.logInfo (appLogger state) ("article.created slug=" <> slug)
        pure article

    createUrlH request = do
      requireValid validateUrlRequest request
      liftIO do
        now <- getCurrentTime
        let slug = maybe (stableSlug (requestUrl request)) stableSlug (requestCustomSlug request)
            mapping = UrlMapping
              { urlSlug = slug
              , urlTarget = requestUrl request
              , urlClicks = 0
              , urlCreatedAt = now
              }
        atomically (modifyTVar' (appUrls state) (Map.insert slug mapping))
        EventStore.appendEvent (appEvents state) (UrlShortened slug (requestUrl request))
        Metrics.increment (appMetrics state) "urls_created_total"
        pure mapping

    getUrlH slug = do
      found <- liftIO $ atomically do
        urls <- readTVar (appUrls state)
        case Map.lookup slug urls of
          Nothing -> pure Nothing
          Just mapping -> do
            let clicked = mapping{urlClicks = urlClicks mapping + 1}
            writeTVar (appUrls state) (Map.insert slug clicked urls)
            pure (Just clicked)
      maybe (throwError err404{errBody = "slug not found"}) pure found

    createLedgerH seed = do
      requireValid validateLedgerSeed seed
      liftIO do
        now <- getCurrentTime
        existing <- atomically (readTVar (appLedger state))
        let ident = "txn-" <> tshow (length existing + 1)
        case newTransaction now ident seed of
          Left msg -> fail (T.unpack msg)
          Right tx -> do
            atomically (modifyTVar' (appLedger state) (<> [tx]))
            EventStore.appendEvent (appEvents state) (LedgerAccepted ident)
            Metrics.increment (appMetrics state) "ledger_transactions_total"
            pure tx

    balancesH = liftIO do
      txs <- atomically (readTVar (appLedger state))
      pure (sortOn balanceAccount (balances txs))

    enqueueJobH payload = do
      requireValid validateJobPayload payload
      liftIO do
        now <- getCurrentTime
        jobs <- atomically (readTVar (appJobs state))
        let ident = "job-" <> tshow (Map.size jobs + 1)
            job = Job
              { jobId = ident
              , jobKind = payloadKind payload
              , jobBody = payloadBody payload
              , jobStatus = JobQueued
              , jobAttempts = 0
              , jobCreatedAt = now
              , jobUpdatedAt = now
              }
        atomically do
          modifyTVar' (appJobs state) (Map.insert ident job)
          writeTQueue (appQueue state) job
        Metrics.increment (appMetrics state) "jobs_enqueued_total"
        pure job

    listJobsH = liftIO do
      Map.elems <$> atomically (readTVar (appJobs state))

    listEventsH = liftIO do
      EventStore.loadEvents (appEvents state)

    searchH Nothing = pure []
    searchH (Just q) = liftIO do
      articles <- Map.elems <$> atomically (readTVar (appArticles state))
      projects <- Map.elems <$> atomically (readTVar (appProjects state))
      let toHit article = searchText (T.unpack (articleSlug article)) q (articleBody article)
          toProjectHit project =
            searchText
              (T.unpack (projectId project))
              q
              (projectName project <> "\n" <> projectSummary project <> "\n" <> T.unwords (projectTags project))
      pure (foldMap maybeToList (map toHit articles) <> foldMap maybeToList (map toProjectHit projects))
    readProjects =
      Map.elems <$> atomically (readTVar (appProjects state))
    readLearning =
      atomically (readTVar (appLearningLogs state))
    readReleases =
      atomically (readTVar (appReleases state))

maybeToList :: Maybe a -> [a]
maybeToList Nothing = []
maybeToList (Just x) = [x]

requireValid :: (a -> Either Text ()) -> a -> Handler ()
requireValid validate value =
  case validate value of
    Right () -> pure ()
    Left msg -> throwError err400{errBody = encode msg}

app :: AppState -> Application
app state = serve apiProxy (server state)

runWorkerLoop :: AppState -> IO ()
runWorkerLoop state = forever do
  job <- atomically (readTQueue (appQueue state))
  now <- getCurrentTime
  atomically $ modifyTVar' (appJobs state) (Map.adjust (mark JobRunning now) (jobId job))
  Logger.logInfo (appLogger state) ("job.started id=" <> jobId job)
  threadDelay 300000
  finishedAt <- getCurrentTime
  let finalStatus = if jobKind job == "fail" then JobFailed "simulated failure" else JobSucceeded
  atomically $ modifyTVar' (appJobs state) (Map.adjust (mark finalStatus finishedAt) (jobId job))
  when (finalStatus == JobSucceeded) do
    EventStore.appendEvent (appEvents state) (JobCompleted (jobId job))
    Metrics.increment (appMetrics state) "jobs_succeeded_total"
  where
    mark status now old = old
      { jobStatus = status
      , jobAttempts = jobAttempts old + 1
      , jobUpdatedAt = now
      }
