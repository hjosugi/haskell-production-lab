# chezmoi Integration

This project is intentionally not stored inside chezmoi as a copied directory. The source of truth is the public GitHub repository.

Recommended chezmoi state:

- keep a small bootstrap script or note in the dotfiles repo
- clone `haskell-production-lab` into the preferred workspace
- run `cabal update && cabal test hps-test`

Example bootstrap script:

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

The script keeps dotfiles small while making the Haskell lab reproducible on a new machine.
