#!/bin/bash
set -e

while getopts "d" OPT; do
  case $OPT in
    d)
      /usr/bin/curl -f https://ftp.apnic.net/stats/apnic/delegated-apnic-latest -o /delegated-apnic-latest;;
  esac
done

/bin/cat /delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > /CHN-IPs


iptables -t filter -n -L SHADOWSOCKS >/dev/null 2>&1 \
  || (iptables -t filter -N SHADOWSOCKS && iptables -t filter -A OUTPUT -m state --state NEW -j SHADOWSOCKS)

iptables -t filter -F SHADOWSOCKS

for i in $(cat /CHN-IPs)
do
  iptables -t filter -A SHADOWSOCKS -d $i -j REJECT
done

