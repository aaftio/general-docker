FROM ubuntu:18.04 as builder

RUN apt-get update
RUN apt-get install curl -y
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh

FROM alpine:3.10.3

LABEL maintainer "panhaipeng1989@gmail.com"

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

# iptables

RUN apk --no-cache add curl bash iptables

COPY entrypoint.sh /
COPY update-iptables.sh /
COPY crontab /var/spool/cron/crontabs/root
COPY delegated-apnic-latest /

ENTRYPOINT ["bash", "/entrypoint.sh"]
