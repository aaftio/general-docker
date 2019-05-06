#!/bin/bash
set -e

# Max Upload Rate (Kbps)
: ${MAX_UPLOAD_RATE:=10240}

wondershaper -a eth0 -u $MAX_UPLOAD_RATE
bitcoind
