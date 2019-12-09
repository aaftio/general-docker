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
IN_CHN_IP_CHAIN="MY_IN_CHNIP"
IN_CHN_IP_TABLE="mangle"
OUT_MARK_CHAIN="MY_OUT_MARK"
OUT_MARK_TABLE="mangle"

SS_PROXY_PORT=1080
V2RAY_PROXY_PORT=1081
V2RAY_DIRECT_PORT=1082

# Proxy chain for VPN client or local machine
iptables -t $IN_PROXY_TABLE -n -L $IN_PROXY_CHAIN >/dev/null 2>&1 \
  || (iptables -t $IN_PROXY_TABLE -N $IN_PROXY_CHAIN && iptables -t $IN_PROXY_TABLE -A PREROUTING -j $IN_PROXY_CHAIN)

# Proxy CHN IPs CHAIN
iptables -t $IN_CHN_IP_TABLE -n -L $IN_CHN_IP_CHAIN >/dev/null 2>&1 \
  || (iptables -t $IN_CHN_IP_TABLE -N $IN_CHN_IP_CHAIN \
    && iptables -t $IN_CHN_IP_TABLE -A $IN_CHN_IP_CHAIN -p udp --dport 53 -j TPROXY --on-port $V2RAY_PROXY_PORT --tproxy-mark 1 \
    && iptables -t $IN_CHN_IP_TABLE -A $IN_CHN_IP_CHAIN -p udp -j TPROXY --on-port $V2RAY_DIRECT_PORT --tproxy-mark 1 \
    && iptables -t $IN_CHN_IP_TABLE -A $IN_CHN_IP_CHAIN -p tcp -j TPROXY --on-port $V2RAY_DIRECT_PORT --tproxy-mark 1)

## Flush IN_PROXY_CHAIN
iptables -t $IN_PROXY_TABLE -F $IN_PROXY_CHAIN

## All reserved network bypass the proxy
for i in ${reserved_networks[@]}; do
  iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -d $i -j RETURN
done

## All DNS (port 53, tcp) to v2ray
iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -p tcp --dport 53 -j TPROXY --on-port $V2RAY_PROXY_PORT --tproxy-mark 1

## All CHN IPs will bypass the proxy
for i in $(cat /CHN-IPs)
do
  iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -d $i -j $IN_CHN_IP_CHAIN
done

### Any else tcp will proxy
iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -p tcp -j TPROXY --on-port $V2RAY_PROXY_PORT --tproxy-mark 1

### Not CHN DNS udp use ss proxy
iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -p udp --dport 53 -j TPROXY --on-port $SS_PROXY_PORT --tproxy-mark 1

### All not CHN ip udp and not 53 port udp go direct by v2ray
iptables -t $IN_PROXY_TABLE -A $IN_PROXY_CHAIN -p udp -j TPROXY --on-port $V2RAY_DIRECT_PORT --tproxy-mark 1


# Proxy local machine traffic
iptables -t $OUT_MARK_TABLE -n -L $OUT_MARK_CHAIN >/dev/null 2>&1 \
  || (iptables -t $OUT_MARK_TABLE -N $OUT_MARK_CHAIN \
    && iptables -t $OUT_MARK_TABLE -A OUTPUT -p udp --dport 53 -j $OUT_MARK_CHAIN \
    && iptables -t $OUT_MARK_TABLE -A OUTPUT -p tcp -j $OUT_MARK_CHAIN \
    && ip route add local default dev lo table 100 \
    && ip rule add fwmark 1 table 100)


## Flush OUT_MARK_CHAIN
iptables -t $OUT_MARK_TABLE -F $OUT_MARK_CHAIN

## Marked by 0xff(255) is from the v2ray, and if is TCP, bypass the proxy
iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -m mark --mark 0xff -j RETURN

## All reserved network bypass the proxy
for i in ${reserved_networks[@]}; do
  iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -d $i -j RETURN
done

### Mark TCP, and re-routing
iptables -t $OUT_MARK_TABLE -A $OUT_MARK_CHAIN -j MARK --set-mark 1
