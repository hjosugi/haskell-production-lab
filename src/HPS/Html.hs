module HPS.Html
  ( HTML
  ) where

import Lucid (Html, renderBS)
import Network.HTTP.Media ((//), (/:))
import Servant.API (Accept(..), MimeRender(..))

data HTML

instance Accept HTML where
  contentType _ = "text" // "html" /: ("charset", "utf-8")

instance MimeRender HTML (Html ()) where
  mimeRender _ = renderBS
