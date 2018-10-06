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


# ================================== TCP ===============================
# Create chain if not exist
iptables -t nat -n -L SHADOWSOCKS >/dev/null 2>&1 \
  || (iptables -t nat -N SHADOWSOCKS && iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS)

# Flush chain
iptables -t nat -F SHADOWSOCKS

# All reserved network bypass the proxy
for i in ${reserved_networks[@]}; do
  iptables -t nat -A SHADOWSOCKS -d $i -j RETURN
done

# All CHN IPs will bypass the proxy
for i in $(cat /CHN-IPs)
do
  iptables -t nat -A SHADOWSOCKS -d $i -j RETURN
done

# Anything else should be redirected to shadowsocks's local port
iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports 1080


# ================================== UDP ===============================
# Create chain if not exits
iptables -t mangle -n -L SHADOWSOCKS >/dev/null 2>&1 \
  || (iptables -t mangle -N SHADOWSOCKS \
    && iptables -t mangle -A PREROUTING -p udp --dport 53 -j SHADOWSOCKS \
    && ip route add local default dev lo table 100 \
    && ip rule add fwmark 1 lookup 100)

# Flush chain
iptables -t mangle -F SHADOWSOCKS

# All reserved network bypass the proxy
for i in ${reserved_networks[@]}; do
  iptables -t mangle -A SHADOWSOCKS -d $i -j RETURN
done

# All CHN IPs will bypass the proxy
for i in $(cat /CHN-IPs)
do
  iptables -t mangle -A SHADOWSOCKS -d $i -j RETURN
done

# Any DNS query (destination dns server not in CHN) will go through proxy, to prevent DNS cache pollution. TODO: (write a description about this)
iptables -t mangle -A SHADOWSOCKS -p udp --dport 53 -j TPROXY --on-port 1080 --tproxy-mark 0x01/0x01

