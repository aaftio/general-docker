FROM node:10.15-slim
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

RUN echo 'nameserver 172.22.0.3' > /etc/resolv.conf

RUN apt-get update && apt-get install -yq libgconf-2-4 apt-transport-https

ENV NODE_ENV production

WORKDIR /app

COPY ./RSSHub/package.json /app

RUN npm config set registry https://registry.npm.taobao.org

RUN apt-get install -y wget --no-install-recommends \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get purge --auto-remove -y curl \
  && rm -rf /src/*.deb \
  && npm install --production;

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

COPY ./RSSHub /app

# 安装strongswan相关
RUN apt-get update && apt-get install -y strongswan libcharon-extra-plugins

EXPOSE 1200
ENTRYPOINT ["dumb-init", "--"]

CMD ["bash", "-c", "ipsec start && npm run start"]
