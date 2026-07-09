module HPS.Lab
  ( makeProject
  , updateProjectStage
  , makeLearningLog
  , makeRelease
  , labStats
  , sortProjects
  , sortLearningLogs
  , sortReleases
  , renderProjectStage
  , renderLearningOutcome
  ) where

import Data.List (sortOn)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime)
import HPS.Domain
import HPS.Util (stableSlug, tshow)

makeProject :: UTCTime -> Int -> ProjectSeed -> LabProject
makeProject now index ProjectSeed{projectNameSeed, projectSummarySeed, projectRepoSeed, projectDemoSeed, projectTagsSeed} =
  LabProject
    { projectId = stableSlug (projectNameSeed <> "-" <> tshow index)
    , projectName = T.strip projectNameSeed
    , projectSummary = T.strip projectSummarySeed
    , projectRepository = T.strip <$> projectRepoSeed
    , projectDemoUrl = T.strip <$> projectDemoSeed
    , projectTags = map T.strip projectTagsSeed
    , projectStage = ProjectIdea
    , projectCreatedAt = now
    , projectUpdatedAt = now
    }

updateProjectStage :: UTCTime -> ProjectStage -> LabProject -> LabProject
updateProjectStage now stage project =
  project
    { projectStage = stage
    , projectUpdatedAt = now
    }

makeLearningLog :: UTCTime -> Int -> LearningLogSeed -> LearningLog
makeLearningLog now index LearningLogSeed{learningTopicSeed, learningNotesSeed, learningLinksSeed, learningOutcomeSeed} =
  LearningLog
    { learningId = stableSlug (learningTopicSeed <> "-" <> tshow index)
    , learningTopic = T.strip learningTopicSeed
    , learningNotes = T.strip learningNotesSeed
    , learningLinks = map T.strip learningLinksSeed
    , learningOutcome = learningOutcomeSeed
    , learningCreatedAt = now
    }

makeRelease :: UTCTime -> Int -> ReleaseSeed -> LabRelease
makeRelease now index ReleaseSeed{releaseProjectIdSeed, releaseVersionSeed, releaseNotesSeed, releaseArtifactSeed} =
  LabRelease
    { releaseId = stableSlug (releaseProjectIdSeed <> "-" <> releaseVersionSeed <> "-" <> tshow index)
    , releaseProjectId = T.strip releaseProjectIdSeed
    , releaseVersion = T.strip releaseVersionSeed
    , releaseNotes = T.strip releaseNotesSeed
    , releaseArtifactUrl = T.strip <$> releaseArtifactSeed
    , releaseCreatedAt = now
    }

labStats :: [LabProject] -> [LearningLog] -> [LabRelease] -> LabStats
labStats projects learning releases =
  LabStats
    { statsProjects = length projects
    , statsLearningLogs = length learning
    , statsReleases = length releases
    , statsShippedProjects = length (filter isShipped projects)
    }
  where
    isShipped LabProject{projectStage} =
      projectStage == ProjectShipped || projectStage == ProjectMaintained

sortProjects :: [LabProject] -> [LabProject]
sortProjects = sortOn projectUpdatedAt

sortLearningLogs :: [LearningLog] -> [LearningLog]
sortLearningLogs = sortOn learningCreatedAt

sortReleases :: [LabRelease] -> [LabRelease]
sortReleases = sortOn releaseCreatedAt

renderProjectStage :: ProjectStage -> Text
renderProjectStage = \case
  ProjectIdea -> "Idea"
  ProjectBuilding -> "Building"
  ProjectShipped -> "Shipped"
  ProjectMaintained -> "Maintained"
  ProjectArchived -> "Archived"

renderLearningOutcome :: LearningOutcome -> Text
renderLearningOutcome = \case
  LearningPlanned -> "Planned"
  LearningPracticed -> "Practiced"
  LearningUnderstood -> "Understood"
  LearningBlocked reason -> "Blocked: " <> reason
