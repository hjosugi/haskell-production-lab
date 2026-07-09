module HPS.Api
  ( API
  , apiProxy
  ) where

import Data.Text (Text)
import HPS.Domain
import HPS.Html (HTML)
import Lucid (Html)
import Servant

type API =
       "health" :> Get '[JSON] Health
  :<|> "metrics" :> Get '[PlainText] Text
  :<|> "lab" :> Get '[HTML] (Html ())
  :<|> "lab" :> "stats" :> Get '[JSON] LabStats
  :<|> "lab" :> "projects" :> Get '[JSON] [LabProject]
  :<|> "lab" :> "projects" :> ReqBody '[JSON] ProjectSeed :> PostCreated '[JSON] LabProject
  :<|> "lab" :> "projects" :> Capture "projectId" Text :> "stage" :> ReqBody '[JSON] ProjectStagePatch :> Put '[JSON] LabProject
  :<|> "lab" :> "learning" :> Get '[JSON] [LearningLog]
  :<|> "lab" :> "learning" :> ReqBody '[JSON] LearningLogSeed :> PostCreated '[JSON] LearningLog
  :<|> "lab" :> "releases" :> Get '[JSON] [LabRelease]
  :<|> "lab" :> "releases" :> ReqBody '[JSON] ReleaseSeed :> PostCreated '[JSON] LabRelease
  :<|> "articles" :> Get '[JSON] [Article]
  :<|> "articles" :> ReqBody '[JSON] ArticleSeed :> PostCreated '[JSON] Article
  :<|> "urls" :> ReqBody '[JSON] UrlRequest :> PostCreated '[JSON] UrlMapping
  :<|> "urls" :> Capture "slug" Text :> Get '[JSON] UrlMapping
  :<|> "ledger" :> ReqBody '[JSON] LedgerSeed :> PostCreated '[JSON] LedgerTransaction
  :<|> "ledger" :> "balances" :> Get '[JSON] [Balance]
  :<|> "jobs" :> ReqBody '[JSON] JobPayload :> PostAccepted '[JSON] Job
  :<|> "jobs" :> Get '[JSON] [Job]
  :<|> "events" :> Get '[JSON] [DomainEvent]
  :<|> "search" :> QueryParam "q" Text :> Get '[JSON] [SearchHit]

apiProxy :: Proxy API
apiProxy = Proxy
