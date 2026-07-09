module Main (main) where

import Data.Aeson (encode)
import qualified Data.ByteString.Lazy.Char8 as BL8
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Time (getCurrentTime)
import HPS.Domain
import qualified HPS.Service.KV as KV
import HPS.Util (stableSlug)
import HPS.Validation (validateUrlRequest)
import System.Environment (getArgs)

main :: IO ()
main = do
  store <- KV.newJsonFileHandle "data/url-shortener.json"
  args <- getArgs
  case args of
    ["create", rawUrl] -> create store (T.pack rawUrl) Nothing
    ["create", rawUrl, rawSlug] -> create store (T.pack rawUrl) (Just (T.pack rawSlug))
    ["get", rawSlug] -> KV.kvGet store (T.pack rawSlug) >>= maybe notFound (BL8.putStrLn . encode)
    ["list"] -> KV.kvList store >>= BL8.putStrLn . encode . map snd
    _ -> TIO.putStrLn "usage: hps-url-shortener create <url> [slug] | get <slug> | list"
  where
    notFound = TIO.putStrLn "not found"

create :: KV.Handle T.Text UrlMapping -> T.Text -> Maybe T.Text -> IO ()
create store target customSlug = do
  let request = UrlRequest{requestUrl = target, requestCustomSlug = customSlug}
  case validateUrlRequest request of
    Left err -> TIO.putStrLn ("error: " <> err)
    Right () -> do
      now <- getCurrentTime
      let slug = maybe (stableSlug target) stableSlug customSlug
          mapping = UrlMapping{urlSlug = slug, urlTarget = target, urlClicks = 0, urlCreatedAt = now}
      KV.kvPut store slug mapping
      BL8.putStrLn (encode mapping)
