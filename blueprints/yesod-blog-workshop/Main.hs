{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

import Yesod

data App = App

mkYesod "App" [parseRoutes|
/ HomeR GET
/blog BlogR GET POST
|]

instance Yesod App

getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|
  <h1>Yesod Blog Workshop
  <p>Start from a typed route, then add forms, Persistent, Aeson, and auth.
|]

getBlogR :: Handler Value
getBlogR = returnJson ["typed routes", "templates", "forms"]

postBlogR :: Handler Value
postBlogR = returnJson (object ["ok" .= True])

main :: IO ()
main = warp 3000 App
