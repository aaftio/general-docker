FROM alpine:3.8
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
ADD sendemail.sh /sendemail.sh
ADD crontab /var/spool/cron/crontabs/root
RUN apk update && apk add mutt p7zip bash \
    && chmod +x /sendemail.sh

CMD /sendemail.sh && crond -f

