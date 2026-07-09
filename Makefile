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
