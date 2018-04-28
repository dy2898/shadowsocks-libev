FROM nginx:stable-alpine

ENV PASSWD="passwd" SS_VER="3.1.3" \
    ID="e92d4093-dbe9-4d6a-b615-e4971ee62fac"  V2RAY_VER="3.19"

ADD conf/default.conf /etc/nginx/conf.d/
ADD conf/ss_config.json /etc/ss_config.json
ADD conf/v_config.json /etc/v_config.json
ADD entrypoint.sh /entrypoint.sh

RUN apk upgrade --update \
    && apk add bash libsodium \
    && apk add --virtual .build-deps \
        autoconf \
        automake \
        xmlto \
        build-base \
        curl \
        c-ares-dev \
        libev-dev \
        libtool \
        linux-headers \
        udns-dev \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        udns-dev \
        tar \
        git \
    && curl -sSLO https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_VER}/shadowsocks-libev-${SS_VER}.tar.gz \
    && tar -zxf shadowsocks-libev-${SS_VER}.tar.gz \
    && (cd shadowsocks-libev-${SS_VER} \
    && ./configure --prefix=/usr --disable-documentation \
    && make install) \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && (cd simple-obfs \
    && git submodule update --init --recursive \
    && ./autogen.sh && ./configure --disable-documentation\
    && make && make install) \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* /usr/local/bin/obfs-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --virtual .run-deps $runDeps \
    && apk del .build-deps \
    && rm -rf shadowsocks-libev-${SS_VER}.tar.gz \
        shadowsocks-libev-${SS_VER} \
        simple-obfs \
        /var/cache/apk/* \
    && mkdir /var/log/v2ray \
    && chmod +x /entrypoint.sh 

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
