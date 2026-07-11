<!-- i18n: language-switcher -->
[English](ARCHITECTURE.md) | [日本語](ARCHITECTURE.ja.md)

# アーキテクチャ

## 目的

このリポジトリは、「Haskellで作れる実サービス」を横断的に練習し、その制作物・学習ログ・リリース準備をオンラインで管理するためのproductionスタイルのモノレポです。

重点は次の3つです。

1. ピュアなドメインロジックとIOを分離する
2. Service/Handleパターンでロガー / ストア / キュー / メトリクス / イベントストアを差し替え可能にする
3. Web API、HTMLダッシュボード、CLI、ワーカー、エッジ/WASM、学習ツールまで同じ設計思想で作る

## Haskell Production Lab

`/lab` はServant APIからLucidで配信される管理UIです。

- `ProjectStage` でアイデア / ビルド中 / 出荷済み / メンテナンス中 / アーカイブ済みを型として表す
- `LearningOutcome` で計画済み / 実践済み / 理解済み / ブロック中を型として表す
- `LabRelease` でGitHubリリース前のノートとアーティファクトURLを管理する
- STMストアはローカルファーストな実装で、将来的にPostgres / D1に置き換えられる

## ハイレベル設計

```text
              +-------------------+
HTTP/CLI ---> | app/* 実行可能ファイル |
              +---------+---------+
                        |
                        v
              +-------------------+
              | src/HPS/* ライブラリ |
              +---------+---------+
                        |
                        v
        +---------------+----------------+
        | サービスハンドル / アダプター   |
        | ロガー、KV、キュー、メトリクス   |
        +--------------------------------+
```

## コアルール

ドメインモジュールはHTTP、ファイル、Cloudflareについて知るべきではありません。IOモジュールはハンドルに依存し、具体的な実装には依存しません。

これにより：

- インメモリテスト
- ファイルバックのローカルデモ
- PostgreSQL KVストレージとD1をバックエンドに持つHumblr Database Worker、将来的にはRedis / R2アダプターも
- より薄いServant、Scotty、Yesod、Worker層

## プロダクションアップグレードパス

| 領域 | 現在の実装 | プロダクション置き換え案 |
|---|---|---|
| ストア | STM / JSONファイル; PostgreSQL KVアダプター | Cloudflare D1、DynamoDB、ドメイン固有のPostgreSQLリポジトリ |
| キュー | STM TQueue | Cloudflare Queues、SQS、Redis Streams |
| オブジェクトストレージ | Blueprint | Cloudflare R2、S3 |
| 可観測性 | インメモリメトリクス | Prometheus / OpenTelemetry |
| 認証 | バックログ | JWT / OAuth2、内部サービス呼び出し用mTLS |
| デプロイ | Docker / CIブループリント | Kubernetes、Nomad、Fly.io、Cloudflare Workers |