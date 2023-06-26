FROM erlang:21-alpine

RUN mkdir /buildroot
WORKDIR /buildroot

COPY coursework2 coursework2

WORKDIR coursework2

RUN apk add git
RUN apk add make
RUN rebar3 as prod release

FROM alpine:3.15

ADD coursework2/c_src/Makefile /files/
ADD coursework2/c_src/rtpsend.c /files/
ADD coursework2/c_src/generate.wav /files/

RUN apk add --no-cache make build-base
RUN apk add --no-cache ffmpeg
RUN apk add --no-cache ortp-dev
RUN apk add --no-cache bctoolbox-dev

RUN (cd files/ && make)

COPY --from=0 /buildroot/coursework2/_build/prod/rel/coursework2 /coursework2

EXPOSE 8080

CMD ["coursework2/bin/coursework2", "foreground"]