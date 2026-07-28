<!-- i18n: language-switcher -->
[English](README.md) | [日本語](README.ja.md)

# Humblr Workers ブループリント

Cloudflare Workers + Haskell/WASM ブログエンジンのブループリント。

このフォルダは本番環境の分割を反映しています：

```text
router-worker      公開ルート、認証、サービスオーケストレーション
database-worker    D1 SQLアクセス
storage-worker     R2オブジェクトストレージ
images-worker      画像ポリシーと変換境界
ssr-worker         Haskell/WASMまたはフォールバックレンダラーによるHTMLレンダリング
```

## ローカルコマンド

```bash
npm ci
npm run types
npm run d1:migrate
npm run dev
```

`d1:migrate`は`schema/*.sql`をWranglerのローカル専用D1状態に適用します。
`.wrangler/state`内に保存されます。これにより`articles`、`comments`、`sessions`テーブルが作成されます。
リモートデータベースには一切触れません。ローカルスキーマを確認するには：

```bash
npx wrangler d1 execute DB --local \
  --config wrangler.database.jsonc \
  --command "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name"
```

`npm run dev`はRouter Workerをプライマリワーカーとして起動し、Database WorkerをセカンダリワーカーとしてWranglerのマルチコンフィグ開発モードで起動します。ルーターの`DATABASE`サービスバインディングは公開HTTPホップなしで接続されます。もし実験的なマルチコンフィグモードが利用できない場合は、別々のターミナルで次を実行してください：

```bash
npm run dev:database
npm run dev:router
```

## D1 API境界

Router Workerによってフォワードされる公開ルート：

- `GET/POST /api/articles`
- `GET /api/articles/:slug`
- `GET/POST /api/articles/:slug/comments`

Database Workerはまた、`/internal/sessions`以下のサービスバインディング専用のセッションルートも持ちます。セッション呼び出し側はSHA-256の16進数トークンハッシュを提供します。生のセッショントークンは保存も返却もされません。Database Workerは`workers_dev: false`なので、展開は`workers.dev`エンドポイントを公開しません。

すべてのD1値は`.bind()`を用いたプリペアドステートメントを通じて渡されます。JSON入力はクエリ実行前にサイズ制限と検証が行われ、データベースの失敗はSQLの詳細を公開せずに構造化されたエラーを返します。

## 検証と展開

```bash
npm run typecheck
npm test
npm run deploy:dry-run
npm run check
```

最初のDatabase Workerの展開時にD1バインディングが自動的にプロビジョニングされます。これはテンプレートが意図的にアカウント固有の`database_id`を省略しているためです。リモートマイグレーションとRouter Workerの展開前にDatabase Workerを展開してください。`npm run deploy`はその順序を強制します。リモートマイグレーションコマンドは明示的であり、ローカル開発の一部として実行されることはありません。

## Haskell/WASMビルドアイデア

```bash
wasm32-wasi-cabal build exe:humblr-router
cp $(wasm32-wasi-cabal list-bin exe:humblr-router) dist/humblr_router.wasm
npx wrangler deploy --config wrangler.router.jsonc
```

この`.hs`ファイルは意図的にルートのCabalビルドには含まれていません。これらはワーカー向けの契約を記述し、エッジ実験をローカルのServantアプリから隔離するためのものです。