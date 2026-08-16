<!-- i18n: language-switcher -->
[English](RELEASE_NOTES_v0.1.2.md) | [日本語](RELEASE_NOTES_v0.1.2.ja.md)

# v0.1.2

Haskell Production Lab の再現可能なツールチェインリリース。

## 収録内容

- 開発シェルを宣言する`flake.nix`、`flake.lock`、`.envrc`。
  GHC 9.8.4、cabal-install、haskell-language-server、fourmoluに加え、
  依存パッケージがリンクするlibpqとzlibを含みます。
- シェルのコンパイラは`.github/workflows/ci.yml`が入れるものと同じ
  GHC 9.8.4です。手元のビルドとCIのビルドが、マシンにたまたま入っていた
  GHCの違いで食い違うことはなくなりました。
- リリースワークフローの修正：ノートのファイルをタグごとに
  `docs/RELEASE_NOTES_<tag>.md`として解決します。従来は
  `RELEASE_NOTES_v0.1.0.md`に固定されていたため、v0.1.0以降のどのタグも
  v0.1.0の本文を自身のリリースノートとして公開してしまう状態でした。
  ファイルが無い場合は生成ノートにフォールバックします。
- README、README.ja、STATUSをシェル前提の手順に更新。

## 廃止した回避策

いずれもパッケージマネージャの外で入れたGHCに由来するもので、もう不要です。
再導入しないでください。

- conda由来のGHCがリンカを見つけるために必要だった
  `~/.local/bin/x86_64-conda-linux-gnu-ld`から`/usr/bin/ld`へのシンボリックリンク。
- v0.1.1が検証コマンドとして記録していた、`cabal`の前に置く
  `LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH`。

## 検証方法

- `nix develop -c cabal build all`
- `nix develop -c cabal test all`
- 同じシェルから起動した PostgreSQL 18.4 を`HPS_TEST_DATABASE_URL`に指定して
  `cabal test all`を再実行。libpq 経路をスキップさせずに通した
- `nix flake check`

## 備考

- このリリースでライブラリ、実行ファイル、APIの挙動は変更していません。
- PostgreSQL統合テストは`HPS_TEST_DATABASE_URL`が未設定なら従来どおり
  スキップされます。
