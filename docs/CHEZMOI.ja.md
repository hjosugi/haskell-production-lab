<!-- i18n: language-switcher -->
[English](CHEZMOI.md) | [日本語](CHEZMOI.ja.md)

# chezmoi 連携

このプロジェクトは意図的に chezmoi 内にコピーされたディレクトリとして保存されていません。真の情報源は公開の GitHub リポジトリです。

推奨される chezmoi の状態：

- dotfiles リポジトリに小さなブートストラップスクリプトやメモを保持する
- `haskell-production-lab` を希望の作業スペースにクローンする
- `cabal update && cabal test hps-test` を実行する

例のブートストラップスクリプト：

```bash
#!/usr/bin/env bash
set -euo pipefail

workspace="${HOME}/workspace"
repo="${workspace}/haskell-production-lab"

mkdir -p "${workspace}"
if [ ! -d "${repo}/.git" ]; then
  git clone git@github.com:hjosugi/haskell-production-lab.git "${repo}"
fi

cd "${repo}"
cabal update
cabal test hps-test
```

このスクリプトは dotfiles を小さく保ちながら、新しいマシンでも Haskell ラボを再現可能にします。