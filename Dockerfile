FROM elixir:1.6 as deps-getter

WORKDIR /opt/app

RUN mix do local.hex --force, local.rebar --force
COPY mix.exs mix.lock ./

RUN mix deps.get

########################################################################
FROM node:8 as asset-builder

WORKDIR /opt/app

COPY --from=deps-getter /opt/app/deps ./deps

WORKDIR /opt/app/assets

COPY assets/ ./
RUN yarn install
RUN yarn run deploy

########################################################################
FROM elixir:1.6-alpine as releaser

WORKDIR /opt/app

# dependencies for comeonin
RUN apk add --no-cache git build-base cmake && rm -rf /var/cache/apk/*

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

COPY --from=deps-getter /opt/app/deps ./deps

# Cache elixir deps
# COPY config/ ./config/
COPY mix.exs mix.lock ./

ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . .

# Digest precompiled assets
COPY --from=asset-builder /opt/app/priv/static/ ./priv/static/

WORKDIR /opt/app
RUN mix phx.digest

# Release
RUN mix release --env=$MIX_ENV

########################################################################
FROM elixir:1.6-alpine

WORKDIR /opt/app

ENV LANG=en_US.UTF-8
ENV VERSION=0.0.1

RUN apk add --no-cache bash netcat-openbsd && rm -rf /var/cache/apk/*

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod REPLACE_OS_VARS=true SHELL=/bin/sh

COPY --from=releaser /opt/app/_build/prod/rel/tilex/releases/$VERSION/tilex.tar.gz ./

COPY ./wait-pg.sh /opt/app/bin/wait-pg.sh

RUN tar -xzf tilex.tar.gz
RUN rm -fr tilex.tar.gz

ENTRYPOINT ["/opt/app/bin/tilex"]
CMD ["foreground"]
