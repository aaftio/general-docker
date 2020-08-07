FROM golang:1.13.0-alpine3.10 as builder

COPY ./frp /frp
WORKDIR /frp
RUN apk update && apk add make && make

FROM alpine:3.11.6
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

COPY --from=builder /frp/bin/frpc /usr/bin/
COPY --from=builder /frp/bin/frps /usr/bin/
RUN chmod +x /usr/bin/frpc \
  && chmod +x /usr/bin/frps
