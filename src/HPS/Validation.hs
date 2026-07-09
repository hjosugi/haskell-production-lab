module HPS.Validation
  ( validateArticleSeed
  , validateUrlRequest
  , validateLedgerSeed
  , validateJobPayload
  , validateProjectSeed
  , validateLearningLogSeed
  , validateReleaseSeed
  ) where

import Data.List (nub)
import Data.Text (Text)
import qualified Data.Text as T
import HPS.Domain

nonEmpty :: Text -> Text -> Either Text ()
nonEmpty label value
  | T.null (T.strip value) = Left (label <> " must not be empty")
  | otherwise = Right ()

validateArticleSeed :: ArticleSeed -> Either Text ()
validateArticleSeed ArticleSeed{seedTitle, seedBody, seedTags} = do
  nonEmpty "title" seedTitle
  nonEmpty "body" seedBody
  if length seedTags == length (nub seedTags)
    then Right ()
    else Left "tags must be unique"

validateUrlRequest :: UrlRequest -> Either Text ()
validateUrlRequest UrlRequest{requestUrl, requestCustomSlug} = do
  if "https://" `T.isPrefixOf` requestUrl || "http://" `T.isPrefixOf` requestUrl
    then Right ()
    else Left "url must start with http:// or https://"
  case requestCustomSlug of
    Nothing -> Right ()
    Just slug -> nonEmpty "customSlug" slug

validateLedgerSeed :: LedgerSeed -> Either Text ()
validateLedgerSeed LedgerSeed{ledgerPostingsSeed} = do
  if length ledgerPostingsSeed < 2
    then Left "ledger transaction needs at least two postings"
    else Right ()
  let total = sum (map postingAmount ledgerPostingsSeed)
  if abs total < 0.000001
    then Right ()
    else Left "double-entry ledger transaction must balance to zero"

validateJobPayload :: JobPayload -> Either Text ()
validateJobPayload JobPayload{payloadKind, payloadBody} = do
  nonEmpty "kind" payloadKind
  nonEmpty "body" payloadBody

validateProjectSeed :: ProjectSeed -> Either Text ()
validateProjectSeed ProjectSeed{projectNameSeed, projectSummarySeed, projectRepoSeed, projectDemoSeed, projectTagsSeed} = do
  nonEmpty "projectName" projectNameSeed
  nonEmpty "projectSummary" projectSummarySeed
  mapM_ (validateUrl "repository") projectRepoSeed
  mapM_ (validateUrl "demo") projectDemoSeed
  if length projectTagsSeed == length (nub projectTagsSeed)
    then Right ()
    else Left "project tags must be unique"

validateLearningLogSeed :: LearningLogSeed -> Either Text ()
validateLearningLogSeed LearningLogSeed{learningTopicSeed, learningNotesSeed, learningLinksSeed} = do
  nonEmpty "learningTopic" learningTopicSeed
  nonEmpty "learningNotes" learningNotesSeed
  mapM_ (validateUrl "learning link") learningLinksSeed

validateReleaseSeed :: ReleaseSeed -> Either Text ()
validateReleaseSeed ReleaseSeed{releaseProjectIdSeed, releaseVersionSeed, releaseNotesSeed, releaseArtifactSeed} = do
  nonEmpty "releaseProjectId" releaseProjectIdSeed
  nonEmpty "releaseVersion" releaseVersionSeed
  nonEmpty "releaseNotes" releaseNotesSeed
  mapM_ (validateUrl "artifact") releaseArtifactSeed

validateUrl :: Text -> Text -> Either Text ()
validateUrl label value
  | T.null (T.strip value) = Right ()
  | "https://" `T.isPrefixOf` value || "http://" `T.isPrefixOf` value = Right ()
  | otherwise = Left (label <> " must start with http:// or https://")
