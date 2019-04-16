#!/bin/bash
set -e

# ==============Configurate iptables===================

# Ignore your shadowsocks server's addresses
# It's very IMPORTANT, just be careful.
iptables -t nat -A PREROUTING -d $SS_SERVER_HOST -j RETURN

# Make strongswan can access network
iptables -t nat -A POSTROUTING -j MASQUERADE

# When use Linux Strongswan Client Or Android Client the MSS may consensus to be 1460, then the client can not access some website(eg. https://baidu.com).
# IOS client do not have this problem.
# MSS set to 1360
iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360

# Update iptables to split CHN-IPs
/bin/bash /update-iptables.sh
# Start crond
/usr/sbin/crond

# =============Start IKEv2 server=====================
ipsec start

# =============Start ss-redir========================
ss-redir -s $SS_SERVER_HOST -p $SS_SERVER_PORT -b 0.0.0.0 -l 1080 -m $SS_ENCRYPT_METHOD -k $SS_PASSWORD $SS_APPEND_CONFIG
