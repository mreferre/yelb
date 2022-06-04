FROM elixir:1.13-otp-25-alpine as build

RUN apk add --update git

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config ./
RUN mix do deps.get, deps.compile

COPY . .
RUN mix distillery.release --env=prod --no-tar --verbose

FROM alpine:3.9
RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc bash ca-certificates erlang-crypto

RUN mkdir /app && chown -R nobody: /app
WORKDIR /app
USER nobody

COPY --from=build /app/_build/prod/rel/yelb_pheonix ./

ENV PORT=4000 REDIS_HOST=redis-server REDIS_PORT=6379
EXPOSE ${PORT}

ENV REPLACE_OS_VARS=true SHELL=/bin/bash

ENTRYPOINT [ "/app/bin/yelb_pheonix", "foreground" ]