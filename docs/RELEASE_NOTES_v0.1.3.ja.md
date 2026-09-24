<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.3.md) | [日本語](RELEASE_NOTES_v0.1.3.ja.md)

# v0.1.3

Haskell Production Lab のメンテナンスリリース。

## 収録内容

- リリースワークフロー：各`docs/RELEASE_NOTES_<tag>.md`の先頭にある
  言語スイッチャーを、リリース本文からは取り除きます。リンクが`docs/`
  からの相対パスのため、`/releases/`配下では404になっていました。
  ファイル側には残します。
- CIでcabal storeをキャッシュします。キーは解決済みのビルドプラン
  （`cabal build all --dry-run`がコンパイル前に`plan.json`を書き出す）で、
  cabalジョブが毎回すべてのHackage依存を再ビルドすることはなくなりました。
- Cloudflare Workersブループリント（`cloudflare/humblr-workers`）の開発依存：
  wrangler 4.114.0、@cloudflare/vitest-pool-workers 0.18.8、
  miniflare 4.20260722.0、postcss 8.5.25、sharp 0.35.2（#4）。

## 検証方法

- Node 22で`cloudflare/humblr-workers`の`npm ci`、
  `CI=true npm run d1:migrate`、`npm run check`（Wranglerの型チェック、
  `tsc --noEmit`、Vitest、両Workerの`wrangler deploy --dry-run`）
- `main`のCI：`workers`ジョブと、GHC 9.8.4・PostgreSQL 16で
  `cabal build all`と`cabal test all`を実行する`cabal`ジョブ

## 備考

- このリリースでライブラリ、実行ファイル、APIの挙動は変更していません。
