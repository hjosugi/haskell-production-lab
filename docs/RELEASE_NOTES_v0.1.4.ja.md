<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.4.md) | [日本語](RELEASE_NOTES_v0.1.4.ja.md)

# v0.1.4

Haskell Production Lab のメンテナンスリリース。

## 収録内容

- Cloudflare Workersブループリント（`cloudflare/humblr-workers`）の開発依存で、
  未対応だったセキュリティアドバイザリをvitest 4のまま解消しました。
  `@cloudflare/vitest-pool-workers`がまだ`vitest ^4.1.0`をピアに取るため
  です（#6）。
  - vitestと@vitest/mocker 4.1.11（GHSA-82fw-gwwq-j7x9）
  - undici 7.29.0。miniflareが固定しているため、
    @cloudflare/vitest-pool-workers 0.22.0とwrangler ^4.124.0経由で更新
  - sharp 0.35.4（GHSA-rgj7-g3m4-5g8c）を`overrides`で指定。miniflareが
    sharpを完全一致で固定しており、最新のvitest-pool-workersもまだ0.35.2を
    固定しています。vitest-pool-workersが新しいminiflareを取り込めば
    overrideは外せます。

## 検証方法

- Node 22で`cloudflare/humblr-workers`の`npm ci`、`npm audit`
  （脆弱性0件）、`CI=true npm run d1:migrate`、`npm run check`
  （Wranglerの型チェック、`tsc --noEmit`、Vitest、両Workerの
  `wrangler deploy --dry-run`）
- `main`のCI：`workers`ジョブと、GHC 9.8.4・PostgreSQL 16で
  `cabal build all`と`cabal test all`を実行する`cabal`ジョブ

## 備考

- このリリースでライブラリ、実行ファイル、APIの挙動は変更していません。
