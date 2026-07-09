module HPS.Search
  ( searchFiles
  , searchText
  ) where

import Data.List (sortOn)
import Data.Ord (Down(..))
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import HPS.Domain
import HPS.Util (splitWords)

searchText :: FilePath -> Text -> Text -> Maybe SearchHit
searchText name query content =
  if score == 0
    then Nothing
    else Just SearchHit{hitDocument = name, hitScore = score, hitSnippet = snippet}
  where
    queryTerms = splitWords query
    body = T.toLower content
    score = length [term | term <- queryTerms, term `T.isInfixOf` body]
    snippet = T.take 160 (T.strip content)

searchFiles :: Text -> [FilePath] -> IO [SearchHit]
searchFiles query files = do
  hits <- traverse load files
  pure (take 20 (sortOn (Down . hitScore) (concat hits)))
  where
    load path = do
      content <- TIO.readFile path
      pure (maybe [] pure (searchText path query content))
