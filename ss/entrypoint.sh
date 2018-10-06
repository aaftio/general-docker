#!/bin/bash

set -e

: ${SS_MODULE:="ss-server"}
: ${SS_CONFIG:=""}
unset BAN_CHN_IP

while getopts "s:m:b" OPT; do
  case $OPT in
    s)
      SS_CONFIG=$OPTARG;;
    m)
      SS_MODULE=$OPTARG;;
    b)
      BAN_CHN_IP=true;;
  esac
done

if [ ! -z $BAN_CHN_IP ]; then
  /bin/bash /update-iptables.sh

  # Start crond
  /usr/sbin/crond
fi

if [ "$SS_CONFIG" != "" ]; then
    echo -e "\033[32mStarting shadowsocks......\033[0m"
    $SS_MODULE $SS_CONFIG
else
    echo -e "\033[31mError: SS_CONFIG is blank!\033[0m"
    exit 1
fi
