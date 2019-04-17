FROM diygod/rsshub
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

RUN apt-get update && apt-get install -y strongswan libcharon-extra-plugins

CMD ["bash", "-c", "ipsec start && npm run start"]
