FROM alpine:latest as builder

WORKDIR /root
COPY v2ray.sh /root/v2ray.sh

RUN set -ex \
	&& apk add --no-cache tzdata openssl ca-certificates \
	&& mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
	&& chmod +x /root/v2ray.sh \
	&& /root/v2ray.sh linux/arm64

VOLUME /etc/v2ray
CMD [ "/usr/bin/v2ray", "-config", "/etc/v2ray/config.json" ]

FROM alpine:3.10.3
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

# Install v2ray
COPY --from=builder /usr/local/bin/v2ray /usr/bin/v2ray/
COPY --from=builder /usr/local/bin/v2ctl /usr/bin/v2ray/
COPY --from=builder /usr/local/share/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=builder /usr/local/share/v2ray/geosite.dat /usr/bin/v2ray/

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
