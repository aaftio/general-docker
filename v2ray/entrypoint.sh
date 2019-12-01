#!/bin/bash

set -e

: ${MODULE:="v2ray"}
: ${CONFIG:="-config=/etc/v2ray/config.json"}
unset BAN_CHN_IP

while getopts "c:m:b" OPT; do
  case $OPT in
    c)
      CONFIG=$OPTARG;;
    m)
      MODULE=$OPTARG;;
    b)
      BAN_CHN_IP=true;;
  esac
done

if [ ! -z $BAN_CHN_IP ]; then
  /bin/bash /update-iptables.sh

  # Start crond
  /usr/sbin/crond
fi

if [ "$CONFIG" != "" ]; then
    echo -e "\033[32mStarting: $MODULE $CONFIG ......\033[0m"
    $MODULE $CONFIG
else
    echo -e "\033[31mError: CONFIG is blank!\033[0m"
    exit 1
fi
