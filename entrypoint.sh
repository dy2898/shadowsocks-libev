#!/bin/bash

sed -i "s/PASSWD/$PASSWD/g" /etc/config.json
ss-server -c /etc/config.json &
nginx -g 'daemon off;'
