#!/bin/sh
set -e
i2p_path=$1
$i2p_path/runplain.sh
while true; do
  sleep 1d
done
