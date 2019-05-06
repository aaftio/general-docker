# Build image
FROM alpine:3.8 as bitcoin-core-build

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories

RUN apk update && apk add patch gcc g++ make \
  autoconf automake libtool boost-dev libressl-dev libevent-dev miniupnpc-dev zeromq-dev

COPY bitcoin /bitcoin
WORKDIR /bitcoin

RUN /bitcoin/contrib/install_db4.sh `pwd`
RUN ./autogen.sh
RUN ./configure \
    BDB_LIBS="-L/bitcoin/db4/lib -ldb_cxx-4.8" BDB_CFLAGS="-I/bitcoin/db4/include" \
    --prefix=/opt/bitcoin \
    --with-gui=no
RUN make -j4 && make install


# Final image
FROM alpine:3.8
LABEL maintainer="panhaipeng <panhaipeng1989@gmail.com>"

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk update && apk add bash iproute2 boost libevent miniupnpc libressl zeromq

COPY --from=bitcoin-core-build /opt/bitcoin /opt/bitcoin
ENV PATH=/opt/bitcoin/bin:$PATH

# Add Network Upload Max Rate Limit Tool
COPY wondershaper /usr/local/bin/

COPY entrypoint.sh /entrypoint.sh

VOLUME ["/root/.bitcoin"]
EXPOSE 8332 8333

ENTRYPOINT ["bash", "/entrypoint.sh"]
