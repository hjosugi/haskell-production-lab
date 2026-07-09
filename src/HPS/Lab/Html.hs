module HPS.Lab.Html
  ( renderLabDashboard
  ) where

import Control.Monad (forM_)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time (UTCTime)
import Data.Time.Format (defaultTimeLocale, formatTime)
import HPS.Domain
import HPS.Lab
import Lucid
import Lucid.Base (makeAttribute)

renderLabDashboard :: [LabProject] -> [LearningLog] -> [LabRelease] -> Html ()
renderLabDashboard projects learning releases =
  do
    doctype_
    html_ [lang_ "en"] do
      head_ do
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        title_ "Haskell Production Lab"
        style_ labCss
      body_ do
        header_ [class_ "topbar"] do
          div_ do
            h1_ "Haskell Production Lab"
            p_ "Projects, learning logs, and release notes managed by a Haskell app."
          nav_ do
            a_ [href_ "#projects"] "Projects"
            a_ [href_ "#learning"] "Learning"
            a_ [href_ "#releases"] "Releases"
            a_ [href_ "/health"] "Health"
        main_ do
          renderStats stats
          section_ [id_ "projects", class_ "band"] do
            div_ [class_ "section-head"] do
              h2_ "Projects"
              span_ [class_ "muted"] "Track ideas through shipped Haskell apps."
            renderProjects projects
            renderProjectForm
          section_ [id_ "learning", class_ "band"] do
            div_ [class_ "section-head"] do
              h2_ "Learning"
              span_ [class_ "muted"] "Keep deliberate practice visible."
            renderLearning learning
            renderLearningForm
          section_ [id_ "releases", class_ "band"] do
            div_ [class_ "section-head"] do
              h2_ "Releases"
              span_ [class_ "muted"] "Prepare public GitHub release notes."
            renderReleases releases
            renderReleaseForm projects
        footer_ do
          span_ "Served by Servant, STM, Lucid, and pure Haskell domain logic."
        script_ labJs
  where
    stats = labStats projects learning releases

renderStats :: LabStats -> Html ()
renderStats LabStats{statsProjects, statsLearningLogs, statsReleases, statsShippedProjects} =
  section_ [class_ "stats"] do
    stat "Projects" statsProjects
    stat "Shipped" statsShippedProjects
    stat "Learning logs" statsLearningLogs
    stat "Releases" statsReleases
  where
    stat :: Text -> Int -> Html ()
    stat label value =
      div_ [class_ "stat"] do
        span_ [class_ "stat-value"] (toHtml (show value))
        span_ [class_ "stat-label"] (toHtml label)

renderProjects :: [LabProject] -> Html ()
renderProjects [] = p_ [class_ "empty"] "No projects yet."
renderProjects projects =
  table_ do
    thead_ do
      tr_ do
        th_ "Name"
        th_ "Stage"
        th_ "Repository"
        th_ "Demo"
        th_ "Tags"
        th_ "Updated"
    tbody_ do
      forM_ projects \project -> tr_ do
        td_ do
          strong_ (toHtml (projectName project))
          div_ [class_ "muted"] (toHtml (projectSummary project))
          code_ (toHtml (projectId project))
        td_ (stageSelect project)
        td_ (maybeLink (projectRepository project))
        td_ (maybeLink (projectDemoUrl project))
        td_ (tagList (projectTags project))
        td_ (timeCell (projectUpdatedAt project))

renderLearning :: [LearningLog] -> Html ()
renderLearning [] = p_ [class_ "empty"] "No learning logs yet."
renderLearning learning =
  table_ do
    thead_ do
      tr_ do
        th_ "Topic"
        th_ "Outcome"
        th_ "Links"
        th_ "Created"
    tbody_ do
      forM_ learning \entry -> tr_ do
        td_ do
          strong_ (toHtml (learningTopic entry))
          div_ [class_ "muted"] (toHtml (learningNotes entry))
          code_ (toHtml (learningId entry))
        td_ (span_ [class_ "pill"] (toHtml (renderLearningOutcome (learningOutcome entry))))
        td_ (linkList (learningLinks entry))
        td_ (timeCell (learningCreatedAt entry))

renderReleases :: [LabRelease] -> Html ()
renderReleases [] = p_ [class_ "empty"] "No releases yet."
renderReleases releases =
  table_ do
    thead_ do
      tr_ do
        th_ "Version"
        th_ "Project"
        th_ "Artifact"
        th_ "Notes"
        th_ "Created"
    tbody_ do
      forM_ releases \release -> tr_ do
        td_ do
          strong_ (toHtml (releaseVersion release))
          div_ do code_ (toHtml (releaseId release))
        td_ do code_ (toHtml (releaseProjectId release))
        td_ (maybeLink (releaseArtifactUrl release))
        td_ (toHtml (releaseNotes release))
        td_ (timeCell (releaseCreatedAt release))

renderProjectForm :: Html ()
renderProjectForm =
  form_ [id_ "project-form", class_ "inline-form"] do
    label_ do
      span_ "Name"
      input_ [id_ "project-name", type_ "text", required_ "required"]
    label_ [class_ "wide"] do
      span_ "Summary"
      input_ [id_ "project-summary", type_ "text", required_ "required"]
    label_ do
      span_ "Repository"
      input_ [id_ "project-repo", type_ "url"]
    label_ do
      span_ "Demo"
      input_ [id_ "project-demo", type_ "url"]
    label_ do
      span_ "Tags"
      input_ [id_ "project-tags", type_ "text", placeholder_ "servant, cli"]
    button_ [type_ "submit"] "Create project"

renderLearningForm :: Html ()
renderLearningForm =
  form_ [id_ "learning-form", class_ "inline-form"] do
    label_ do
      span_ "Topic"
      input_ [id_ "learning-topic", type_ "text", required_ "required"]
    label_ [class_ "wide"] do
      span_ "Notes"
      input_ [id_ "learning-notes", type_ "text", required_ "required"]
    label_ do
      span_ "Outcome"
      select_ [id_ "learning-outcome"] do
        option_ [value_ "planned"] "Planned"
        option_ [value_ "practiced", selected_ "selected"] "Practiced"
        option_ [value_ "understood"] "Understood"
    label_ do
      span_ "Links"
      input_ [id_ "learning-links", type_ "text", placeholder_ "https://..."]
    button_ [type_ "submit"] "Log learning"

renderReleaseForm :: [LabProject] -> Html ()
renderReleaseForm projects =
  form_ [id_ "release-form", class_ "inline-form"] do
    label_ do
      span_ "Project"
      select_ [id_ "release-project"] do
        forM_ projects \project ->
          option_ [value_ (projectId project)] (toHtml (projectName project))
    label_ do
      span_ "Version"
      input_ [id_ "release-version", type_ "text", placeholder_ "v0.1.0", required_ "required"]
    label_ do
      span_ "Artifact"
      input_ [id_ "release-artifact", type_ "url"]
    label_ [class_ "wide"] do
      span_ "Notes"
      input_ [id_ "release-notes", type_ "text", required_ "required"]
    button_ [type_ "submit"] "Prepare release"

stageSelect :: LabProject -> Html ()
stageSelect LabProject{projectId, projectStage} =
  select_ [class_ "stage-select", makeAttribute "data-project-id" projectId] do
    optionFor ProjectIdea "idea"
    optionFor ProjectBuilding "building"
    optionFor ProjectShipped "shipped"
    optionFor ProjectMaintained "maintained"
    optionFor ProjectArchived "archived"
  where
    optionFor :: ProjectStage -> Text -> Html ()
    optionFor stage raw =
      option_ (value_ raw : selectedAttrs stage) (toHtml (renderProjectStage stage))
    selectedAttrs stage =
      if stage == projectStage then [selected_ "selected"] else []

maybeLink :: Maybe Text -> Html ()
maybeLink Nothing = span_ [class_ "muted"] "none"
maybeLink (Just url)
  | T.null (T.strip url) = span_ [class_ "muted"] "none"
  | otherwise = a_ [href_ url, target_ "_blank", rel_ "noreferrer"] "open"

linkList :: [Text] -> Html ()
linkList [] = span_ [class_ "muted"] "none"
linkList links = forM_ links \url -> div_ (maybeLink (Just url))

tagList :: [Text] -> Html ()
tagList [] = span_ [class_ "muted"] "none"
tagList tags = forM_ tags \tag -> span_ [class_ "pill"] (toHtml tag)

timeCell :: UTCTime -> Html ()
timeCell = span_ [class_ "muted"] . toHtml . T.pack . formatTime defaultTimeLocale "%Y-%m-%d %H:%M UTC"

labCss :: Text
labCss =
  T.unlines
    [ ":root{color-scheme:light;--ink:#202124;--muted:#667085;--line:#d0d5dd;--bg:#f7f7f4;--panel:#ffffff;--accent:#117865;--warn:#a15c07;--hot:#b42318}"
    , "*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",sans-serif;font-size:15px;line-height:1.45}"
    , ".topbar{display:flex;align-items:flex-end;justify-content:space-between;gap:24px;padding:24px 32px 18px;background:var(--panel);border-bottom:1px solid var(--line)}"
    , "h1{margin:0;font-size:30px;line-height:1.1;font-weight:750}h2{margin:0;font-size:20px}p{margin:6px 0 0}.topbar nav{display:flex;gap:12px;flex-wrap:wrap}.topbar a{color:var(--accent);font-weight:700;text-decoration:none}"
    , "main{max-width:1180px;margin:0 auto;padding:22px 20px 44px}.stats{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-bottom:20px}.stat{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:14px}.stat-value{display:block;font-size:28px;font-weight:800}.stat-label{color:var(--muted)}"
    , ".band{background:var(--panel);border:1px solid var(--line);border-radius:8px;margin:0 0 18px;padding:18px}.section-head{display:flex;align-items:baseline;justify-content:space-between;gap:14px;margin-bottom:14px}.muted{color:var(--muted);font-size:13px}"
    , "table{width:100%;border-collapse:collapse;margin-bottom:16px;table-layout:fixed}th,td{text-align:left;vertical-align:top;border-bottom:1px solid var(--line);padding:10px 8px;overflow-wrap:anywhere}th{font-size:12px;text-transform:uppercase;color:var(--muted);letter-spacing:0;font-weight:800}tr:last-child td{border-bottom:0}code{display:inline-block;margin-top:4px;color:#6941c6;font-size:12px}"
    , ".pill{display:inline-block;background:#eef4ff;color:#3538cd;border:1px solid #c7d7fe;border-radius:999px;padding:2px 8px;margin:2px 4px 2px 0;font-size:12px;font-weight:700}.empty{border:1px dashed var(--line);border-radius:8px;padding:12px;color:var(--muted);margin-bottom:16px}"
    , ".inline-form{display:grid;grid-template-columns:repeat(5,minmax(130px,1fr)) auto;gap:10px;align-items:end;border-top:1px solid var(--line);padding-top:14px}.inline-form label{display:flex;flex-direction:column;gap:5px;font-weight:700;color:var(--muted);font-size:12px}.inline-form .wide{grid-column:span 2}"
    , "input,select{height:38px;border:1px solid var(--line);border-radius:6px;background:#fff;padding:8px 10px;color:var(--ink);font:inherit;min-width:0}button{height:38px;border:0;border-radius:6px;background:var(--accent);color:#fff;font-weight:800;padding:0 14px;white-space:nowrap;cursor:pointer}button:focus,input:focus,select:focus,a:focus{outline:3px solid #99f6e4;outline-offset:2px}"
    , "footer{max-width:1180px;margin:0 auto 28px;padding:0 20px;color:var(--muted)}@media(max-width:860px){.topbar{align-items:flex-start;flex-direction:column;padding:20px}.stats{grid-template-columns:repeat(2,minmax(0,1fr))}.section-head{align-items:flex-start;flex-direction:column}.inline-form{grid-template-columns:1fr}.inline-form .wide{grid-column:auto}table{display:block;overflow-x:auto;white-space:nowrap}}"
    ]

labJs :: Text
labJs =
  T.unlines
    [ "const compact = value => value && value.trim() ? value.trim() : null;"
    , "const csv = value => value.split(',').map(x => x.trim()).filter(Boolean);"
    , "async function postJson(path, body) {"
    , "  const res = await fetch(path, {method:'POST', headers:{'content-type':'application/json'}, body: JSON.stringify(body)});"
    , "  if (!res.ok) throw new Error(await res.text());"
    , "  location.reload();"
    , "}"
    , "document.querySelector('#project-form').addEventListener('submit', event => {"
    , "  event.preventDefault();"
    , "  postJson('/lab/projects', {projectNameSeed:document.querySelector('#project-name').value, projectSummarySeed:document.querySelector('#project-summary').value, projectRepoSeed:compact(document.querySelector('#project-repo').value), projectDemoSeed:compact(document.querySelector('#project-demo').value), projectTagsSeed:csv(document.querySelector('#project-tags').value)}).catch(alert);"
    , "});"
    , "document.querySelector('#learning-form').addEventListener('submit', event => {"
    , "  event.preventDefault();"
    , "  postJson('/lab/learning', {learningTopicSeed:document.querySelector('#learning-topic').value, learningNotesSeed:document.querySelector('#learning-notes').value, learningLinksSeed:csv(document.querySelector('#learning-links').value), learningOutcomeSeed:document.querySelector('#learning-outcome').value}).catch(alert);"
    , "});"
    , "document.querySelector('#release-form').addEventListener('submit', event => {"
    , "  event.preventDefault();"
    , "  postJson('/lab/releases', {releaseProjectIdSeed:document.querySelector('#release-project').value, releaseVersionSeed:document.querySelector('#release-version').value, releaseNotesSeed:document.querySelector('#release-notes').value, releaseArtifactSeed:compact(document.querySelector('#release-artifact').value)}).catch(alert);"
    , "});"
    , "document.querySelectorAll('.stage-select').forEach(select => select.addEventListener('change', async event => {"
    , "  const id = event.target.dataset.projectId;"
    , "  const res = await fetch('/lab/projects/' + encodeURIComponent(id) + '/stage', {method:'PUT', headers:{'content-type':'application/json'}, body: JSON.stringify({patchStage:event.target.value})});"
    , "  if (!res.ok) alert(await res.text()); else location.reload();"
    , "}));"
    ]
