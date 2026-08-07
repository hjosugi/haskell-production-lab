.PHONY: build test run-api run-lab run-websocket run-worker format docs clean zip

build:
	cabal build all

test:
	cabal test all

run-api:
	cabal run hps-api

run-lab:
	cabal run hps-api

run-websocket:
	PORT=8081 cabal run hps-websocket

run-worker:
	cabal run hps-worker

format:
	fourmolu -i src app test

docs:
	cabal haddock all

clean:
	rm -rf dist-newstyle public data

zip:
	git archive --format=zip --output=../haskell-production-lab.zip HEAD

.PHONY: graphify-setup graphify-update

## Install graphify and register its skill with Claude, Copilot and Codex.
graphify-setup:
	@sh scripts/graphify.sh setup

## Upgrade graphify, refresh the skill, and update the knowledge graph.
graphify-update:
	@sh scripts/graphify.sh update
