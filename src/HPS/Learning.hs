module HPS.Learning
  ( exercises
  , findExercise
  , evaluateSubmission
  , renderExercise
  ) where

import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import HPS.Domain

exercises :: [Exercise]
exercises =
  [ Exercise
      { exerciseId = "mmlh-001"
      , exerciseTitle = "Fix a type mismatch"
      , exercisePrompt = "Implement addOne :: Int -> Int without changing the type signature."
      , exerciseExpectedTokens = ["addOne", "::", "Int", "+"]
      , exerciseHint = "The body should use numeric addition, not string concatenation."
      }
  , Exercise
      { exerciseId = "mmlh-002"
      , exerciseTitle = "Replace partial head"
      , exercisePrompt = "Rewrite firstName :: [Text] -> Maybe Text without using head."
      , exerciseExpectedTokens = ["Maybe", "Nothing", "Just"]
      , exerciseHint = "Pattern match on [] and x : _."
      }
  , Exercise
      { exerciseId = "mmlh-003"
      , exerciseTitle = "Separate pure logic from IO"
      , exercisePrompt = "Move validation logic into a pure function and keep putStrLn in main."
      , exerciseExpectedTokens = ["Either", "main", "validate"]
      , exerciseHint = "Pure functions should not call print, readFile, or getLine."
      }
  ]

findExercise :: Text -> Maybe Exercise
findExercise ident = go exercises
  where
    go [] = Nothing
    go (e:rest)
      | exerciseId e == ident = Just e
      | otherwise = go rest

evaluateSubmission :: Exercise -> Text -> ExerciseResult
evaluateSubmission Exercise{exerciseId, exerciseExpectedTokens} submission =
  ExerciseResult
    { resultExerciseId = exerciseId
    , resultPassed = null missing
    , resultMissingTokens = missing
    , resultMessage = if null missing then "passed" else "missing: " <> T.intercalate ", " missing
    }
  where
    lowered = T.toLower submission
    missing = filter (not . (`T.isInfixOf` lowered) . T.toLower) exerciseExpectedTokens

renderExercise :: Exercise -> Text
renderExercise Exercise{exerciseId, exerciseTitle, exercisePrompt, exerciseHint} = T.unlines
  [ "# " <> exerciseId <> " - " <> exerciseTitle
  , ""
  , exercisePrompt
  , ""
  , "Hint: " <> fromMaybe exerciseHint (Just exerciseHint)
  ]
