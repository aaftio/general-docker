FROM alpine:3.8
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

RUN apk update && apk add --no-cache bind strongswan \
    && mv /etc/ipsec.conf /etc/ipsec.conf.bak \
    && mv /etc/ipsec.secrets /etc/ipsec.secrets.bak

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
