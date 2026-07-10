FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates build-essential libgmp-dev libpq-dev pkg-config zlib1g-dev git \
  && rm -rf /var/lib/apt/lists/*

ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV BOOTSTRAP_HASKELL_INSTALL_HLS=1
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ENV PATH=/root/.ghcup/bin:/root/.cabal/bin:$PATH

WORKDIR /app
COPY . .
RUN cabal update \
  && cabal build exe:hps-api exe:hps-websocket \
  && cp "$(cabal list-bin exe:hps-api)" /usr/local/bin/hps-api \
  && cp "$(cabal list-bin exe:hps-websocket)" /usr/local/bin/hps-websocket

FROM ubuntu:24.04 AS runtime
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates libgmp10 libpq5 \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /usr/local/bin/hps-api /usr/local/bin/hps-api
COPY --from=build /usr/local/bin/hps-websocket /usr/local/bin/hps-websocket
ENV PORT=8080
CMD ["hps-api"]
