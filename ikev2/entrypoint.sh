#!/bin/bash
set -e

# ==============Configurate iptables===================

# Ignore your shadowsocks server's addresses
# It's very IMPORTANT, just be careful.
iptables -t nat -A PREROUTING -d $SS_SERVER_HOST -j RETURN

# Make strongswan can access network
iptables -t nat -A POSTROUTING -s 10.2.0.0/24 -o eth0 -j MASQUERADE

# Update iptables to split CHN-IPs
/bin/bash /update-iptables.sh
# Start crond
/usr/sbin/crond

# =============Start IKEv2 server=====================
ipsec start

# =============Start ss-redir========================
ss-redir -s $SS_SERVER_HOST -p $SS_SERVER_PORT -b 0.0.0.0 -l 1080 -m $SS_ENCRYPT_METHOD -k $SS_PASSWORD $SS_APPEND_CONFIG
