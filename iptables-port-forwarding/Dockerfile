FROM alpine:3.8
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

RUN apk update && apk add iptables bash
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]
