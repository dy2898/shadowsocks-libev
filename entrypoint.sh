#!/bin/bash
sed -i "s/ID/$ID/g" /etc/v2ray/config.json
sed -i "s/PASSWD/$PASSWD/g" /etc/config.json

curl -L -H "Cache-Control: no-cache" -o v2ray.zip http://github.com/v2ray/v2ray-core/releases/download/v$V2ARY_VER/v2ray-linux-64.zip
unzip v2ray.zip
mv ./v2ray-v$V2ARY_VER-linux-64/v2ray /usr/local/bin/
mv ./v2ray-v$V2ARY_VER-linux-64/v2ctl /usr/local/bin/
chmod +x /usr/local/bin/*
rm -rf v2ray.zip
rm -rf v2ray-v$V2ARY_VER-linux-64

v2ray -config=/etc/v_config.json &
ss-server -c /etc/ss_config.json &
nginx -g 'daemon off;'
