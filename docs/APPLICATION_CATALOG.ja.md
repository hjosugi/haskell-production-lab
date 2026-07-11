<!-- i18n: language-switcher -->
[English](APPLICATION_CATALOG.md) | [日本語](APPLICATION_CATALOG.ja.md)

# アプリケーションカタログ

## 同梱されている実行可能アプリ

| 実行可能ファイル | カテゴリ | 何を示しているか |
|---|---|---|
| `hps-api` | Servant RESTサービス + Labダッシュボード | `/lab` プロジェクト管理、学習ログ、リリース準備、型付きAPI、ヘルス、メトリクス、記事、URL短縮、台帳、ジョブ、検索、イベントログ |
| `hps-scotty-shortener` | Scotty HTTPサービス | 軽量なSinatraスタイルのURL短縮器 |
| `hps-url-shortener` | CLI + JSONストア | ファイルバックのローカルサービス境界 |
| `hps-ledger` | フィンテックCLI | 複式簿記の検証 |
| `hps-worker` | バックグラウンドジョブ | STMキュー、リトライ、ワーカーのライフサイクル |
| `hps-event-sourcing` | イベントソーシング | 追記専用のイベントと投影 |
| `hps-stream` | アナリティクスCLI | ストリーミングログ処理 |
| `hps-search` | パーサ/検索 | シンプルなテキスト検索とランキング |
| `hps-static-site` | 静的サイトジェネレーター | ピュアレンダラー + IOシェル |
| `hps-mmlh` | 学習ツール | mmlhに触発された間違い駆動型演習 |
| `hps-monitor` | ランタイム監視 | 閾値ベースのアラート生成 |
| `hps-websocket` | リアルタイムサーバ | WebSocketブロードキャストサーバ |
| `hps-tui-kanban` | ターミナルアプリ | インタラクティブな状態管理CLI/TUI |

## ブループリント

| ブループリント | 目的 |
|---|---|
| `cloudflare/humblr-workers` | D1バックエンドのWorkersブログアーキテクチャ、ルーター / データベース / ストレージ / 画像 / SSRにサービスバインディングを分割 |
| `blueprints/yesod-blog-workshop` | Yesod/GREEスタイルのブログワークショップのスケルトン |
| `blueprints/postgres-adapter` | 実装されたPostgreSQL KVアダプターと将来の台帳リポジトリの方向性 |

## 実世界のインスピレーションマップ

| 実世界のパターン | 実装例 |
|---|---|
| Servantを用いた型付きAPI | `HPS.Api`, `HPS.Handlers`, `hps-api` |
| Haskellのプロダクションラボ | `HPS.Lab`, `HPS.Lab.Html`, `/lab` |
| Sinatraスタイルの小規模サービス | `hps-scotty-shortener` |
| Yesodブログワークショップ | `blueprints/yesod-blog-workshop` |
| mmlhスタイルの間違い学習 | `HPS.Learning`, `hps-mmlh` |
| サービス/ハンドルパターン | `HPS.Service.*` |
| エッジ/WASMブログエンジン | `cloudflare/humblr-workers` |
| 金融 / 信頼性の高い会計 | `HPS.Ledger`, `hps-ledger` |
| ランタイム検証 / 監視 | `HPS.RuntimeMonitor`, `hps-monitor` |
| Awesome-Haskellスタイルのツール | 静的サイト、検索、監視、CLI、ワーカー |