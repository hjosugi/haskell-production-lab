<!-- i18n: language-switcher -->
[English](CLOUDFLARE_WORKERS_WASM.md) | [日本語](CLOUDFLARE_WORKERS_WASM.ja.md)

# Cloudflare Workers + Haskell WASM ブループリント

`cloudflare/humblr-workers` フォルダは、提供された記事の Haskell-on-Cloudflare ブログエンジンアーキテクチャに触発されています。

## サービスの分割

```text
ルーターワーカー  -> パブリックHTTPルート
データベースワーカー -> D1 SQLアクセス
ストレージワーカー  -> R2オブジェクトストレージアクセス
画像ワーカー      ->画像変換の境界
SSRワーカー       -> Haskell/Misoのようなレンダリング境界
```

## なぜサービスを分割するのか？

分割することで各ワーカーが小さく保たれ、巨大なモジュールを避け、明確な所有権を持たせることができます。

- ルーターはリクエストの流れを決定します。
- データベースはSQLとマイグレーションを管理します。
- ストレージはオブジェクトキーとアップロードポリシーを管理します。
- 画像はリサイズ・フォーマットポリシーを管理します。
- SSRはHTMLレンダリングを管理します。

## Haskell/WASMの注意点

GHC wasmバックエンドを通じたHaskellからWASMへの変換は実現していますが、Cloudflare Workerとの統合には依然としてJSモジュールの境界や、バンドルサイズ・メモリの慎重なテストが必要です。そのため、このブループリントには以下が含まれます。

- Haskellの共有API/ドメインモジュール
- Worker用のJSシム
- Wrangler設定から生成されたバインディングタイプ
- 記事、コメント、ハッシュ化セッション用のバージョン管理されたD1マイグレーション
- ルーターとデータベースサービス間のルーティングバインディング
- workerd/Vitestによる統合テストとデプロイのドライラン
- 本番環境の堅牢化のための明示的な課題バックログ

## D1ワークフロー

実行可能なワークフローは
`cloudflare/humblr-workers/README.md` に記載されています。要約すると、`npm run d1:migrate` は Wranglerのローカル状態にのみ適用され、`npm test` はマイグレーションとWorkerd内のデータベースワーカーリクエストを実行し、`npm run deploy` はルーターとデータベースワーカーをデプロイします。リモートマイグレーションには明示的な `d1:migrate:remote` コマンドが必要です。

## ローカルの代替案

`hps-api` を、エッジワーカーに移行する前の同じブログ/サービスアイデアのローカルServantバージョンとして使用してください。