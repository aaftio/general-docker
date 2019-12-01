#!/bin/bash
set -e

while getopts "d" OPT; do
  case $OPT in
    d)
      /usr/bin/curl -f https://ftp.apnic.net/stats/apnic/delegated-apnic-latest -o /delegated-apnic-latest;;
  esac
done

/bin/cat /delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > /CHN-IPs

iptables -t filter -n -L BAN-CHN-IP >/dev/null 2>&1 \
  || (iptables -t filter -N BAN-CHN-IP && iptables -t filter -A OUTPUT -m state --state NEW -j BAN-CHN-IP)

iptables -t filter -F BAN-CHN-IP

for i in $(cat /CHN-IPs)
do
  iptables -t filter -A BAN-CHN-IP -d $i -j REJECT
done

