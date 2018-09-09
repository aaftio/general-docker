FROM golang:1.10.4-alpine3.8 as builder

LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"
RUN apk update && \
    apk upgrade && \
    apk add git
RUN go get -ldflags "-X main.VERSION=$(date -u +%Y%m%d) -s -w" github.com/xtaci/kcptun/client && go get -ldflags "-X main.VERSION=$(date -u +%Y%m%d) -s -w" github.com/xtaci/kcptun/server

FROM alpine:3.8
COPY --from=builder /go/bin /bin
EXPOSE 29900
EXPOSE 12948
