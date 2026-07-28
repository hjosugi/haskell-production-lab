<!-- i18n: language-switcher -->
[English](README.md) | [日本語](README.ja.md)

# Haskell Production Lab

Haskell Production Labは、実際のアプリケーションを構築しながらHaskellについて深く学び、オンラインで作業を追跡するための公開されたプロダクションスタイルのモノレポです。

メインアプリは、`/lab`で提供されるServant APIから配信されるHaskell製のラボダッシュボードです。これには以下が含まれます。

- Haskellアプリのアイデアとリリース済みプロジェクト
- 学習ログと練習ノート
- リリースノートとアーティファクトリンク
- 健康状態、メトリクス、イベントログ、検索、ジョブ、台帳デモ、およびサポートCLIアプリ

リポジトリには、焦点を絞った例も含まれています：URLショートナー、ダブルエントリー台帳、STMワーカー、イベントソーシング、ストリーミング分析、パーサ/検索、静的サイトジェネレータ、mmlhスタイルの学習CLI、ランタイム監視、WebSocketチャット、TUIカンバン、そしてCloudflare Workers / Haskell WASMのブループリント。

## クイックスタート

```bash
cabal update
cabal build all
cabal test all

cabal run hps-api
```

開く：

```text
http://localhost:8080/lab
```

APIのデフォルトポートは`8080`です。上書きするには：

```bash
PORT=9000 cabal run hps-api
```

## Lab API

```bash
curl localhost:8080/health
curl localhost:8080/lab/stats
curl localhost:8080/lab/projects

curl -X POST localhost:8080/lab/projects \
  -H 'content-type: application/json' \
  -d '{
    "projectNameSeed": "Typed calculator",
    "projectSummarySeed": "CLIラッパー付きの純粋計算コア。",
    "projectRepoSeed": null,
    "projectDemoSeed": null,
    "projectTagsSeed": ["calculator", "types"]
  }'
```

## リポジトリマップ

```text
src/                       共有Haskellライブラリ
src/HPS/Lab*.hs            プロジェクト、学習、リリースダッシュボード
app/                       実行可能アプリケーション
cloudflare/humblr-workers/ Haskell/WASM Cloudflare Workersブログブループリント
migrations/postgresql/     バージョン管理されたPostgreSQLスキーママイグレーション
docs/                      アーキテクチャ、運用手順、本番ノート、リファレンス
issues/                    Markdownによる課題バックログと将来の機能
examples/                  サンプル入力とリクエストファイル
.github/                   CI、リリースワークフロー、課題テンプレート
```

## なぜHaskellを使うのか？

コードは純粋なビジネスロジックをIOハンドルから分離しています。プロジェクトの段階、学習成果、リリース記録、台帳の不変条件、ジョブの状態は、緩い文字列ではなく代数的データ型でモデル化されています。これにより、システムのリファクタリング、テスト、インメモリのSTMストレージからPostgreSQL、Cloudflare D1/R2、または他の本番バックエンドへの移行が容易になります。

## リリースフロー

タグを作成してプッシュします：

```bash
git tag v0.1.0
git push origin v0.1.0
```

GitHubのリリースワークフローは、ソースアーカイブをビルドし、そのタグからリリースを公開します。最初のリリースは手動でも作成可能です：

```bash
gh release create v0.1.0 --title "v0.1.0" --notes-file docs/RELEASE_NOTES_v0.1.0.md
```