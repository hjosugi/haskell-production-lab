{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module SharedApi where

import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)
import Servant

data BlogArticle = BlogArticle
  { slug :: Text
  , title :: Text
  , body :: Text
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

type BlogApi =
       "api" :> "health" :> Get '[JSON] Text
  :<|> "api" :> "articles" :> Get '[JSON] [BlogArticle]
  :<|> "api" :> "articles" :> ReqBody '[JSON] BlogArticle :> PostCreated '[JSON] BlogArticle
