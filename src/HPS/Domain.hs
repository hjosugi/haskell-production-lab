module HPS.Domain
  ( Health(..)
  , ArticleSeed(..)
  , Article(..)
  , UrlRequest(..)
  , UrlMapping(..)
  , LedgerPosting(..)
  , LedgerSeed(..)
  , LedgerTransaction(..)
  , Balance(..)
  , JobStatus(..)
  , JobPayload(..)
  , Job(..)
  , DomainEvent(..)
  , SearchHit(..)
  , Exercise(..)
  , ExerciseResult(..)
  , MonitorSample(..)
  , MonitorAlert(..)
  , KanbanCard(..)
  , ProjectStage(..)
  , ProjectSeed(..)
  , LabProject(..)
  , ProjectStagePatch(..)
  , LearningOutcome(..)
  , LearningLogSeed(..)
  , LearningLog(..)
  , ReleaseSeed(..)
  , LabRelease(..)
  , LabStats(..)
  ) where

import Control.Applicative ((<|>))
import Data.Aeson (FromJSON, ToJSON)
import qualified Data.Aeson as Aeson
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime)
import GHC.Generics (Generic)

-- | Common health response for every service.
data Health = Health
  { healthService :: Text
  , healthStatus :: Text
  , healthVersion :: Text
  , healthCheckedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data ArticleSeed = ArticleSeed
  { seedTitle :: Text
  , seedSlug :: Maybe Text
  , seedBody :: Text
  , seedTags :: [Text]
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data Article = Article
  { articleSlug :: Text
  , articleTitle :: Text
  , articleBody :: Text
  , articleTags :: [Text]
  , articleCreatedAt :: UTCTime
  , articleUpdatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data UrlRequest = UrlRequest
  { requestUrl :: Text
  , requestCustomSlug :: Maybe Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data UrlMapping = UrlMapping
  { urlSlug :: Text
  , urlTarget :: Text
  , urlClicks :: Int
  , urlCreatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LedgerPosting = LedgerPosting
  { postingAccount :: Text
  , postingAmount :: Double
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LedgerSeed = LedgerSeed
  { ledgerDescriptionSeed :: Text
  , ledgerPostingsSeed :: [LedgerPosting]
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LedgerTransaction = LedgerTransaction
  { ledgerId :: Text
  , ledgerDescription :: Text
  , ledgerPostings :: [LedgerPosting]
  , ledgerCreatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data Balance = Balance
  { balanceAccount :: Text
  , balanceAmount :: Double
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data JobStatus
  = JobQueued
  | JobRunning
  | JobSucceeded
  | JobFailed Text
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data JobPayload = JobPayload
  { payloadKind :: Text
  , payloadBody :: Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data Job = Job
  { jobId :: Text
  , jobKind :: Text
  , jobBody :: Text
  , jobStatus :: JobStatus
  , jobAttempts :: Int
  , jobCreatedAt :: UTCTime
  , jobUpdatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data DomainEvent
  = ArticlePublished Text
  | UrlShortened Text Text
  | LedgerAccepted Text
  | JobCompleted Text
  | LearningAttempt Text Bool
  | MonitorAlertRaised Text
  | ProjectCreated Text
  | ProjectStageChanged Text ProjectStage
  | LearningLogged Text
  | ReleasePrepared Text Text
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data SearchHit = SearchHit
  { hitDocument :: FilePath
  , hitScore :: Int
  , hitSnippet :: Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data Exercise = Exercise
  { exerciseId :: Text
  , exerciseTitle :: Text
  , exercisePrompt :: Text
  , exerciseExpectedTokens :: [Text]
  , exerciseHint :: Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data ExerciseResult = ExerciseResult
  { resultExerciseId :: Text
  , resultPassed :: Bool
  , resultMissingTokens :: [Text]
  , resultMessage :: Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data MonitorSample = MonitorSample
  { sampleName :: Text
  , sampleValue :: Double
  , sampleTimestamp :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data MonitorAlert = MonitorAlert
  { alertName :: Text
  , alertValue :: Double
  , alertThreshold :: Double
  , alertTimestamp :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data KanbanCard = KanbanCard
  { cardId :: Text
  , cardTitle :: Text
  , cardStatus :: Text
  , cardCreatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data ProjectStage
  = ProjectIdea
  | ProjectBuilding
  | ProjectShipped
  | ProjectMaintained
  | ProjectArchived
  deriving stock (Eq, Ord, Show, Generic)

instance ToJSON ProjectStage where
  toJSON stage =
    Aeson.String case stage of
      ProjectIdea -> "idea"
      ProjectBuilding -> "building"
      ProjectShipped -> "shipped"
      ProjectMaintained -> "maintained"
      ProjectArchived -> "archived"

instance FromJSON ProjectStage where
  parseJSON = Aeson.withText "ProjectStage" \raw ->
    case T.toLower raw of
      "idea" -> pure ProjectIdea
      "building" -> pure ProjectBuilding
      "shipped" -> pure ProjectShipped
      "maintained" -> pure ProjectMaintained
      "archived" -> pure ProjectArchived
      other -> fail ("unknown project stage: " <> T.unpack other)

data ProjectSeed = ProjectSeed
  { projectNameSeed :: Text
  , projectSummarySeed :: Text
  , projectRepoSeed :: Maybe Text
  , projectDemoSeed :: Maybe Text
  , projectTagsSeed :: [Text]
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LabProject = LabProject
  { projectId :: Text
  , projectName :: Text
  , projectSummary :: Text
  , projectRepository :: Maybe Text
  , projectDemoUrl :: Maybe Text
  , projectTags :: [Text]
  , projectStage :: ProjectStage
  , projectCreatedAt :: UTCTime
  , projectUpdatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

newtype ProjectStagePatch = ProjectStagePatch
  { patchStage :: ProjectStage
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LearningOutcome
  = LearningPlanned
  | LearningPracticed
  | LearningUnderstood
  | LearningBlocked Text
  deriving stock (Eq, Show, Generic)

instance ToJSON LearningOutcome where
  toJSON = \case
    LearningPlanned -> Aeson.String "planned"
    LearningPracticed -> Aeson.String "practiced"
    LearningUnderstood -> Aeson.String "understood"
    LearningBlocked reason ->
      Aeson.object
        [ "status" Aeson..= ("blocked" :: Text)
        , "reason" Aeson..= reason
        ]

instance FromJSON LearningOutcome where
  parseJSON value =
    parseText value <|> parseObject value
    where
      parseText = Aeson.withText "LearningOutcome" \raw ->
        case T.toLower raw of
          "planned" -> pure LearningPlanned
          "practiced" -> pure LearningPracticed
          "understood" -> pure LearningUnderstood
          other -> fail ("unknown learning outcome: " <> T.unpack other)
      parseObject = Aeson.withObject "LearningOutcome" \obj -> do
        status <- obj Aeson..: "status"
        case T.toLower status of
          "blocked" -> LearningBlocked <$> obj Aeson..: "reason"
          other -> fail ("unknown learning outcome object: " <> T.unpack other)

data LearningLogSeed = LearningLogSeed
  { learningTopicSeed :: Text
  , learningNotesSeed :: Text
  , learningLinksSeed :: [Text]
  , learningOutcomeSeed :: LearningOutcome
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LearningLog = LearningLog
  { learningId :: Text
  , learningTopic :: Text
  , learningNotes :: Text
  , learningLinks :: [Text]
  , learningOutcome :: LearningOutcome
  , learningCreatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data ReleaseSeed = ReleaseSeed
  { releaseProjectIdSeed :: Text
  , releaseVersionSeed :: Text
  , releaseNotesSeed :: Text
  , releaseArtifactSeed :: Maybe Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LabRelease = LabRelease
  { releaseId :: Text
  , releaseProjectId :: Text
  , releaseVersion :: Text
  , releaseNotes :: Text
  , releaseArtifactUrl :: Maybe Text
  , releaseCreatedAt :: UTCTime
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data LabStats = LabStats
  { statsProjects :: Int
  , statsLearningLogs :: Int
  , statsReleases :: Int
  , statsShippedProjects :: Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)
