module Main (main) where

import Control.Concurrent.STM
import qualified Data.Map.Strict as Map
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Data.Time (getCurrentTime)
import HPS.Domain
import HPS.Util (currentServicePort, stableSlug, tshow)
import HPS.Validation (validateUrlRequest)
import Network.HTTP.Types.Status (badRequest400, created201, notFound404)
import Web.Scotty

main :: IO ()
main = do
  port <- currentServicePort 8082
  store <- newTVarIO Map.empty
  scotty port do
    get "/health" do
      now <- liftIO getCurrentTime
      json Health{healthService = "hps-scotty-shortener", healthStatus = "ok", healthVersion = "0.1.0", healthCheckedAt = now}

    post "/urls" do
      urlRequest <- jsonData :: ActionM UrlRequest
      case validateUrlRequest urlRequest of
        Left err -> status badRequest400 >> text (TL.fromStrict err)
        Right () -> do
          now <- liftIO getCurrentTime
          let slug = maybe (stableSlug (requestUrl urlRequest)) stableSlug (requestCustomSlug urlRequest)
              mapping = UrlMapping{urlSlug = slug, urlTarget = requestUrl urlRequest, urlClicks = 0, urlCreatedAt = now}
          liftIO $ atomically (modifyTVar' store (Map.insert slug mapping))
          status created201
          json mapping

    get "/:slug" do
      slug <- pathParam "slug" :: ActionM T.Text
      found <- liftIO $ atomically do
        urls <- readTVar store
        case Map.lookup slug urls of
          Nothing -> pure Nothing
          Just mapping -> do
            let clicked = mapping{urlClicks = urlClicks mapping + 1}
            writeTVar store (Map.insert slug clicked urls)
            pure (Just clicked)
      case found of
        Nothing -> status notFound404 >> text "not found"
        Just mapping -> redirect (TL.fromStrict (urlTarget mapping))

    get "/_debug/urls" do
      urls <- liftIO $ atomically (Map.elems <$> readTVar store)
      json urls

    notFound do
      status notFound404
      text ("unknown route on port " <> TL.fromStrict (tshow port))
