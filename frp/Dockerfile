From golang:1.13.0-alpine3.10
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

COPY ./frp /frp
WORKDIR /frp
RUN apk update && apk add make && make
