FROM openjdk:8u171-jdk-alpine3.8
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

ENV I2P_DOWNLOAD_URL https://download.i2p2.de/releases/0.9.37/i2pinstall_0.9.37.jar
ENV JAR_FILE_NAME i2pinstall_0.9.37.jar
ENV I2P_PATH /i2p

RUN apk add curl expect --no-cache \
  && curl -sSLO ${I2P_DOWNLOAD_URL} \
  && apk del curl

COPY install.expect /
RUN expect /install.expect ${JAR_FILE_NAME} ${I2P_PATH} && rm -rf /install.expect /$JAR_FILE_NAME

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh", "${I2P_PATH}"]
