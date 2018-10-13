#!/bin/bash

valid_ip() {
  local ip=$1
  local stat=1
  local array

  if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    readarray -d . -t array <<< "$ip."; unset array[-1]
    [[ ${array[0]} -le 255 && ${array[1]} -le 255 && ${array[2]} -le 255 && ${array[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

valid_port() {
  local port=$1
  [[ "$port" -ge 0 && "$port" -le 65535 ]]
  return $?
}

add_rule() {
  local array dst_port to_ip to_port protocol

  readarray -d "/" -t array <<< "$1/"; unset array[-1]

  if [ "${#array[@]}" -eq 2 ]; then
    protocol="${array[1]}"
    if [[ "$protocol" != "tcp" && "$protocol" != "udp" ]]; then
      echo "Invalid protocol: $protocol"
      exit 1
    fi
  else
    echo 'error parameter format, maybe no specify protocol'
    exit 1
  fi

  readarray -d ":" -t array <<< "${array[0]}:"; unset array[-1]
  if [[ ${#array[@]} -ne 3 ]]; then
    echo 'error parameter format'
    exit 1
  fi

  dst_port=${array[0]}
  to_ip=${array[1]}
  to_port=${array[2]}

  if ! valid_port $dst_port; then
    echo "Invalid port: $dst_port"
    exit 1
  fi

  if ! valid_ip $to_ip; then
    echo "Invalid IP: $to_ip"
    exit 1
  fi

  if ! valid_port $to_port; then
    echo "Invalid port: $to_port"
    exit 1
  fi

  iptables -t nat -A PREROUTING -p $protocol --dport $dst_port -j DNAT --to $to_ip:$to_port
}

while getopts "p:" OPT; do
  case $OPT in
    p)
      add_rule $OPTARG
  esac
done

iptables -t nat -A POSTROUTING -j MASQUERADE

# hungup the bash
bash
