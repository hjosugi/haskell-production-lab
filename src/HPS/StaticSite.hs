module HPS.StaticSite
  ( markdownToHtml
  , buildSite
  ) where

import Control.Monad (forM_)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.Directory (createDirectoryIfMissing, listDirectory)
import System.FilePath ((</>), replaceExtension, takeFileName)

markdownToHtml :: Text -> Text
markdownToHtml input = T.unlines
  [ "<!doctype html>"
  , "<html lang=\"en\"><head><meta charset=\"utf-8\"><title>HPS Site</title></head><body>"
  , T.unlines (map renderLine (T.lines input))
  , "</body></html>"
  ]
  where
    renderLine line
      | "# " `T.isPrefixOf` line = tag "h1" (T.drop 2 line)
      | "## " `T.isPrefixOf` line = tag "h2" (T.drop 3 line)
      | "### " `T.isPrefixOf` line = tag "h3" (T.drop 4 line)
      | T.null (T.strip line) = ""
      | otherwise = tag "p" line
    tag name body = "<" <> name <> ">" <> escape body <> "</" <> name <> ">"
    escape = T.concatMap \case
      '<' -> "&lt;"
      '>' -> "&gt;"
      '&' -> "&amp;"
      '"' -> "&quot;"
      c -> T.singleton c

buildSite :: FilePath -> FilePath -> IO ()
buildSite inputDir outputDir = do
  createDirectoryIfMissing True outputDir
  files <- listDirectory inputDir
  forM_ files \file -> do
    let src = inputDir </> file
        dst = outputDir </> replaceExtension (takeFileName file) "html"
    content <- TIO.readFile src
    TIO.writeFile dst (markdownToHtml content)
