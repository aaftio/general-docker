FROM alpine:3.10.3
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

ENV SS_LIBEV_VERSION 3.3.3
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_LIBEV_VERSION}/shadowsocks-libev-${SS_LIBEV_VERSION}.tar.gz

RUN apk add --no-cache curl iptables bash \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        c-ares-dev \
        libev-dev \
        libtool \
        libsodium-dev \
        linux-headers \
        mbedtls-dev \
        pcre-dev \
        tar \
    && curl -sSLO ${SS_DOWNLOAD_URL} \
    && tar -zxf shadowsocks-libev-${SS_LIBEV_VERSION}.tar.gz \
    && (cd shadowsocks-libev-${SS_LIBEV_VERSION} \
    && ./configure --prefix=/usr --disable-documentation \
    && make install) \
    && apk del .build-deps \
    # Runtime dependencies setup
    && apk add --no-cache \
        ca-certificates \
        rng-tools \
        $(scanelf --needed --nobanner /usr/bin/ss-* \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u) \
    && rm -rf shadowsocks-libev-${SS_LIBEV_VERSION}.tar.gz \
        shadowsocks-libev-${SS_LIBEV_VERSION}

COPY entrypoint.sh /
COPY update-iptables.sh /
COPY crontab /var/spool/cron/crontabs/root
COPY delegated-apnic-latest /

ENTRYPOINT ["bash", "/entrypoint.sh"]
