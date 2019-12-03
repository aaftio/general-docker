#!/bin/bash
set -e

while getopts "d" OPT; do
  case $OPT in
    d)
      /usr/bin/curl -f https://ftp.apnic.net/stats/apnic/delegated-apnic-latest -o /delegated-apnic-latest;;
  esac
done

cat /delegated-apnic-latest | awk -F '|' '/CN/&&/ipv4/ {print $4 "/" 32-log($5)/log(2)}' | cat > /CHN-IPs

# Ignore LANs and any other addresses you'd like to bypass the proxy
# See Wikipedia and RFC5735 for full list of reserved networks.
# See ashi009/bestroutetb for a highly optimized CHN route list.
reserved_networks=(\
  "0.0.0.0/8" \
  "10.0.0.0/8" \
  "127.0.0.0/8" \
  "169.254.0.0/16" \
  "172.16.0.0/12" \
  "192.168.0.0/16" \
  "224.0.0.0/4" \
  "240.0.0.0/4")


IN_PROXY_CHAIN="MY_IN_PROXY"
IN_PROXY_TABLE="mangle"
OUT_MARK_CHAIN="MY_OUT_MARK"
OUT_MARK_TABLE="mangle"

# Proxy chain for VPN client
iptables -t $IN_PROXY_TABLE -n -L $IN_PROXY_CHAIN >/dev/null 2>&1 \
  || (iptables -t $IN_PROXY_TABLE -N $IN_PROXY_CHAIN && iptables -t $IN_PROXY_TABLE -A PREROUTING -j $IN_PROXY_CHAIN)

## Flush IN_PROXY_CHAIN
iptables -t $IN_PROXY_TABLE -F $IN_PROXY_CHAIN

## All reserved network bypass the proxy
for i in ${reserved_networks[@]}; do
  iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -d $i -j RETURN
done

## All CHN IPs will bypass the proxy
for i in $(cat /CHN-IPs)
do
  iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -d $i -j RETURN
done

## Anything else should be proxy

### TCP proxy
iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -p tcp -j TPROXY --on-port 1080 --tproxy-mark 1

### UDP proxy( only proxy dns, port 53)
iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -p udp --dport 53 -j TPROXY --on-port 1080 --tproxy-mark 0x01/0x01



# Proxy local machine traffic
iptables -t $OUT_MARK_TABLE -n -L $OUT_MARK_CHAIN >/dev/null 2>&1 \
  || (iptables -t $OUT_MARK_TABLE -N $OUT_MARK_CHAIN \
    && iptables -t $OUT_MARK_TABLE -A OUTPUT -p udp --dport 53 -j $OUT_MARK_CHAIN\
    && ip route add local default dev lo table 100 \
    && ip rule add fwmark 1 table 100)


## Flush OUT_MARK_CHAIN
iptables -t $OUT_MARK_TABLE -F $OUT_MARK_CHAIN

## Marked by 0xff(255) is from the v2ray, bypass the proxy
iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -m mark --mark 0xff -j RETURN

## All reserved network bypass the proxy
for i in ${reserved_networks[@]}; do
  iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -d $i -j RETURN
done

## All CHN IPs will bypass the proxy
for i in $(cat /CHN-IPs)
do
  iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -d $i -j RETURN
done

### Mark TCP, and re-routing
iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -p tcp -j MARK --set-mark 1

### UDP proxy. Any DNS query (destination dns server not in CHN) will go through proxy, to prevent DNS cache pollution. TODO: (write a description about this)
iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -p udp --dport 53 -j MARK --set-mark 1 # Mark and re-routing

