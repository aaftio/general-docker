FROM ubuntu:18.04 as builder

RUN apt-get update
RUN apt-get install curl -y
RUN curl -L -o /tmp/install-release.sh https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh
RUN chmod +x /tmp/install-release.sh
RUN /tmp/install-release.sh

FROM alpine:3.10.3
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

# Install v2ray
COPY --from=builder /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
COPY --from=builder /etc/v2ray/config.json /etc/v2ray/

RUN apk --no-cache add ca-certificates \
  && mkdir /var/log/v2ray \
  && chmod +x /usr/bin/v2ray/v2ctl \
  && chmod +x /usr/bin/v2ray/v2ray

ENV PATH /usr/bin/v2ray:$PATH

# Install ss
ENV SS_LIBEV_VERSION 3.3.3
ENV SS_DOWNLOAD_URL https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_LIBEV_VERSION}/shadowsocks-libev-${SS_LIBEV_VERSION}.tar.gz

RUN apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        build-base \
        curl \
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
    && apk add --no-cache \
        rng-tools \
        $(scanelf --needed --nobanner /usr/bin/ss-* \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u) \
    && rm -rf shadowsocks-libev-${SS_LIBEV_VERSION}.tar.gz \
        shadowsocks-libev-${SS_LIBEV_VERSION}

# Install strongswan, dns server and utils
RUN apk add --no-cache iptables strongswan curl bash \
    && mv /etc/ipsec.conf /etc/ipsec.conf.bak \
    && mv /etc/ipsec.secrets /etc/ipsec.secrets.bak

COPY delegated-apnic-latest /
COPY entrypoint.sh /
COPY update-iptables.sh /
COPY crontab var/spool/cron/crontabs/root

ENTRYPOINT ["bash", "/entrypoint.sh"]
